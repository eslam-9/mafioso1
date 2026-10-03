import '../repositories/online_room_repository.dart';

class CreateRoomUseCase {
  final OnlineRoomRepository repository;

  CreateRoomUseCase(this.repository);

  Future<Map<String, dynamic>> call({
    required String name,
    String? password,
    String displayName = 'Host',
  }) {
    return repository.createRoom(name: name, password: password, displayName: displayName);
  }
}
