import '../repositories/story_history_repository.dart';

class MarkAsUploadedUseCase {
  final StoryHistoryRepository repository;

  const MarkAsUploadedUseCase(this.repository);

  Future<void> call(String id) async {
    return repository.markAsUploaded(id);
  }
}
