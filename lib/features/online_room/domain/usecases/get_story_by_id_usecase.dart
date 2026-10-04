import '../repositories/online_room_repository.dart';

class GetStoryByIdUseCase {
  final OnlineRoomRepository repository;

  GetStoryByIdUseCase(this.repository);

  Future<Map<String, dynamic>> call(String storyId) {
    return repository.getStoryById(storyId);
  }
}
