import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/errors/app_error_exception.dart';
import '../../../../core/errors/app_error.dart';
import '../../domain/usecases/create_room_usecase.dart';
import '../../domain/usecases/join_room_usecase.dart';
import '../../domain/usecases/leave_room_usecase.dart';
import '../../domain/usecases/kick_player_usecase.dart';
import '../../domain/usecases/select_game_usecase.dart';
import '../../domain/usecases/start_game_usecase.dart';
import '../../domain/usecases/submit_game_event_usecase.dart';
import '../../domain/usecases/get_livekit_token_usecase.dart';
import '../../domain/usecases/get_story_by_id_usecase.dart';
import '../../data/datasources/online_room_realtime_datasource.dart';
import '../../data/datasources/livekit_service.dart';
import '../../data/models/room_model.dart';
import '../../../story/domain/entities/story.dart';
import '../../../story/domain/entities/clue.dart';
import '../../../story/domain/entities/suspect.dart';
import '../../domain/entities/room_status.dart';
import '../../../../core/services/analytics_service.dart';
import 'online_room_event.dart';
import 'online_room_state.dart';
import 'dart:async';

class OnlineRoomBloc extends Bloc<OnlineRoomEvent, OnlineRoomState> {
  final CreateRoomUseCase createRoom;
  final JoinRoomUseCase joinRoom;
  final LeaveRoomUseCase leaveRoom;
  final KickPlayerUseCase kickPlayerUseCase;
  final SelectGameUseCase selectGameUseCase;
  final StartGameUseCase startGameUseCase;
  final SubmitGameEventUseCase submitGameEventUseCase;
  final GetLiveKitTokenUseCase getLiveKitTokenUseCase;
  final GetStoryByIdUseCase getStoryByIdUseCase;
  final AuthService authService;
  final AnalyticsService analyticsService;
  final OnlineRoomRealtimeDataSource realtimeDataSource;
  final LiveKitService liveKitService;

  StreamSubscription? _roomSubscription;
  StreamSubscription? _membersSubscription;
  StreamSubscription? _sessionSubscription;
  StreamSubscription? _gamePlayersSubscription;

  /// Guard flag: prevents dispatching multiple FetchStoryRequested events
  /// when the session Realtime fires more than once before the fetch completes.
  bool _isFetchingStory = false;

  OnlineRoomBloc({
    required this.createRoom,
    required this.joinRoom,
    required this.leaveRoom,
    required this.kickPlayerUseCase,
    required this.selectGameUseCase,
    required this.startGameUseCase,
    required this.submitGameEventUseCase,
    required this.getLiveKitTokenUseCase,
    required this.getStoryByIdUseCase,
    required this.authService,
    required this.analyticsService,
    required this.realtimeDataSource,
    required this.liveKitService,
  }) : super(const OnlineRoomState()) {
    on<CreateRoomRequested>(_onCreateRoom);
    on<JoinRoomRequested>(_onJoinRoom);
    on<LeaveRoomRequested>(_onLeaveRoom);
    on<RoomUpdated>(_onRoomUpdated);
    on<MembersUpdated>(_onMembersUpdated);
    on<SessionUpdated>(_onSessionUpdated);
    on<GamePlayersUpdated>(_onGamePlayersUpdated);
    on<FetchStoryRequested>(_onFetchStoryRequested);
    on<StoryFetched>(_onStoryFetched);
    on<KickPlayerRequested>(_onKickPlayer);
    on<SelectGameRequested>(_onSelectGame);
    on<StartGameRequested>(_onStartGame);
    on<SubmitGameEventRequested>(_onSubmitGameEvent);
    on<ToggleMicRequested>(_onToggleMic);
  }

  @override
  Future<void> close() {
    _cancelSubscriptions();
    return super.close();
  }

  void _cancelSubscriptions() {
    _roomSubscription?.cancel();
    _membersSubscription?.cancel();
    _sessionSubscription?.cancel();
    _gamePlayersSubscription?.cancel();
    _roomSubscription = null;
    _membersSubscription = null;
    _sessionSubscription = null;
    _gamePlayersSubscription = null;
    realtimeDataSource.unsubscribe();
  }

  /// Subscribes to Realtime streams only — LiveKit is connected separately
  /// after a successful create/join emit to avoid a re-entrant add() that
  /// would crash on Android 13+ when the mic-permission dialog fires.
  void _subscribeToRealtime(String roomId) {
    _cancelSubscriptions();
    realtimeDataSource.subscribeToRoom(roomId);

    _roomSubscription = realtimeDataSource.roomStream.listen((room) {
      add(RoomUpdated(room));
    });

    _membersSubscription = realtimeDataSource.membersStream.listen((members) {
      add(MembersUpdated(members));
    });

    _sessionSubscription = realtimeDataSource.sessionStream.listen((session) {
      add(SessionUpdated(session));
    });

    _gamePlayersSubscription = realtimeDataSource.gamePlayersStream.listen((players) {
      add(GamePlayersUpdated(players));
    });
  }

  void _onRoomUpdated(RoomUpdated event, Emitter<OnlineRoomState> emit) {
    var newRoom = event.room;
    final oldRoom = state.room;
    
    // Postgres triggers with replica identity = default may omit unchanged columns in updates.
    // Since code, name, and hostId never change during the lifetime of a room, we ALWAYS
    // preserve them from the old state to avoid any accidental data loss or truncation.
    if (oldRoom != null && newRoom is RoomModel) {
      newRoom = newRoom.copyWith(
        code: oldRoom.code,
        name: oldRoom.name,
        hostId: oldRoom.hostId,
        selectedStoryId: newRoom.selectedStoryId ?? oldRoom.selectedStoryId,
        gameMode: newRoom.gameMode ?? oldRoom.gameMode,
        maxPlayers: newRoom.maxPlayers == 8 && oldRoom.maxPlayers != 8 ? oldRoom.maxPlayers : newRoom.maxPlayers,
        requiredPlayers: newRoom.requiredPlayers ?? oldRoom.requiredPlayers,
      );
    }

    final isHost = newRoom.isHost(authService.currentUserId ?? '');

    if (newRoom.status == RoomStatus.playing) {
      // Game is live — navigate to role reveal
      emit(state.copyWith(room: newRoom, isHost: isHost, status: OnlineRoomStatus.inGame));
    } else if (newRoom.status == RoomStatus.starting) {
      // Brief transition: disable UI while the server assigns roles on the server
      emit(state.copyWith(room: newRoom, isHost: isHost, status: OnlineRoomStatus.loading));
    } else {
      emit(state.copyWith(room: newRoom, isHost: isHost, status: OnlineRoomStatus.inLobby));
    }
  }

  void _onMembersUpdated(MembersUpdated event, Emitter<OnlineRoomState> emit) {
    final currentUserId = authService.currentUserId;
    if (currentUserId != null && state.status != OnlineRoomStatus.idle) {
      final isStillMember = event.members.any((m) => m.userId == currentUserId);
      if (!isStillMember) {
        // User was kicked — reset fully and navigate away
        emit(state.copyWith(
          status: OnlineRoomStatus.error,
          error: AppError('error_kicked_from_room'),
          room: null,      // now correctly sets room to null (sentinel fix)
          session: null,
          members: [],
        ));
        _cancelSubscriptions();
        return;
      }
    }
    emit(state.copyWith(members: event.members));
  }

  void _onSessionUpdated(SessionUpdated event, Emitter<OnlineRoomState> emit) {
    emit(state.copyWith(session: event.session));
    // Guard: only dispatch one fetch even if Realtime fires the session event
    // multiple times before the first fetch completes.
    if (state.story == null && !_isFetchingStory) {
      _isFetchingStory = true;
      add(FetchStoryRequested(event.session.storyId));
    }
  }

  void _onGamePlayersUpdated(GamePlayersUpdated event, Emitter<OnlineRoomState> emit) {
    emit(state.copyWith(gamePlayers: event.gamePlayers));
  }

  Future<void> _onFetchStoryRequested(FetchStoryRequested event, Emitter<OnlineRoomState> emit) async {
    try {
      final json = await getStoryByIdUseCase(event.storyId);
      final story = Story(
        title: json['title'] ?? '',
        intro: json['intro'] ?? '',
        crimeDescription: json['crimeDescription'] ?? '',
        twist: json['twist'] ?? '',
        killerName: json['killerName'] ?? '',
        suspects: (json['suspects'] as List<dynamic>?)
                ?.map((s) => Suspect(
                      name: s['name'] ?? '',
                      suspiciousBehavior: s['suspiciousBehavior'] ?? '',
                    ))
                .toList() ??
            [],
        clues: (json['clues'] as List<dynamic>?)
                ?.map((c) => Clue(
                      text: c['text'] ?? c['description'] ?? '',
                      difficulty: ClueDifficulty.medium,
                    ))
                .toList() ??
            [],
      );
      add(StoryFetched(story));
    } catch (e, st) {
      AppLogger.logError('OnlineRoomBloc._onFetchStoryRequested', e, stackTrace: st);
    } finally {
      // Reset flag whether fetch succeeded or failed so a retry is possible
      _isFetchingStory = false;
    }
  }

  void _onStoryFetched(StoryFetched event, Emitter<OnlineRoomState> emit) {
    emit(state.copyWith(story: event.story));
  }

  /// Connects to LiveKit for voice chat.
  ///
  /// Must be called OUTSIDE any ongoing emit() to avoid re-entrant add() calls
  /// that crash on Android 13+ when the mic-permission dialog fires mid-emit.
  /// Intentionally fire-and-forget (non-fatal on failure).
  Future<void> _connectToLiveKit(String roomId) async {
    try {
      final tokenData = await getLiveKitTokenUseCase(roomId);
      final token = tokenData['token'] as String;
      const liveKitUrl = String.fromEnvironment('LIVEKIT_URL', defaultValue: 'ws://localhost:7880');

      await liveKitService.connect(liveKitUrl, token);
      // Guard isClosed before dispatching so we never add to a closed BLoC
      if (!isClosed) add(const ToggleMicRequested(true));
    } catch (e) {
      AppLogger.logError('OnlineRoomBloc', 'LiveKit connection failed: $e');
      // LiveKit failure is non-fatal — user stays in room, just without voice.
    }
  }

  Future<void> _onCreateRoom(
    CreateRoomRequested event,
    Emitter<OnlineRoomState> emit,
  ) async {
    AppLogger.logBlocEvent('OnlineRoomBloc', 'CreateRoomRequested');
    emit(state.copyWith(status: OnlineRoomStatus.loading));

    try {
      final result = await createRoom(
        name: event.name,
        password: event.password,
        displayName: event.displayName,
      );
      final room = RoomModel(
        id: result['roomId'] as String,
        code: result['code'] as String,
        name: event.name,
        hostId: authService.currentUserId ?? '',
        status: RoomStatusX.fromString('waiting'),
        maxPlayers: 8,
      );

      emit(state.copyWith(
        status: OnlineRoomStatus.inLobby,
        room: room,
        isHost: true,
      ));

      analyticsService.logOnlineRoomCreated();

      // Subscribe to Realtime FIRST (no LiveKit inside)
      _subscribeToRealtime(room.id);

      // Connect to LiveKit AFTER the emit
      unawaited(_connectToLiveKit(room.id));

      if (event.storyId != null) {
        add(SelectGameRequested(
          storyId: event.storyId!,
          gameMode: 'standard',
        ));
      }
    } on AppErrorException catch (e, st) {
      AppLogger.logError('OnlineRoomBloc._onCreateRoom', e, stackTrace: st);
      emit(state.copyWith(
        status: OnlineRoomStatus.error,
        error: e.error,
      ));
    } catch (e, st) {
      AppLogger.logError('OnlineRoomBloc._onCreateRoom', e, stackTrace: st);
      emit(state.copyWith(
        status: OnlineRoomStatus.error,
        error: AppError('error_creating_room'),
      ));
    }
  }

  Future<void> _onJoinRoom(
    JoinRoomRequested event,
    Emitter<OnlineRoomState> emit,
  ) async {
    AppLogger.logBlocEvent('OnlineRoomBloc', 'JoinRoomRequested');
    emit(state.copyWith(status: OnlineRoomStatus.loading));

    try {
      final result = await joinRoom(
        code: event.code,
        password: event.password,
        displayName: event.displayName,
      );

      final roomDetails = result['roomDetails'] as Map<String, dynamic>;
      final room = RoomModel.fromJson(roomDetails);

      emit(state.copyWith(
        status: OnlineRoomStatus.inLobby,
        room: room,
        isHost: room.isHost(authService.currentUserId ?? ''),
      ));

      analyticsService.logOnlineRoomJoined();

      // Subscribe to Realtime FIRST (no LiveKit inside)
      _subscribeToRealtime(room.id);

      // Connect to LiveKit AFTER the emit — fire-and-forget, non-fatal.
      unawaited(_connectToLiveKit(room.id));
    } on AppErrorException catch (e, st) {
      AppLogger.logError('OnlineRoomBloc._onJoinRoom', e, stackTrace: st);
      emit(state.copyWith(
        status: OnlineRoomStatus.error,
        error: e.error,
      ));
    } catch (e, st) {
      AppLogger.logError('OnlineRoomBloc._onJoinRoom', e, stackTrace: st);
      emit(state.copyWith(
        status: OnlineRoomStatus.error,
        error: AppError('error_joining_room'),
      ));
    }
  }

  Future<void> _onLeaveRoom(
    LeaveRoomRequested event,
    Emitter<OnlineRoomState> emit,
  ) async {
    AppLogger.logBlocEvent('OnlineRoomBloc', 'LeaveRoomRequested');

    if (state.room == null) return;

    emit(state.copyWith(status: OnlineRoomStatus.loading));

    try {
      await leaveRoom(state.room!.id);
      await liveKitService.disconnect();
    } catch (e, st) {
      AppLogger.logError('OnlineRoomBloc._onLeaveRoom', e, stackTrace: st);
    } finally {
      // Always clean up and reset — even if the server call fails
      _cancelSubscriptions();
      _isFetchingStory = false;
      emit(const OnlineRoomState());
    }
  }

  Future<void> _onKickPlayer(KickPlayerRequested event, Emitter<OnlineRoomState> emit) async {
    if (state.room == null) return;
    try {
      await kickPlayerUseCase(roomId: state.room!.id, targetUserId: event.userId);
    } catch (e, st) {
      AppLogger.logError('OnlineRoomBloc._onKickPlayer', e, stackTrace: st);
    }
  }

  Future<void> _onSelectGame(SelectGameRequested event, Emitter<OnlineRoomState> emit) async {
    if (state.room == null) return;
    try {
      await selectGameUseCase(roomId: state.room!.id, storyId: event.storyId, gameMode: event.gameMode);
    } catch (e, st) {
      AppLogger.logError('OnlineRoomBloc._onSelectGame', e, stackTrace: st);
    }
  }

  Future<void> _onStartGame(StartGameRequested event, Emitter<OnlineRoomState> emit) async {
    if (state.room == null) return;
    try {
      await startGameUseCase(state.room!.id);
    } catch (e, st) {
      AppLogger.logError('OnlineRoomBloc._onStartGame', e, stackTrace: st);
      emit(state.copyWith(
        status: OnlineRoomStatus.error,
        error: AppError('error_starting_game'),
      ));
    }
  }

  Future<void> _onSubmitGameEvent(SubmitGameEventRequested event, Emitter<OnlineRoomState> emit) async {
    if (state.session == null) return;
    try {
      await submitGameEventUseCase(
        sessionId: state.session!.id,
        eventType: event.eventType,
        payload: event.payload,
      );
    } catch (e, st) {
      AppLogger.logError('OnlineRoomBloc._onSubmitGameEvent', e, stackTrace: st);
    }
  }

  Future<void> _onToggleMic(ToggleMicRequested event, Emitter<OnlineRoomState> emit) async {
    if (!liveKitService.isConnected) return;
    await liveKitService.enableMic(event.enable);
    emit(state.copyWith(isMicEnabled: event.enable));
  }
}
