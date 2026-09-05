import '../entities/community_story.dart';
import '../repositories/story_library_repository.dart';

class GetCommunityStoriesUseCase {
  final StoryLibraryRepository repository;
  const GetCommunityStoriesUseCase(this.repository);

  Future<List<CommunityStory>> call({int page = 0}) =>
      repository.getCommunityStories(page: page);
}
