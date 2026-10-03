import '../../domain/entities/game_session.dart';

class GameSessionModel extends GameSession {
  const GameSessionModel({
    required super.id,
    required super.roomId,
    required super.storyId,
    required super.status,
    required super.currentRound,
    required super.phase,
    required super.revealedClueIndices,
    required super.gameState,
  });

  factory GameSessionModel.fromJson(Map<String, dynamic> json) {
    return GameSessionModel(
      id: json['id'],
      roomId: json['room_id'],
      storyId: json['story_id'],
      status: json['status'],
      currentRound: json['current_round'] ?? 1,
      phase: json['phase'] ?? 'clues',
      revealedClueIndices: List<int>.from(json['revealed_clue_indices'] ?? []),
      gameState: json['game_state'] ?? 'playing',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'story_id': storyId,
      'status': status,
      'current_round': currentRound,
      'phase': phase,
      'revealed_clue_indices': revealedClueIndices,
      'game_state': gameState,
    };
  }
}
