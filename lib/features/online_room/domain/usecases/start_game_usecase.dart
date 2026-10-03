import '../repositories/online_room_repository.dart';

class StartGameUseCase {
  final OnlineRoomRepository repository;

  StartGameUseCase(this.repository);

  Future<String> call(String roomId) {
    return repository.startGame(roomId);
  }
}
