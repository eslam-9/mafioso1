import '../../domain/entities/clue.dart';

class ClueModel extends Clue {
  const ClueModel({required super.text, required super.difficulty});

  factory ClueModel.fromJson(Map<String, dynamic> json) {
    final text = (json['text'] as String?)?.trim() ?? '';
    final difficultyName = json['difficulty'] as String?;
    final difficulty = ClueDifficulty.values.firstWhere(
      (e) => e.name == difficultyName,
      orElse: () => ClueDifficulty.medium,
    );

    if (text.isEmpty) {
      throw const FormatException('Invalid clue payload: text is required.');
    }

    return ClueModel(text: text, difficulty: difficulty);
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'difficulty': difficulty.name};
  }

  ClueModel copyWith({String? text, ClueDifficulty? difficulty}) {
    return ClueModel(
      text: text ?? this.text,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
