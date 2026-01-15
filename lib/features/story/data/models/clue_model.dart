import '../../domain/entities/clue.dart';

class ClueModel extends Clue {
  const ClueModel({
    required super.text,
    required super.difficulty,
  });

  factory ClueModel.fromJson(Map<String, dynamic> json) {
    return ClueModel(
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

  ClueModel copyWith({
    String? text,
    ClueDifficulty? difficulty,
  }) {
    return ClueModel(
      text: text ?? this.text,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
