import '../../domain/repositories/online_room_repository.dart';
import '../datasources/online_room_remote_datasource.dart';

class OnlineRoomRepositoryImpl implements OnlineRoomRepository {
  final OnlineRoomRemoteDataSource remoteDataSource;

  OnlineRoomRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Map<String, dynamic>> createRoom({
    required String name,
    String? password,
    String displayName = 'Host',
    int maxPlayers = 8,
  }) {
    return remoteDataSource.createRoom(
      name: name,
      password: password,
      displayName: displayName,
      maxPlayers: maxPlayers,
    );
  }

  @override
  Future<Map<String, dynamic>> joinRoom({
    required String code,
    String? password,
    String displayName = 'Player',
  }) {
    return remoteDataSource.joinRoom(
      code: code,
      password: password,
      displayName: displayName,
    );
  }

  @override
  Future<void> leaveRoom(String roomId) {
    return remoteDataSource.leaveRoom(roomId);
  }

  @override
  Future<void> kickPlayer({
    required String roomId,
    required String targetUserId,
  }) {
    return remoteDataSource.kickPlayer(
      roomId: roomId,
      targetUserId: targetUserId,
    );
  }

  @override
  Future<void> selectGame({
    required String roomId,
    required String storyId,
    required String gameMode,
  }) {
    return remoteDataSource.selectGame(
      roomId: roomId,
      storyId: storyId,
      gameMode: gameMode,
    );
  }

  @override
  Future<String> startGame(String roomId) {
    return remoteDataSource.startGame(roomId);
  }

  @override
  Future<void> submitGameEvent({
    required String sessionId,
    required String eventType,
    required Map<String, dynamic> payload,
  }) {
    return remoteDataSource.submitGameEvent(
      sessionId: sessionId,
      eventType: eventType,
      payload: payload,
    );
  }

  @override
  Future<Map<String, dynamic>> getLiveKitToken(String roomId) {
    return remoteDataSource.getLiveKitToken(roomId);
  }

  @override
  Future<Map<String, dynamic>> getStoryById(String storyId) {
    return remoteDataSource.getStoryById(storyId);
  }
}
