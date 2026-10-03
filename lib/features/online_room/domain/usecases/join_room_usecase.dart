import '../repositories/online_room_repository.dart';

class JoinRoomUseCase {
  final OnlineRoomRepository repository;

  JoinRoomUseCase(this.repository);

  Future<Map<String, dynamic>> call({
    required String code,
    String? password,
    required String displayName,
  }) {
    return repository.joinRoom(code: code, password: password, displayName: displayName);
  }
}
