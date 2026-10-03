import '../repositories/online_room_repository.dart';

class SelectGameUseCase {
  final OnlineRoomRepository repository;

  SelectGameUseCase(this.repository);

  Future<void> call({
    required String roomId,
    required String storyId,
    required String gameMode,
  }) {
    return repository.selectGame(roomId: roomId, storyId: storyId, gameMode: gameMode);
  }
}
