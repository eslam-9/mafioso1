abstract class OnlineRoomRepository {
  Future<Map<String, dynamic>> createRoom({
    required String name,
    String? password,
    String displayName = 'Host',
    int maxPlayers = 8,
  });

  Future<Map<String, dynamic>> joinRoom({
    required String code,
    String? password,
    String displayName = 'Player',
  });

  Future<void> leaveRoom(String roomId);

  Future<void> kickPlayer({
    required String roomId,
    required String targetUserId,
  });

  Future<void> selectGame({
    required String roomId,
    required String storyId,
    required String gameMode,
  });

  Future<String> startGame(String roomId);

  Future<void> submitGameEvent({
    required String sessionId,
    required String eventType,
    required Map<String, dynamic> payload,
  });

  Future<Map<String, dynamic>> getLiveKitToken(String roomId);

  Future<Map<String, dynamic>> getStoryById(String storyId);
}
