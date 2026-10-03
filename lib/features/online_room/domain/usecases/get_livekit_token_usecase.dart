import '../repositories/online_room_repository.dart';

class GetLiveKitTokenUseCase {
  final OnlineRoomRepository repository;

  GetLiveKitTokenUseCase(this.repository);

  Future<Map<String, dynamic>> call(String roomId) {
    return repository.getLiveKitToken(roomId);
  }
}
