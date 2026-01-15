enum PlayerRole {
  killer,
  detective,
  innocent,
}

class Player {
  final String id;
  final String name;
  final PlayerRole role;
  final bool isAlive;
  final bool hasRevealed;
  final String? storyCharacterName;
  final String? storyCharacterBehavior;

  const Player({
    required this.id,
    required this.name,
    required this.role,
    this.isAlive = true,
    this.hasRevealed = false,
    this.storyCharacterName,
    this.storyCharacterBehavior,
  });

  Player copyWith({
    String? id,
    String? name,
    PlayerRole? role,
    bool? isAlive,
    bool? hasRevealed,
    String? storyCharacterName,
    String? storyCharacterBehavior,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      isAlive: isAlive ?? this.isAlive,
      hasRevealed: hasRevealed ?? this.hasRevealed,
      storyCharacterName: storyCharacterName ?? this.storyCharacterName,
      storyCharacterBehavior: storyCharacterBehavior ?? this.storyCharacterBehavior,
    );
  }

  String get roleDisplayName {
    switch (role) {
      case PlayerRole.killer:
        return 'القاتل';
      case PlayerRole.detective:
        return 'المحقق';
      case PlayerRole.innocent:
        return 'بريء';
    }
  }

  String get roleDescription {
    switch (role) {
      case PlayerRole.killer:
        return 'إنت اللي عملت الجريمة. استخبى واستبعد الأبرياء.';
      case PlayerRole.detective:
        return 'لاقي القاتل قبل ما يبقى متأخر. استخدم الأدلة بذكاء.';
      case PlayerRole.innocent:
        return 'إنت بريء. اتعاونوا عشان تلاقوا القاتل.';
    }
  }
}
