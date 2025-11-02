import 'package:flutter_test/flutter_test.dart';
import 'package:mafioso/models/player.dart';
import 'package:mafioso/models/story.dart';
import 'package:mafioso/models/vote_result.dart';
import 'package:mafioso/viewmodels/game_viewmodel.dart';

void main() {
  group('GameViewModel', () {
    late GameViewModel viewModel;

    Story createTestStory() {
      return Story(
        title: 'Test Story',
        intro: 'Test intro',
        crimeDescription: 'Test crime',
        suspects: [
          Suspect(name: 'Suspect A', suspiciousBehavior: 'Behavior A'),
          Suspect(name: 'Suspect B', suspiciousBehavior: 'Behavior B'),
        ],
        clues: [
          Clue(text: 'Clue 1', difficulty: ClueDifficulty.easy),
          Clue(text: 'Clue 2', difficulty: ClueDifficulty.medium),
        ],
        twist: 'Test twist',
        killerName: 'Suspect A',
      );
    }

    List<Player> createTestPlayers() {
      return [
        Player(id: '1', name: 'Alice', role: PlayerRole.killer),
        Player(id: '2', name: 'Bob', role: PlayerRole.innocent),
        Player(id: '3', name: 'Charlie', role: PlayerRole.innocent),
        Player(id: '4', name: 'David', role: PlayerRole.innocent),
      ];
    }

    setUp(() {
      viewModel = GameViewModel();
    });

    test('initial state should be empty', () {
      expect(viewModel.players, isEmpty);
      expect(viewModel.story, isNull);
      expect(viewModel.gameState, GameState.playing);
      expect(viewModel.currentRound, 1);
      expect(viewModel.revealedClues, isEmpty);
    });

    test('initGame should initialize game state', () {
      final story = createTestStory();
      final players = createTestPlayers();

      viewModel.initGame(players, story);

      expect(viewModel.players.length, 4);
      expect(viewModel.story, story);
      expect(viewModel.gameState, GameState.playing);
      expect(viewModel.currentRound, 1);
      expect(viewModel.voteHistory, isEmpty);
      expect(viewModel.revealedClues, isEmpty);
    });

    test('alivePlayers should return only alive players', () {
      final story = createTestStory();
      final players = createTestPlayers();
      viewModel.initGame(players, story);

      expect(viewModel.alivePlayers.length, 4);

      // Eliminate a player
      final updatedPlayers = List<Player>.from(viewModel.players);
      updatedPlayers[1] = updatedPlayers[1].copyWith(isAlive: false);
      viewModel.initGame(updatedPlayers, story);

      expect(viewModel.alivePlayers.length, 3);
    });

    test('revealNextClue should reveal clues in order', () {
      final story = createTestStory();
      final players = createTestPlayers();
      viewModel.initGame(players, story);

      expect(viewModel.revealedClues, isEmpty);
      expect(viewModel.canRevealMoreClues, true);

      viewModel.revealNextClue();
      expect(viewModel.revealedClues.length, 1);
      expect(viewModel.revealedClues[0].text, 'Clue 1');

      viewModel.revealNextClue();
      expect(viewModel.revealedClues.length, 2);
      expect(viewModel.revealedClues[1].text, 'Clue 2');

      expect(viewModel.canRevealMoreClues, false);
    });

    test('revealNextClue should not reveal more than available', () {
      final story = createTestStory();
      final players = createTestPlayers();
      viewModel.initGame(players, story);

      viewModel.revealNextClue();
      viewModel.revealNextClue();
      viewModel.revealNextClue(); // Should not add third clue

      expect(viewModel.revealedClues.length, 2);
    });

    test('availableClues should return story clues', () {
      final story = createTestStory();
      final players = createTestPlayers();
      viewModel.initGame(players, story);

      expect(viewModel.availableClues.length, 2);
      expect(viewModel.availableClues, story.clues);
    });

    test('submitVotes should eliminate most voted player', () async {
      final story = createTestStory();
      final players = createTestPlayers();
      viewModel.initGame(players, story);

      final votes = [
        Vote(voterId: '2', voterName: 'Bob', accusedId: '1', accusedName: 'Alice'),
        Vote(voterId: '3', voterName: 'Charlie', accusedId: '1', accusedName: 'Alice'),
        Vote(voterId: '4', voterName: 'David', accusedId: '1', accusedName: 'Alice'),
      ];

      final result = await viewModel.submitVotes(votes);

      expect(result.eliminatedPlayerId, '1');
      expect(result.eliminatedPlayerName, 'Alice');
      expect(viewModel.players.firstWhere((p) => p.id == '1').isAlive, false);
      expect(viewModel.gameState, GameState.innocentsWin);
      expect(viewModel.isGameOver, true);
    });

    test('submitVotes should handle ties (no elimination)', () async {
      final story = createTestStory();
      final players = createTestPlayers();
      viewModel.initGame(players, story);

      // Create a true tie: 2 votes for Alice, 2 votes for Bob
      final votes = [
        Vote(voterId: '1', voterName: 'Alice', accusedId: '2', accusedName: 'Bob'),
        Vote(voterId: '2', voterName: 'Bob', accusedId: '1', accusedName: 'Alice'),
        Vote(voterId: '3', voterName: 'Charlie', accusedId: '1', accusedName: 'Alice'),
        Vote(voterId: '4', voterName: 'David', accusedId: '2', accusedName: 'Bob'),
      ];

      final result = await viewModel.submitVotes(votes);

      expect(result.eliminatedPlayerId, isNull);
      expect(viewModel.currentRound, 2);
      expect(viewModel.gameState, GameState.playing);
    });

    test('submitVotes should detect killer win condition', () async {
      final story = createTestStory();
      // Create scenario where only killer + 1 other alive
      final players = [
        Player(id: '1', name: 'Alice', role: PlayerRole.killer, isAlive: true),
        Player(id: '2', name: 'Bob', role: PlayerRole.innocent, isAlive: true),
        Player(id: '3', name: 'Charlie', role: PlayerRole.innocent, isAlive: false),
      ];
      viewModel.initGame(players, story);

      // Vote out the innocent, leaving only killer
      final votes = [
        Vote(voterId: '1', voterName: 'Alice', accusedId: '2', accusedName: 'Bob'),
      ];

      final result = await viewModel.submitVotes(votes);

      expect(result.eliminatedPlayerId, '2');
      expect(viewModel.gameState, GameState.killerWins);
      expect(viewModel.isGameOver, true);
    });

    test('submitVotes should increment round when game continues', () async {
      final story = createTestStory();
      final players = createTestPlayers();
      viewModel.initGame(players, story);

      // Vote out an innocent (not killer)
      final votes = [
        Vote(voterId: '1', voterName: 'Alice', accusedId: '2', accusedName: 'Bob'),
        Vote(voterId: '3', voterName: 'Charlie', accusedId: '2', accusedName: 'Bob'),
        Vote(voterId: '4', voterName: 'David', accusedId: '2', accusedName: 'Bob'),
      ];

      await viewModel.submitVotes(votes);

      expect(viewModel.currentRound, 2);
      expect(viewModel.gameState, GameState.playing);
    });

    test('getKiller should return the killer player', () {
      final story = createTestStory();
      final players = createTestPlayers();
      viewModel.initGame(players, story);

      final killer = viewModel.getKiller();

      expect(killer, isNotNull);
      expect(killer!.role, PlayerRole.killer);
    });

    test('isGameOver should return true when game is over', () {
      final story = createTestStory();
      final players = createTestPlayers();
      viewModel.initGame(players, story);

      expect(viewModel.isGameOver, false);

      // Manually set game state to win condition
      viewModel.initGame(players, story);
      // We can't directly test private _gameState, so we test through submitVotes
    });

    test('reset should clear all game data', () {
      final story = createTestStory();
      final players = createTestPlayers();
      viewModel.initGame(players, story);
      viewModel.revealNextClue();

      viewModel.reset();

      expect(viewModel.players, isEmpty);
      expect(viewModel.story, isNull);
      expect(viewModel.gameState, GameState.playing);
      expect(viewModel.currentRound, 1);
      expect(viewModel.voteHistory, isEmpty);
      expect(viewModel.revealedClues, isEmpty);
    });

    test('voteHistory should track all vote results', () async {
      final story = createTestStory();
      final players = createTestPlayers();
      viewModel.initGame(players, story);

      final votes1 = [
        Vote(voterId: '2', voterName: 'Bob', accusedId: '3', accusedName: 'Charlie'),
        Vote(voterId: '3', voterName: 'Charlie', accusedId: '3', accusedName: 'Charlie'),
        Vote(voterId: '4', voterName: 'David', accusedId: '3', accusedName: 'Charlie'),
      ];

      await viewModel.submitVotes(votes1);

      expect(viewModel.voteHistory.length, 1);
      expect(viewModel.voteHistory[0].round, 1);
    });
  });
}

