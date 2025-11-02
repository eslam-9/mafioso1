import 'package:flutter/foundation.dart';
import '../models/player.dart';
import '../models/story.dart';
import '../models/vote_result.dart';
import '../services/error_handler.dart';

class GameViewModel extends ChangeNotifier {
  List<Player> _players = [];
  Story? _story;
  GameState _gameState = GameState.playing;
  int _currentRound = 1;
  List<VoteResult> _voteHistory = [];
  List<Clue> _revealedClues = [];
  
  List<Player> get players => _players;
  List<Player> get alivePlayers => _players.where((p) => p.isAlive).toList();
  Story? get story => _story;
  GameState get gameState => _gameState;
  int get currentRound => _currentRound;
  List<VoteResult> get voteHistory => _voteHistory;
  List<Clue> get revealedClues => _revealedClues;
  List<Clue> get availableClues => _story?.clues ?? [];
  bool get canRevealMoreClues => _revealedClues.length < availableClues.length;
  
  void initGame(List<Player> players, Story story) {
    _players = players;
    _story = story;
    _gameState = GameState.playing;
    _currentRound = 1;
    _voteHistory = [];
    _revealedClues = [];
    notifyListeners();
  }
  
  void revealNextClue() {
    try {
      if (!canRevealMoreClues || _story == null) {
        return;
      }

      final nextClueIndex = _revealedClues.length;
      if (nextClueIndex >= _story!.clues.length) {
        return;
      }

      _revealedClues.add(_story!.clues[nextClueIndex]);
      notifyListeners();
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace, context: 'GameViewModel.revealNextClue');
    }
  }
  
  Future<VoteResult> submitVotes(List<Vote> votes) async {
    try {
      if (votes.isEmpty) {
        throw ArgumentError('قايمة الأصوات مينفعش تكون فاضية');
      }

      if (_players.isEmpty) {
        throw StateError('مفيش لاعبين متبدئين');
      }

      final result = VoteResult(
        round: _currentRound,
        votes: votes,
        gameState: _gameState,
      );
      
      // Determine who gets eliminated
      final mostVotedId = result.mostVotedPlayerId;
      
      if (mostVotedId != null) {
        final eliminatedPlayer = _players.firstWhere(
          (p) => p.id == mostVotedId,
          orElse: () => throw StateError('اللاعب اللي اتصوت عليه مش موجود'),
        );
        
        // Eliminate the player
        final index = _players.indexWhere((p) => p.id == mostVotedId);
        if (index == -1) {
          throw StateError('رقم اللاعب مش موجود');
        }
        _players[index] = _players[index].copyWith(isAlive: false);
        
        // Check win conditions
        if (eliminatedPlayer.role == PlayerRole.killer) {
          _gameState = GameState.innocentsWin;
        } else {
          // Check if killer wins (only killer + 1 other alive)
          final aliveCount = alivePlayers.length;
          final killerAlive = alivePlayers.any((p) => p.role == PlayerRole.killer);
          
          if (killerAlive && aliveCount <= 2) {
            _gameState = GameState.killerWins;
          }
        }
        
        final finalResult = VoteResult(
          round: _currentRound,
          votes: votes,
          eliminatedPlayerId: eliminatedPlayer.id,
          eliminatedPlayerName: eliminatedPlayer.name,
          gameState: _gameState,
        );
        
        _voteHistory.add(finalResult);
        
        if (_gameState == GameState.playing) {
          _currentRound++;
        }

        notifyListeners();
        return _voteHistory.last;
      } else {
        // Tie - no elimination
        final finalResult = VoteResult(
          round: _currentRound,
          votes: votes,
          gameState: _gameState,
        );
        _voteHistory.add(finalResult);
        _currentRound++;
        
        notifyListeners();
        return _voteHistory.last;
      }
    } catch (e, stackTrace) {
      // Log error and rethrow with better message
      ErrorHandler.logError(e, stackTrace: stackTrace, context: 'GameViewModel.submitVotes');
      rethrow;
    }
  }
  
  Player? getKiller() {
    try {
      return _players.firstWhere((p) => p.role == PlayerRole.killer);
    } catch (e) {
      // No killer found or empty players list
      return null;
    }
  }
  
  bool get isGameOver => _gameState == GameState.innocentsWin || _gameState == GameState.killerWins;
  
  void reset() {
    _players = [];
    _story = null;
    _gameState = GameState.playing;
    _currentRound = 1;
    _voteHistory = [];
    _revealedClues = [];
    notifyListeners();
  }
}
