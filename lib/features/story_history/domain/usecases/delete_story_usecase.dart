import '../repositories/story_history_repository.dart';

class DeleteStoryUseCase {
  final StoryHistoryRepository repository;

  const DeleteStoryUseCase(this.repository);

  Future<void> call(String id) async {
    return repository.deleteStory(id);
  }
}
