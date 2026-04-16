import 'package:equatable/equatable.dart';
import '../../../role_reveal/domain/entities/player.dart' as player_entity;
import '../../../story/domain/entities/story.dart';
import '../../../voting/domain/entities/vote.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class InitGame extends GameEvent {
  final List<player_entity.Player> players;
  final Story story;

  const InitGame({required this.players, required this.story});

  @override
  List<Object?> get props => [players, story];
}

class RevealNextClue extends GameEvent {
  const RevealNextClue();
}

class SubmitVotes extends GameEvent {
  final List<Vote> votes;

  const SubmitVotes(this.votes);

  @override
  List<Object?> get props => [votes];
}

class ResetGame extends GameEvent {
  const ResetGame();
}
