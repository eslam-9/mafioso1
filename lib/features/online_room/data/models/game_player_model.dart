import '../../domain/entities/game_player.dart';

class GamePlayerModel extends GamePlayer {
  const GamePlayerModel({
    required super.id,
    required super.sessionId,
    required super.userId,
    required super.displayName,
    required super.role,
    super.storyCharacterName,
    super.storyCharacterBehavior,
    required super.isAlive,
    required super.hasVoted,
  });

  factory GamePlayerModel.fromJson(Map<String, dynamic> json) {
    return GamePlayerModel(
      id: json['id'],
      sessionId: json['session_id'],
      userId: json['user_id'],
      displayName: json['display_name'],
      role: json['role'],
      storyCharacterName: json['story_character_name'],
      storyCharacterBehavior: json['story_character_behavior'],
      isAlive: json['is_alive'] ?? true,
      hasVoted: json['has_voted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'user_id': userId,
      'display_name': displayName,
      'role': role,
      'story_character_name': storyCharacterName,
      'story_character_behavior': storyCharacterBehavior,
      'is_alive': isAlive,
      'has_voted': hasVoted,
    };
  }
}
