import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/errors/app_error_exception.dart';
import '../../../../core/utils/logger.dart';

class OnlineRoomRemoteDataSource {
  final SupabaseClient supabase;

  OnlineRoomRemoteDataSource(this.supabase);

  Future<Map<String, dynamic>> createRoom({
    required String name,
    String? password,
    String displayName = 'Player',
    int maxPlayers = 8,
  }) async {
    try {
      if (supabase.auth.currentSession == null) {
        throw AppErrorException(AppError('User is not authenticated! Please ensure Anonymous Sign-In is enabled in your Supabase Dashboard (Authentication -> Providers -> Anonymous).'));
      }
      AppLogger.logApiCall('functions.invoke', params: {'name': 'create-room'});
      final response = await supabase.functions.invoke(
        'create-room',
        body: {
          'name': name,
          'password': password,
          'displayName': displayName,
          'maxPlayers': maxPlayers,
        },
      );
      
      if (response.status != 200) {
        throw AppErrorException(AppError('error_creating_room'));
      }
      
      return response.data as Map<String, dynamic>;
    } on FunctionException catch (e, st) {
      AppLogger.logError('FunctionException in createRoom', e, stackTrace: st);
      AppLogger.logInfo('HTTP Status: ${e.status}');
      AppLogger.logInfo('Response Details: ${e.details}');
      throw AppErrorException(AppError('error_creating_room: ${e.details}'));
    } catch (e, st) {
      AppLogger.logError('OnlineRoomRemoteDataSource.createRoom', e, stackTrace: st);
      if (e is AppErrorException) rethrow;
      throw AppErrorException(AppError('error_creating_room'));
    }
  }

  Future<Map<String, dynamic>> joinRoom({
    required String code,
    String? password,
    String displayName = 'Player',
  }) async {
    try {
      if (supabase.auth.currentSession == null) {
        throw AppErrorException(AppError('User is not authenticated.'));
      }
      AppLogger.logApiCall('functions.invoke', params: {'name': 'join-room'});
      final response = await supabase.functions.invoke(
        'join-room',
        body: {
          'code': code,
          'password': password,
          'displayName': displayName,
        },
      );

      if (response.status != 200) {
        final errorMsg = response.data['error']?.toString().toLowerCase() ?? '';
        if (errorMsg.contains('invalid password')) {
          throw AppErrorException(AppError('error_incorrect_password'));
        }
        if (errorMsg.contains('not found')) {
          throw AppErrorException(AppError('error_room_not_found'));
        }
        throw AppErrorException(AppError('error_joining_room'));
      }

      return response.data as Map<String, dynamic>;
    } catch (e, st) {
      AppLogger.logError('OnlineRoomRemoteDataSource.joinRoom', e, stackTrace: st);
      if (e is AppErrorException) rethrow;
      throw AppErrorException(AppError('error_joining_room'));
    }
  }

  Future<void> leaveRoom(String roomId) async {
    try {
      AppLogger.logApiCall('functions.invoke', params: {'name': 'leave-room'});
      await supabase.functions.invoke(
        'leave-room',
        body: {'roomId': roomId},
      );
    } catch (e, st) {
      AppLogger.logError('OnlineRoomRemoteDataSource', e, stackTrace: st);
      throw AppErrorException(AppError('error_leaving_room'));
    }
  }

  Future<void> kickPlayer({
    required String roomId,
    required String targetUserId,
  }) async {
    try {
      AppLogger.logApiCall('functions.invoke', params: {'name': 'kick-player'});
      await supabase.functions.invoke(
        'kick-player',
        body: {
          'roomId': roomId,
          'targetUserId': targetUserId,
        },
      );
    } catch (e, st) {
      AppLogger.logError('OnlineRoomRemoteDataSource', e, stackTrace: st);
      throw AppErrorException(AppError('error_kicking_player'));
    }
  }

  Future<void> selectGame({
    required String roomId,
    required String storyId,
    required String gameMode,
  }) async {
    try {
      AppLogger.logApiCall('functions.invoke', params: {'name': 'select-game'});
      await supabase.functions.invoke(
        'select-game',
        body: {
          'roomId': roomId,
          'storyId': storyId,
          'gameMode': gameMode,
        },
      );
    } catch (e, st) {
      AppLogger.logError('OnlineRoomRemoteDataSource', e, stackTrace: st);
      throw AppErrorException(AppError('error_selecting_game'));
    }
  }

  Future<String> startGame(String roomId) async {
    try {
      AppLogger.logApiCall('functions.invoke', params: {'name': 'start-game'});
      final response = await supabase.functions.invoke(
        'start-game',
        body: {'roomId': roomId},
      );

      if (response.status != 200) {
        throw AppErrorException(AppError('error_starting_game'));
      }

      return response.data['sessionId'] as String;
    } catch (e, st) {
      AppLogger.logError('OnlineRoomRemoteDataSource', e, stackTrace: st);
      if (e is AppErrorException) rethrow;
      throw AppErrorException(AppError('error_starting_game'));
    }
  }

  Future<void> submitGameEvent({
    required String sessionId,
    required String eventType,
    required Map<String, dynamic> payload,
  }) async {
    try {
      AppLogger.logApiCall('functions.invoke', params: {'name': 'submit-game-event'});
      await supabase.functions.invoke(
        'submit-game-event',
        body: {
          'sessionId': sessionId,
          'eventType': eventType,
          'payload': payload,
        },
      );
    } catch (e, st) {
      AppLogger.logError('OnlineRoomRemoteDataSource', e, stackTrace: st);
      throw AppErrorException(AppError('error_submitting_event'));
    }
  }

  Future<Map<String, dynamic>> getLiveKitToken(String roomId) async {
    try {
      AppLogger.logApiCall('functions.invoke', params: {'name': 'livekit-token'});
      final response = await supabase.functions.invoke(
        'livekit-token',
        body: {'roomId': roomId},
      );

      if (response.status != 200) {
        throw AppErrorException(AppError('error_getting_livekit_token'));
      }

      return response.data as Map<String, dynamic>;
    } catch (e, st) {
      AppLogger.logError('OnlineRoomRemoteDataSource', e, stackTrace: st);
      if (e is AppErrorException) rethrow;
      throw AppErrorException(AppError('error_getting_livekit_token'));
    }
  }

  Future<Map<String, dynamic>> getStoryById(String storyId) async {
    try {
      final response = await supabase
          .from('community_stories')
          .select('story_json')
          .eq('id', storyId)
          .single();
      
      final rawJson = response['story_json'];
      if (rawJson is String) {
        return jsonDecode(rawJson) as Map<String, dynamic>;
      }
      return rawJson as Map<String, dynamic>;
    } catch (e, st) {
      AppLogger.logError('OnlineRoomRemoteDataSource.getStoryById', e, stackTrace: st);
      throw AppErrorException(AppError('error_fetching_story'));
    }
  }
}
