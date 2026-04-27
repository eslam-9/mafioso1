import '../../domain/entities/community_story.dart';
import '../../domain/repositories/story_library_repository.dart';
import '../datasources/story_library_remote_datasource.dart';

class StoryLibraryRepositoryImpl implements StoryLibraryRepository {
  final StoryLibraryRemoteDataSource remoteDataSource;

  const StoryLibraryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CommunityStory>> getCommunityStories({
    int page = 0,
    int limit = 20,
    String languageCode = 'en',
    int? playerCount,
  }) async {
    return remoteDataSource.getCommunityStories(
      page: page,
      limit: limit,
      languageCode: languageCode,
      playerCount: playerCount,
    );
  }

  @override
  Future<String> uploadStory(
    Map<String, dynamic> storyJson,
    String deviceId,
    String languageCode,
  ) async {
    return remoteDataSource.uploadStory(storyJson, deviceId, languageCode);
  }

  @override
  Future<void> rateStory(String storyId, int rating, String deviceId) async {
    return remoteDataSource.rateStory(storyId, rating, deviceId);
  }
}
