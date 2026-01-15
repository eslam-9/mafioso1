import '../entities/story.dart';
import '../repositories/story_repository.dart';

class GenerateStoryUseCase {
  final StoryRepository repository;

  GenerateStoryUseCase(this.repository);

  Future<Story> call({
    required int suspectCount,
    required bool hasDetective,
    required String languageCode,
  }) async {
    return await repository.getStory(
      suspectCount: suspectCount,
      hasDetective: hasDetective,
      languageCode: languageCode,
    );
  }
}
