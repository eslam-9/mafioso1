import '../entities/story.dart';

abstract class StoryRepository {
  Future<Story> getStory({
    required int suspectCount,
    required bool hasDetective,
    required String languageCode,
  });
}
