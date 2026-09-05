import '../../domain/entities/played_story.dart';
import '../../domain/repositories/story_history_repository.dart';
import '../datasources/story_history_local_datasource.dart';

class StoryHistoryRepositoryImpl implements StoryHistoryRepository {
  final StoryHistoryLocalDataSource localDataSource;

  StoryHistoryRepositoryImpl({required this.localDataSource});

  @override
  Future<List<PlayedStory>> getSavedStories() async {
    return await localDataSource.getSavedStories();
  }

  @override
  Future<void> savePlayedStory(PlayedStory story) async {
    await localDataSource.savePlayedStory(story);
  }

  @override
  Future<void> rateStory(String id, int rating) async {
    await localDataSource.rateStory(id, rating);
  }

  @override
  Future<List<PlayedStory>> getPendingUploads() async {
    return await localDataSource.getPendingUploads();
  }

  @override
  Future<void> markAsUploaded(String id) async {
    await localDataSource.markAsUploaded(id);
  }
}
