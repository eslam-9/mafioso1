import '../entities/played_story.dart';
import '../repositories/story_history_repository.dart';

class SavePlayedStoryUseCase {
  final StoryHistoryRepository repository;

  const SavePlayedStoryUseCase(this.repository);

  Future<void> call(PlayedStory story) async {
    return repository.savePlayedStory(story);
  }
}
