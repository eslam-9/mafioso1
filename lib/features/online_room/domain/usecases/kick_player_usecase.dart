import '../repositories/online_room_repository.dart';

class KickPlayerUseCase {
  final OnlineRoomRepository repository;

  KickPlayerUseCase(this.repository);

  Future<void> call({
    required String roomId,
    required String targetUserId,
  }) {
    return repository.kickPlayer(roomId: roomId, targetUserId: targetUserId);
  }
}
