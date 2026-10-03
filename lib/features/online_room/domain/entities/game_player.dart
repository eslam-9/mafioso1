import 'package:equatable/equatable.dart';

class GamePlayer extends Equatable {
  final String id;
  final String sessionId;
  final String userId;
  final String displayName;
  final String role; // 'killer', 'detective', 'innocent'
  final String? storyCharacterName;
  final String? storyCharacterBehavior;
  final bool isAlive;
  final bool hasVoted;

  const GamePlayer({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.displayName,
    required this.role,
    this.storyCharacterName,
    this.storyCharacterBehavior,
    required this.isAlive,
    required this.hasVoted,
  });

  GamePlayer copyWith({
    String? id,
    String? sessionId,
    String? userId,
    String? displayName,
    String? role,
    String? storyCharacterName,
    String? storyCharacterBehavior,
    bool? isAlive,
    bool? hasVoted,
  }) {
    return GamePlayer(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      storyCharacterName: storyCharacterName ?? this.storyCharacterName,
      storyCharacterBehavior: storyCharacterBehavior ?? this.storyCharacterBehavior,
      isAlive: isAlive ?? this.isAlive,
      hasVoted: hasVoted ?? this.hasVoted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sessionId,
        userId,
        displayName,
        role,
        storyCharacterName,
        storyCharacterBehavior,
        isAlive,
        hasVoted,
      ];
}
