import '../repositories/story_library_repository.dart';

class UploadStoryUseCase {
  final StoryLibraryRepository repository;
  const UploadStoryUseCase(this.repository);

  Future<String> call(
    Map<String, dynamic> storyJson,
    String deviceId,
    String languageCode,
  ) => repository.uploadStory(storyJson, deviceId, languageCode);
}
