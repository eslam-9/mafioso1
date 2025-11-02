import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/player.dart';
import '../models/game_config.dart';
import '../models/story.dart';

class RoleRevealViewModel extends ChangeNotifier {
  List<Player> _players = [];
  int _currentPlayerIndex = 0;

  List<Player> get players => _players;
  int get currentPlayerIndex => _currentPlayerIndex;
  Player? get currentPlayer => _currentPlayerIndex < _players.length
      ? _players[_currentPlayerIndex]
      : null;
  bool get hasNextPlayer => _currentPlayerIndex < _players.length - 1;
  bool get isComplete => _currentPlayerIndex >= _players.length;

  void assignRoles(GameConfig config, Story story) {
    _players.clear();
    _currentPlayerIndex = 0;

    final random = Random();
    final playerNames = List<String>.from(config.playerNames);

    // Assign roles
    final roles = <PlayerRole>[];

    // Add killer
    roles.add(PlayerRole.killer);

    // Add detective if needed
    if (config.hasDetective) {
      roles.add(PlayerRole.detective);
    }

    // Fill rest with innocents
    while (roles.length < config.totalPlayers) {
      roles.add(PlayerRole.innocent);
    }

    // Shuffle roles
    roles.shuffle(random);

    // Create players
    for (int i = 0; i < playerNames.length; i++) {
      _players.add(
        Player(id: 'player_$i', name: playerNames[i], role: roles[i]),
      );
    }

    // Assign story characters to players
    if (story.suspects.isNotEmpty) {
      final killerSuspect = story.suspects.firstWhere(
        (s) => s.name == story.killerName,
        orElse: () => story.suspects.first,
      );
      
      final otherSuspects = story.suspects
          .where((s) => s.name != killerSuspect.name)
          .toList()
        ..shuffle(random);

      int suspectIndex = 0;

      for (int i = 0; i < _players.length; i++) {
        if (_players[i].role == PlayerRole.killer) {
          _players[i] = _players[i].copyWith(
            storyCharacterName: killerSuspect.name,
            storyCharacterBehavior: killerSuspect.suspiciousBehavior,
          );
        } else if (_players[i].role != PlayerRole.detective) {
          if (suspectIndex < otherSuspects.length) {
            _players[i] = _players[i].copyWith(
              storyCharacterName: otherSuspects[suspectIndex].name,
              storyCharacterBehavior: otherSuspects[suspectIndex].suspiciousBehavior,
            );
            suspectIndex++;
          }
        }
      }
    }

    notifyListeners();
  }

  void nextPlayer() {
    if (hasNextPlayer) {
      _players[_currentPlayerIndex] = _players[_currentPlayerIndex].copyWith(
        hasRevealed: true,
      );
      _currentPlayerIndex++;
      notifyListeners();
    }
  }

  void markCurrentAsRevealed() {
    if (currentPlayer != null) {
      _players[_currentPlayerIndex] = _players[_currentPlayerIndex].copyWith(
        hasRevealed: true,
      );
      notifyListeners();
    }
  }

  Player? getKiller() {
    return _players.firstWhere(
      (p) => p.role == PlayerRole.killer,
      orElse: () => _players.first,
    );
  }

  Player? getDetective() {
    try {
      return _players.firstWhere((p) => p.role == PlayerRole.detective);
    } catch (e) {
      return null;
    }
  }

  void reset() {
    _players.clear();
    _currentPlayerIndex = 0;
    notifyListeners();
  }
}
