import 'package:flutter_test/flutter_test.dart';
import 'package:mafioso/models/game_config.dart';
import 'package:mafioso/models/story.dart';
import 'package:mafioso/repositories/story_repository.dart';
import 'package:mafioso/services/connectivity_service.dart';
import 'package:mafioso/services/gemini_service.dart';
import 'package:mafioso/viewmodels/story_viewmodel.dart';

void main() {
  group('StoryViewModel', () {
    late StoryViewModel viewModel;

    Story createTestStory() {
      return Story(
        title: 'Test Story',
        intro: 'Test intro',
        crimeDescription: 'Test crime',
        suspects: [
          Suspect(name: 'Suspect A', suspiciousBehavior: 'Behavior A'),
        ],
        clues: [
          Clue(text: 'Clue 1', difficulty: ClueDifficulty.easy),
        ],
        twist: 'Test twist',
        killerName: 'Suspect A',
      );
    }

    GameConfig createConfig() {
      return GameConfig(
        mode: GameMode.withoutDetective,
        suspectCount: 4,
        playerNames: ['Alice', 'Bob', 'Charlie', 'David'],
      );
    }

    setUp(() {
      // Using real repository for now (mocks require build_runner setup)
      final connectivityService = ConnectivityService();
      final geminiService = GeminiService(apiKey: 'test-key');
      viewModel = StoryViewModel(
        storyRepository: StoryRepository(
          geminiService: geminiService,
          connectivityService: connectivityService,
        ),
      );
    });

    test('initial state should be initial', () {
      expect(viewModel.state, StoryState.initial);
      expect(viewModel.story, isNull);
      expect(viewModel.errorMessage, isNull);
    });

    test('reset should clear all state', () {
      viewModel.reset();

      expect(viewModel.state, StoryState.initial);
      expect(viewModel.story, isNull);
      expect(viewModel.errorMessage, isNull);
    });

    // Note: Full integration tests would require mocking the repository
    // which needs build_runner setup. These tests verify the basic structure.
  });
}

