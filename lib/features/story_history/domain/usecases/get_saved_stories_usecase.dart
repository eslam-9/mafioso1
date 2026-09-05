import '../entities/played_story.dart';
import '../repositories/story_history_repository.dart';

class GetSavedStoriesUseCase {
  final StoryHistoryRepository repository;

  const GetSavedStoriesUseCase(this.repository);

  Future<List<PlayedStory>> call() async {
    return repository.getSavedStories();
  }
}
