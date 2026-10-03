import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/logger.dart';
import '../models/room_model.dart';
import '../models/room_member_model.dart';
import '../models/game_session_model.dart';
import '../models/game_player_model.dart';

class OnlineRoomRealtimeDataSource {
  final SupabaseClient supabase;
  RealtimeChannel? _roomChannel;

  // Broadcast stream controllers are never closed (singleton lifetime).
  // They are reused across room sessions. Only the Realtime channel is
  // unsubscribed between sessions.
  final _roomController = StreamController<RoomModel>.broadcast();
  final _membersController = StreamController<List<RoomMemberModel>>.broadcast();
  final _sessionController = StreamController<GameSessionModel>.broadcast();
  final _gamePlayersController = StreamController<List<GamePlayerModel>>.broadcast();

  Stream<RoomModel> get roomStream => _roomController.stream;
  Stream<List<RoomMemberModel>> get membersStream => _membersController.stream;
  Stream<GameSessionModel> get sessionStream => _sessionController.stream;
  Stream<List<GamePlayerModel>> get gamePlayersStream => _gamePlayersController.stream;

  OnlineRoomRealtimeDataSource(this.supabase);

  Future<void> subscribeToRoom(String roomId) async {
    unsubscribe();
    AppLogger.logInfo('OnlineRoomRealtimeDataSource: Subscribing to room $roomId');

    _roomChannel = supabase.channel('public:room:$roomId');

    _roomChannel!
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'rooms',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id',
          value: roomId,
        ),
        callback: (payload) {
          if (payload.eventType == PostgresChangeEvent.delete) {
            AppLogger.logInfo('OnlineRoomRealtimeDataSource: Room deleted');
          } else {
            final data = payload.newRecord;
            if (data.isNotEmpty && !_roomController.isClosed) {
              _roomController.add(RoomModel.fromJson(data));
            }
          }
        },
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'room_members',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'room_id',
          value: roomId,
        ),
        callback: (payload) {
          _fetchMembers(roomId);
        },
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'game_sessions',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'room_id',
          value: roomId,
        ),
        callback: (payload) {
          if (payload.eventType != PostgresChangeEvent.delete) {
            final data = payload.newRecord;
            if (data.isNotEmpty && !_sessionController.isClosed) {
              final session = GameSessionModel.fromJson(data);
              _sessionController.add(session);
              _fetchGamePlayers(session.id);
            }
          }
        },
      );

    _roomChannel!.subscribe();

    // Initial fetch to populate the members list immediately
    _fetchMembers(roomId);
  }

  RealtimeChannel? _sessionChannel;
  String? _currentSessionId;

  Future<void> _fetchMembers(String roomId) async {
    try {
      final response = await supabase
          .from('room_members')
          .select()
          .eq('room_id', roomId)
          .order('joined_at', ascending: true);

      final members = (response as List).map((json) => RoomMemberModel.fromJson(json)).toList();
      if (!_membersController.isClosed) {
        _membersController.add(members);
      }
    } catch (e) {
      AppLogger.logError('OnlineRoomRealtimeDataSource', e);
    }
  }

  Future<void> _fetchGamePlayers(String sessionId) async {
    try {
      if (_currentSessionId != sessionId) {
        _currentSessionId = sessionId;
        if (_sessionChannel != null) {
          supabase.removeChannel(_sessionChannel!);
        }
        
        _sessionChannel = supabase.channel('public:session:$sessionId');
        _sessionChannel!
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'game_players',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'session_id',
                value: sessionId,
              ),
              callback: (payload) {
                _fetchGamePlayers(sessionId);
              },
            )
            .subscribe();
      }

      final response = await supabase
          .from('game_players')
          .select()
          .eq('session_id', sessionId);

      final players = (response as List).map((json) => GamePlayerModel.fromJson(json)).toList();
      if (!_gamePlayersController.isClosed) {
        _gamePlayersController.add(players);
      }
    } catch (e) {
      AppLogger.logError('OnlineRoomRealtimeDataSource', e);
    }
  }

  /// Unsubscribes from the current Realtime channel without closing the stream
  /// controllers. Safe to call multiple times between room sessions.
  void unsubscribe() {
    if (_roomChannel != null) {
      supabase.removeChannel(_roomChannel!);
      _roomChannel = null;
    }
    if (_sessionChannel != null) {
      supabase.removeChannel(_sessionChannel!);
      _sessionChannel = null;
      _currentSessionId = null;
    }
  }

  /// Called only when the datasource is fully torn down (e.g. app logout).
  /// Do NOT call between room sessions — use [unsubscribe] instead.
  void dispose() {
    unsubscribe();
    _roomController.close();
    _membersController.close();
    _sessionController.close();
    _gamePlayersController.close();
  }
}
