import '../repositories/online_room_repository.dart';

class SubmitGameEventUseCase {
  final OnlineRoomRepository repository;

  SubmitGameEventUseCase(this.repository);

  Future<void> call({
    required String sessionId,
    required String eventType,
    required Map<String, dynamic> payload,
  }) {
    return repository.submitGameEvent(
      sessionId: sessionId,
      eventType: eventType,
      payload: payload,
    );
  }
}
