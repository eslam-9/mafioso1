import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mafioso/features/story/domain/usecases/get_community_fallback_story_usecase.dart';
import 'package:mafioso/features/story/domain/entities/story.dart';
import 'package:mafioso/features/story/domain/entities/clue.dart';
import 'package:mafioso/features/story/domain/entities/suspect.dart';
import 'package:mafioso/features/story_history/domain/entities/played_story.dart';
import 'package:mafioso/features/story_history/domain/repositories/story_history_repository.dart';
import 'package:mafioso/features/story_library/domain/entities/community_story.dart';
import 'package:mafioso/features/story_library/domain/repositories/story_library_repository.dart';
import 'package:mafioso/shared/utils/story_content_hasher.dart';

class _FakeStoryLibraryRepository implements StoryLibraryRepository {
  final List<List<CommunityStory>> pages;
  final List<Map<String, Object?>> calls = [];
  Object? error;

  _FakeStoryLibraryRepository(this.pages);

  @override
  Future<List<CommunityStory>> getCommunityStories({
    int page = 0,
    int limit = 20,
    String languageCode = 'en',
    int? playerCount,
  }) async {
    calls.add({
      'page': page,
      'limit': limit,
      'languageCode': languageCode,
      'playerCount': playerCount,
    });
    if (error != null) throw error!;
    if (page >= pages.length) return const [];
    return pages[page];
  }

  @override
  Future<String> uploadStory(
    Map<String, dynamic> storyJson,
    String deviceId,
    String languageCode,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> rateStory(String storyId, int rating, String deviceId) {
    throw UnimplementedError();
  }
}

class _FakeStoryHistoryRepository implements StoryHistoryRepository {
  final List<PlayedStory> saved;

  _FakeStoryHistoryRepository(this.saved);

  @override
  Future<List<PlayedStory>> getSavedStories() async => saved;

  @override
  Future<void> savePlayedStory(PlayedStory story) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteStory(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> rateStory(String id, int rating) {
    throw UnimplementedError();
  }

  @override
  Future<List<PlayedStory>> getPendingUploads() {
    throw UnimplementedError();
  }

  @override
  Future<void> markAsUploaded(String id) {
    throw UnimplementedError();
  }
}

CommunityStory _communityStory({
  required String id,
  required String title,
  bool parseable = true,
}) {
  final storyJson = parseable
      ? <String, dynamic>{
          'title': title,
          'intro': 'Intro $title',
          'crimeDescription': 'Crime $title',
          'suspects': [
            {'name': 'Alice', 'suspiciousBehavior': 'Seen near the library.'},
          ],
          'clues': [
            {'text': 'A muddy footprint.', 'difficulty': 'easy'},
          ],
          'twist': 'Twist $title',
          'killerName': 'Alice',
        }
      : <String, dynamic>{
          'title': title,
          'intro': 'Intro $title',
          'crimeDescription': 'Crime $title',
          'suspects': <dynamic>[],
          'clues': <dynamic>[],
          'twist': 'Twist $title',
          'killerName': 'Alice',
        };

  return CommunityStory(
    id: id,
    contentHash: StoryContentHasher.hash(
      title: storyJson['title'] as String,
      intro: storyJson['intro'] as String,
      crimeDescription: storyJson['crimeDescription'] as String,
      killerName: storyJson['killerName'] as String,
      twist: storyJson['twist'] as String,
      languageCode: 'en',
    ),
    title: storyJson['title'] as String,
    intro: storyJson['intro'] as String,
    crimeDescription: storyJson['crimeDescription'] as String,
    twist: storyJson['twist'] as String,
    killerName: storyJson['killerName'] as String,
    storyJson: storyJson,
    bayesianRating: 4.5,
    totalVotes: 10,
    uploadedAt: DateTime(2026, 1, 1),
    suspectCount: 1,
  );
}

Story _story(String title) => Story(
      title: title,
      intro: 'Intro $title',
      crimeDescription: 'Crime $title',
      suspects: const [
        Suspect(
          name: 'Alice',
          suspiciousBehavior: 'Seen near the library.',
        ),
      ],
      clues: const [
        Clue(text: 'A muddy footprint.', difficulty: ClueDifficulty.easy),
      ],
      twist: 'Twist $title',
      killerName: 'Alice',
    );

void main() {
  group('GetCommunityFallbackStoryUseCase', () {
    test('returns a random unplayed story from the community library', () async {
      final library = _FakeStoryLibraryRepository([
        [
          _communityStory(id: '1', title: 'Played Story'),
          _communityStory(id: '2', title: 'Candidate A'),
          _communityStory(id: '3', title: 'Candidate B'),
        ],
      ]);

      final useCase = GetCommunityFallbackStoryUseCase(
        storyLibraryRepository: library,
        storyHistoryRepository: _FakeStoryHistoryRepository([
          PlayedStory(
            id: 'local_1',
            story: _story('Played Story'),
            languageCode: 'en',
            playedAt: DateTime(2026, 1, 2),
          ),
        ]),
        random: Random(42),
      );

      final result = await useCase(suspectCount: 1, languageCode: 'en');

      expect(result, isNotNull);
      expect(
        result!.title,
        anyOf('Candidate A', 'Candidate B'),
        reason: 'played story must be excluded',
      );
    });

    test('requests top-rated stories for the requested player count and language',
        () async {
      final library = _FakeStoryLibraryRepository([
        [_communityStory(id: '1', title: 'Candidate')],
      ]);

      final useCase = GetCommunityFallbackStoryUseCase(
        storyLibraryRepository: library,
        storyHistoryRepository: _FakeStoryHistoryRepository([]),
        random: Random(1),
      );

      final result = await useCase(suspectCount: 3, languageCode: 'ar');

      expect(result, isNotNull);
      expect(library.calls, isNotEmpty);
      expect(library.calls.first['playerCount'], 3);
      expect(library.calls.first['languageCode'], 'ar');
    });

    test('returns null when every community story was already played', () async {
      final library = _FakeStoryLibraryRepository([
        [
          _communityStory(id: '1', title: 'Played Once'),
          _communityStory(id: '2', title: 'Played Twice'),
        ],
      ]);

      final useCase = GetCommunityFallbackStoryUseCase(
        storyLibraryRepository: library,
        storyHistoryRepository: _FakeStoryHistoryRepository([
          PlayedStory(
            id: 'local_1',
            story: _story('Played Once'),
            languageCode: 'en',
            playedAt: DateTime(2026, 1, 2),
          ),
          PlayedStory(
            id: 'local_2',
            story: _story('Played Twice'),
            languageCode: 'en',
            playedAt: DateTime(2026, 1, 3),
          ),
        ]),
        random: Random(1),
      );

      final result = await useCase(suspectCount: 1, languageCode: 'en');

      expect(result, isNull);
    });

    test('returns null when the community library is empty', () async {
      final library = _FakeStoryLibraryRepository([]);

      final useCase = GetCommunityFallbackStoryUseCase(
        storyLibraryRepository: library,
        storyHistoryRepository: _FakeStoryHistoryRepository([]),
        random: Random(1),
      );

      final result = await useCase(suspectCount: 1, languageCode: 'en');

      expect(result, isNull);
    });

    test('returns null when the community library fetch fails', () async {
      final library = _FakeStoryLibraryRepository([])..error = Exception('boom');

      final useCase = GetCommunityFallbackStoryUseCase(
        storyLibraryRepository: library,
        storyHistoryRepository: _FakeStoryHistoryRepository([]),
        random: Random(1),
      );

      final result = await useCase(suspectCount: 1, languageCode: 'en');

      expect(result, isNull);
    });

    test('skips stories that cannot be parsed into a Story', () async {
      final library = _FakeStoryLibraryRepository([
        [
          _communityStory(id: 'bad', title: 'Broken Story', parseable: false),
          _communityStory(id: 'good', title: 'Good Story'),
        ],
      ]);

      final useCase = GetCommunityFallbackStoryUseCase(
        storyLibraryRepository: library,
        storyHistoryRepository: _FakeStoryHistoryRepository([]),
        random: Random(1),
      );

      final result = await useCase(suspectCount: 1, languageCode: 'en');

      expect(result, isNotNull);
      expect(result!.title, 'Good Story');
    });

    test('stops scanning after the max page count', () async {
      final manyPages = List.generate(
        10,
        (i) => [_communityStory(id: 'p$i', title: 'Story $i')],
      );
      final library = _FakeStoryLibraryRepository(manyPages);

      final useCase = GetCommunityFallbackStoryUseCase(
        storyLibraryRepository: library,
        storyHistoryRepository: _FakeStoryHistoryRepository([]),
        random: Random(1),
      );

      final result = await useCase(suspectCount: 1, languageCode: 'en');

      expect(result, isNotNull);
      expect(library.calls.length, 5, reason: 'cap is 5 pages');
    });
  });
}
