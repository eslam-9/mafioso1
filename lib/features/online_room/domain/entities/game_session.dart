import 'package:equatable/equatable.dart';

class GameSession extends Equatable {
  final String id;
  final String roomId;
  final String storyId;
  final String status;
  final int currentRound;
  final String phase;
  final List<int> revealedClueIndices;
  final String gameState;

  const GameSession({
    required this.id,
    required this.roomId,
    required this.storyId,
    required this.status,
    required this.currentRound,
    required this.phase,
    required this.revealedClueIndices,
    required this.gameState,
  });

  GameSession copyWith({
    String? id,
    String? roomId,
    String? storyId,
    String? status,
    int? currentRound,
    String? phase,
    List<int>? revealedClueIndices,
    String? gameState,
  }) {
    return GameSession(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      storyId: storyId ?? this.storyId,
      status: status ?? this.status,
      currentRound: currentRound ?? this.currentRound,
      phase: phase ?? this.phase,
      revealedClueIndices: revealedClueIndices ?? this.revealedClueIndices,
      gameState: gameState ?? this.gameState,
    );
  }

  @override
  List<Object?> get props => [
        id,
        roomId,
        storyId,
        status,
        currentRound,
        phase,
        revealedClueIndices,
        gameState,
      ];
}
