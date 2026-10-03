import '../repositories/online_room_repository.dart';

class LeaveRoomUseCase {
  final OnlineRoomRepository repository;

  LeaveRoomUseCase(this.repository);

  Future<void> call(String roomId) {
    return repository.leaveRoom(roomId);
  }
}
