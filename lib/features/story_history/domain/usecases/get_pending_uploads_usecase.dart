import '../entities/played_story.dart';
import '../repositories/story_history_repository.dart';

class GetPendingUploadsUseCase {
  final StoryHistoryRepository repository;

  const GetPendingUploadsUseCase(this.repository);

  Future<List<PlayedStory>> call() async {
    return repository.getPendingUploads();
  }
}
