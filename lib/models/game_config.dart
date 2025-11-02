enum GameMode {
  withDetective,
  withoutDetective,
}

class GameConfig {
  final GameMode mode;
  final int suspectCount;
  final List<String> playerNames;

  GameConfig({
    required this.mode,
    required this.suspectCount,
    required this.playerNames,
  });

  bool get hasDetective => mode == GameMode.withDetective;

  int get totalPlayers => hasDetective ? suspectCount + 1 : suspectCount;

  GameConfig copyWith({
    GameMode? mode,
    int? suspectCount,
    List<String>? playerNames,
  }) {
    return GameConfig(
      mode: mode ?? this.mode,
      suspectCount: suspectCount ?? this.suspectCount,
      playerNames: playerNames ?? this.playerNames,
    );
  }
}
