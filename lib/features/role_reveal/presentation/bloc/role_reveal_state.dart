import 'package:equatable/equatable.dart';
import '../../domain/entities/player.dart';

class RoleRevealState extends Equatable {
  final List<Player> players;
  final int currentPlayerIndex;

  const RoleRevealState({
    this.players = const [],
    this.currentPlayerIndex = 0,
  });

  Player? get currentPlayer =>
      currentPlayerIndex < players.length ? players[currentPlayerIndex] : null;

  bool get hasNextPlayer => currentPlayerIndex < players.length - 1;

  bool get isComplete => currentPlayerIndex >= players.length;

  RoleRevealState copyWith({
    List<Player>? players,
    int? currentPlayerIndex,
  }) {
    return RoleRevealState(
      players: players ?? this.players,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
    );
  }

  @override
  List<Object?> get props => [players, currentPlayerIndex];
}
