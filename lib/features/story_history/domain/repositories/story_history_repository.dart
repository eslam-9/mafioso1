import '../entities/played_story.dart';

abstract class StoryHistoryRepository {
  Future<List<PlayedStory>> getSavedStories();
  Future<void> savePlayedStory(PlayedStory story);
  Future<void> rateStory(String id, int rating);
  Future<List<PlayedStory>> getPendingUploads();
  Future<void> markAsUploaded(String id);
}
