import 'package:flutter_test/flutter_test.dart';
import 'package:mafioso/models/game_config.dart';
import 'package:mafioso/viewmodels/game_setup_viewmodel.dart';

void main() {
  group('GameSetupViewModel', () {
    late GameSetupViewModel viewModel;

    setUp(() {
      viewModel = GameSetupViewModel();
    });

    test('initial state should be without detective mode', () {
      expect(viewModel.selectedMode, GameMode.withoutDetective);
      expect(viewModel.suspectCount, 4);
      expect(viewModel.playerNames, isEmpty);
    });

    test('setMode should update mode and notify listeners', () {
      bool notified = false;
      viewModel.addListener(() {
        notified = true;
      });

      viewModel.setMode(GameMode.withDetective);

      expect(viewModel.selectedMode, GameMode.withDetective);
      expect(notified, true);
    });

    test('setMode should update player names list size', () {
      viewModel.setMode(GameMode.withDetective);
      expect(viewModel.totalPlayers, 5); // 4 suspects + 1 detective

      viewModel.setMode(GameMode.withoutDetective);
      expect(viewModel.totalPlayers, 4); // 4 suspects only
    });

    test('setSuspectCount should only accept valid range (4-6)', () {
      viewModel.setSuspectCount(5);
      expect(viewModel.suspectCount, 5);

      viewModel.setSuspectCount(6);
      expect(viewModel.suspectCount, 6);

      viewModel.setSuspectCount(4);
      expect(viewModel.suspectCount, 4);

      // Invalid values should not change
      viewModel.setSuspectCount(3);
      expect(viewModel.suspectCount, 4);

      viewModel.setSuspectCount(7);
      expect(viewModel.suspectCount, 4);
    });

    test('setSuspectCount should update player names list', () {
      viewModel.setSuspectCount(5);
      expect(viewModel.playerNames.length, 5);

      viewModel.setSuspectCount(6);
      expect(viewModel.playerNames.length, 6);
    });

    test('setPlayerName should update name at specific index', () {
      viewModel.setSuspectCount(4);
      viewModel.setPlayerName(0, 'Alice');
      viewModel.setPlayerName(1, 'Bob');

      expect(viewModel.playerNames[0], 'Alice');
      expect(viewModel.playerNames[1], 'Bob');
      expect(viewModel.playerNames[2], '');
      expect(viewModel.playerNames[3], '');
    });

    test('setPlayerName should not update with invalid index', () {
      viewModel.setSuspectCount(4);
      viewModel.setPlayerName(0, 'Alice');
      
      viewModel.setPlayerName(-1, 'Invalid');
      viewModel.setPlayerName(10, 'Invalid');

      expect(viewModel.playerNames[0], 'Alice');
      expect(viewModel.playerNames.every((name) => name == 'Alice' || name == ''), true);
    });

    test('validateNames should return false for empty names', () {
      viewModel.setSuspectCount(4);
      expect(viewModel.validateNames(), false);
    });

    test('validateNames should return false for duplicate names', () {
      viewModel.setSuspectCount(4);
      viewModel.setPlayerName(0, 'Alice');
      viewModel.setPlayerName(1, 'Alice');
      viewModel.setPlayerName(2, 'Bob');
      viewModel.setPlayerName(3, 'Charlie');

      expect(viewModel.validateNames(), false);
    });

    test('validateNames should return false for case-insensitive duplicates', () {
      viewModel.setSuspectCount(4);
      viewModel.setPlayerName(0, 'Alice');
      viewModel.setPlayerName(1, 'alice'); // Different case
      viewModel.setPlayerName(2, 'Bob');
      viewModel.setPlayerName(3, 'Charlie');

      expect(viewModel.validateNames(), false);
    });

    test('validateNames should return true for valid unique names', () {
      viewModel.setSuspectCount(4);
      viewModel.setPlayerName(0, 'Alice');
      viewModel.setPlayerName(1, 'Bob');
      viewModel.setPlayerName(2, 'Charlie');
      viewModel.setPlayerName(3, 'David');

      expect(viewModel.validateNames(), true);
    });

    test('validateNames should trim whitespace', () {
      viewModel.setSuspectCount(2);
      viewModel.setPlayerName(0, '  Alice  ');
      viewModel.setPlayerName(1, 'Bob');

      // Validation should pass (whitespace trimmed for comparison)
      expect(viewModel.validateNames(), true);
      // Raw value in list has whitespace
      if (viewModel.playerNames.isNotEmpty) {
        expect(viewModel.playerNames[0], '  Alice  '); // Raw value preserved
      }
    });

    test('createGameConfig should throw exception for invalid names', () {
      viewModel.setSuspectCount(4);
      // Names are empty

      expect(
        () => viewModel.createGameConfig(),
        throwsException,
      );
    });

    test('createGameConfig should create valid config', () {
      viewModel.setMode(GameMode.withDetective);
      viewModel.setSuspectCount(4);
      // When detective mode, we need 5 players (4 suspects + 1 detective)
      // The viewmodel should have updated player names list
      expect(viewModel.totalPlayers, 5);
      
      viewModel.setPlayerName(0, 'Alice');
      viewModel.setPlayerName(1, 'Bob');
      viewModel.setPlayerName(2, 'Charlie');
      viewModel.setPlayerName(3, 'David');
      viewModel.setPlayerName(4, 'Eve'); // Detective

      final config = viewModel.createGameConfig();

      expect(config.mode, GameMode.withDetective);
      expect(config.suspectCount, 4);
      expect(config.playerNames.length, 5); // 4 suspects + 1 detective name
      expect(config.playerNames[0], 'Alice');
      expect(config.hasDetective, true);
      expect(config.totalPlayers, 5); // 4 suspects + 1 detective
    });

    test('createGameConfig should trim player names', () {
      // setSuspectCount only accepts 4-6, so use minimum valid value
      viewModel.setSuspectCount(4);
      
      // setSuspectCount triggers _updatePlayerNames which populates the list
      // So playerNames should have 4 empty strings at this point
      
      viewModel.setPlayerName(0, '  Alice  ');
      viewModel.setPlayerName(1, '  Bob  ');
      viewModel.setPlayerName(2, 'Charlie'); // Fill remaining required names
      viewModel.setPlayerName(3, 'David');

      final config = viewModel.createGameConfig();

      expect(config.playerNames.length, 4);
      // createGameConfig trims the names
      expect(config.playerNames[0], 'Alice');
      expect(config.playerNames[1], 'Bob');
    });

    test('_updatePlayerNames should reduce list when mode changes', () {
      viewModel.setSuspectCount(6);
      viewModel.setPlayerName(0, 'A');
      viewModel.setPlayerName(1, 'B');
      viewModel.setPlayerName(2, 'C');
      viewModel.setPlayerName(3, 'D');
      viewModel.setPlayerName(4, 'E');
      viewModel.setPlayerName(5, 'F');

      viewModel.setMode(GameMode.withDetective);
      // Total should be 7 (6 suspects + 1 detective)
      expect(viewModel.playerNames.length, 7);

      viewModel.setMode(GameMode.withoutDetective);
      // Total should be 6 (only suspects)
      expect(viewModel.playerNames.length, 6);
    });

    test('reset should restore initial state', () {
      viewModel.setMode(GameMode.withDetective);
      viewModel.setSuspectCount(6);
      viewModel.setPlayerName(0, 'Alice');
      viewModel.setPlayerName(1, 'Bob');

      viewModel.reset();

      expect(viewModel.selectedMode, GameMode.withoutDetective);
      expect(viewModel.suspectCount, 4);
      expect(viewModel.playerNames, isEmpty);
    });

    test('totalPlayers should calculate correctly', () {
      viewModel.setSuspectCount(5);
      viewModel.setMode(GameMode.withoutDetective);
      expect(viewModel.totalPlayers, 5);

      viewModel.setMode(GameMode.withDetective);
      expect(viewModel.totalPlayers, 6); // 5 suspects + 1 detective
    });
  });
}

