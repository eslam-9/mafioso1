enum ClueDifficulty {
  veryEasy,
  easy,
  medium,
  hard,
  veryHard,
}

class Clue {
  final String text;
  final ClueDifficulty difficulty;

  Clue({
    required this.text,
    required this.difficulty,
  });

  factory Clue.fromJson(Map<String, dynamic> json) {
    return Clue(
      text: json['text'] as String,
      difficulty: ClueDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => ClueDifficulty.medium,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'difficulty': difficulty.name,
    };
  }
}

class Suspect {
  final String name;
  final String suspiciousBehavior;

  Suspect({
    required this.name,
    required this.suspiciousBehavior,
  });

  factory Suspect.fromJson(Map<String, dynamic> json) {
    return Suspect(
      name: json['name'] as String,
      suspiciousBehavior: json['suspiciousBehavior'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'suspiciousBehavior': suspiciousBehavior,
    };
  }
}

class Story {
  final String title;
  final String intro;
  final String crimeDescription;
  final List<Suspect> suspects;
  final List<Clue> clues;
  final String twist;
  final String killerName;

  Story({
    required this.title,
    required this.intro,
    required this.crimeDescription,
    required this.suspects,
    required this.clues,
    required this.twist,
    required this.killerName,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      title: json['title'] as String,
      intro: json['intro'] as String,
      crimeDescription: json['crimeDescription'] as String,
      suspects: (json['suspects'] as List)
          .map((s) => Suspect.fromJson(s as Map<String, dynamic>))
          .toList(),
      clues: (json['clues'] as List)
          .map((c) => Clue.fromJson(c as Map<String, dynamic>))
          .toList(),
      twist: json['twist'] as String,
      killerName: json['killerName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'intro': intro,
      'crimeDescription': crimeDescription,
      'suspects': suspects.map((s) => s.toJson()).toList(),
      'clues': clues.map((c) => c.toJson()).toList(),
      'twist': twist,
      'killerName': killerName,
    };
  }
}
