import 'dart:math';

import '../../../../core/utils/logger.dart';
import '../../../story_history/domain/repositories/story_history_repository.dart';
import '../../../story_library/domain/entities/community_story.dart';
import '../../../story_library/domain/repositories/story_library_repository.dart';
import '../../../../shared/utils/story_content_hasher.dart';
import '../entities/story.dart';
import '../../data/models/story_model.dart';

/// Selects a random, high-rated, unplayed-on-this-device story from the
/// community library. Used as a fallback when AI story generation fails.
class GetCommunityFallbackStoryUseCase {
  final StoryLibraryRepository storyLibraryRepository;
  final StoryHistoryRepository storyHistoryRepository;
  final Random _random;

  static const int _pageSize = 20;
  static const int _maxPages = 5;

  GetCommunityFallbackStoryUseCase({
    required this.storyLibraryRepository,
    required this.storyHistoryRepository,
    Random? random,
  }) : _random = random ?? Random();

  /// Returns a random community story, or null when no suitable story exists.
  Future<Story?> call({
    required int suspectCount,
    required String languageCode,
  }) async {
    final playedHashes = await _loadPlayedContentHashes();
    final candidates = <StoryModel>[];

    for (var page = 0; page < _maxPages; page++) {
      final List<CommunityStory> stories;
      try {
        stories = await storyLibraryRepository.getCommunityStories(
          page: page,
          limit: _pageSize,
          languageCode: languageCode,
          playerCount: suspectCount,
        );
      } catch (e) {
        AppLogger.logError('GetCommunityFallbackStoryUseCase', e);
        break;
      }

      if (stories.isEmpty) break;

      for (final story in stories) {
        if (playedHashes.contains(story.contentHash)) continue;

        try {
          candidates.add(StoryModel.fromJson(story.storyJson));
        } catch (e) {
          AppLogger.logError(
            'GetCommunityFallbackStoryUseCase: skip unparseable story',
            e,
          );
        }
      }
    }

    if (candidates.isEmpty) return null;

    final picked = candidates[_random.nextInt(candidates.length)];
    AppLogger.logInfo(
      'GetCommunityFallbackStoryUseCase: picked "${picked.title}" '
      'from ${candidates.length} unplayed candidates',
    );
    return picked;
  }

  Future<Set<String>> _loadPlayedContentHashes() async {
    final savedStories = await storyHistoryRepository.getSavedStories();
    return savedStories
        .map(
          (played) => StoryContentHasher.hash(
            title: played.story.title,
            intro: played.story.intro,
            crimeDescription: played.story.crimeDescription,
            killerName: played.story.killerName,
            twist: played.story.twist,
            languageCode: played.languageCode,
          ),
        )
        .toSet();
  }
}
