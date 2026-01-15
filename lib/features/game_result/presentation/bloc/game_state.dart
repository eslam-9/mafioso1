import 'package:equatable/equatable.dart';
import '../../../role_reveal/domain/entities/player.dart' as player_entity;
import '../../../story/domain/entities/story.dart';
import '../../../story/domain/entities/clue.dart';
import '../../../voting/domain/entities/vote_result.dart';
import '../../domain/entities/game_state.dart' as domain;

class GameState extends Equatable {
  final List<player_entity.Player> players;
  final Story? story;
  final domain.GameState gameState;
  final int currentRound;
  final List<VoteResult> voteHistory;
  final List<Clue> revealedClues;

  const GameState({
    this.players = const [],
    this.story,
    this.gameState = domain.GameState.playing,
    this.currentRound = 1,
    this.voteHistory = const [],
    this.revealedClues = const [],
  });

  List<player_entity.Player> get alivePlayers => players.where((p) => p.isAlive).toList();

  List<Clue> get availableClues => story?.clues ?? [];

  bool get canRevealMoreClues => revealedClues.length < availableClues.length;

  bool get isGameOver =>
      gameState == domain.GameState.innocentsWin ||
      gameState == domain.GameState.killerWins;

  GameState copyWith({
    List<player_entity.Player>? players,
    Story? story,
    domain.GameState? gameState,
    int? currentRound,
    List<VoteResult>? voteHistory,
    List<Clue>? revealedClues,
  }) {
    return GameState(
      players: players ?? this.players,
      story: story ?? this.story,
      gameState: gameState ?? this.gameState,
      currentRound: currentRound ?? this.currentRound,
      voteHistory: voteHistory ?? this.voteHistory,
      revealedClues: revealedClues ?? this.revealedClues,
    );
  }

  @override
  List<Object?> get props =>
      [players, story, gameState, currentRound, voteHistory, revealedClues];
}
