enum ClueDifficulty { veryEasy, easy, medium, hard, veryHard }

class Clue {
  final String text;
  final ClueDifficulty difficulty;

  const Clue({required this.text, required this.difficulty});
}
