import '../repositories/story_library_repository.dart';

class RateCommunityStoryUseCase {
  final StoryLibraryRepository repository;
  const RateCommunityStoryUseCase(this.repository);

  Future<void> call(String storyId, int rating, String deviceId) =>
      repository.rateStory(storyId, rating, deviceId);
}
