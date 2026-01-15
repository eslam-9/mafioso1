import 'clue.dart';
import 'suspect.dart';

class Story {
  final String title;
  final String intro;
  final String crimeDescription;
  final List<Suspect> suspects;
  final List<Clue> clues;
  final String twist;
  final String killerName;

  const Story({
    required this.title,
    required this.intro,
    required this.crimeDescription,
    required this.suspects,
    required this.clues,
    required this.twist,
    required this.killerName,
  });
}
