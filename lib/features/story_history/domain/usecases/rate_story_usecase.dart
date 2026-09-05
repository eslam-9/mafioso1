import '../repositories/story_history_repository.dart';

class RateStoryUseCase {
  final StoryHistoryRepository repository;

  const RateStoryUseCase(this.repository);

  Future<void> call(String id, int rating) async {
    return repository.rateStory(id, rating);
  }
}
