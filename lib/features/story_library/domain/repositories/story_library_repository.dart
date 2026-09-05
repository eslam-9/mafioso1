import '../entities/community_story.dart';

abstract class StoryLibraryRepository {
  /// Fetches paginated stories from the community library, ordered by rating.
  Future<List<CommunityStory>> getCommunityStories({
    int page = 0,
    int limit = 20,
  });

  /// Uploads a story to the community library. Returns the story's DB id.
  /// If the story already exists (same content_hash), returns its existing id.
  Future<String> uploadStory(Map<String, dynamic> storyJson, String deviceId);

  /// Submits a rating for a story, keyed by the device's anonymous id.
  Future<void> rateStory(String storyId, int rating, String deviceId);
}
