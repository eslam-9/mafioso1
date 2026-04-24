import '../../domain/entities/story.dart';
import '../../domain/entities/clue.dart';
import '../../domain/entities/suspect.dart';
import 'clue_model.dart';
import 'suspect_model.dart';

class StoryModel extends Story {
  const StoryModel({
    required super.title,
    required super.intro,
    required super.crimeDescription,
    required super.suspects,
    required super.clues,
    required super.twist,
    required super.killerName,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    final title = (json['title'] as String?)?.trim() ?? '';
    final intro = (json['intro'] as String?)?.trim() ?? '';
    final crimeDescription =
        (json['crimeDescription'] as String?)?.trim() ?? '';
    final twist = (json['twist'] as String?)?.trim() ?? '';
    final killerName = (json['killerName'] as String?)?.trim() ?? '';
    final suspectsJson = json['suspects'];
    final cluesJson = json['clues'];

    if (suspectsJson is! List || cluesJson is! List) {
      throw const FormatException(
        'Invalid story payload: suspects and clues must be arrays.',
      );
    }

    final suspects = suspectsJson
        .map((s) => SuspectModel.fromJson(s as Map<String, dynamic>))
        .toList();
    final clues = cluesJson
        .map((c) => ClueModel.fromJson(c as Map<String, dynamic>))
        .toList();

    if (title.isEmpty ||
        intro.isEmpty ||
        crimeDescription.isEmpty ||
        twist.isEmpty ||
        killerName.isEmpty ||
        suspects.isEmpty ||
        clues.isEmpty) {
      throw const FormatException(
        'Invalid story payload: required fields are missing or empty.',
      );
    }

    return StoryModel(
      title: title,
      intro: intro,
      crimeDescription: crimeDescription,
      suspects: suspects,
      clues: clues,
      twist: twist,
      killerName: killerName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'intro': intro,
      'crimeDescription': crimeDescription,
      'suspects': suspects.map((s) => (s as SuspectModel).toJson()).toList(),
      'clues': clues.map((c) => (c as ClueModel).toJson()).toList(),
      'twist': twist,
      'killerName': killerName,
    };
  }

  StoryModel copyWith({
    String? title,
    String? intro,
    String? crimeDescription,
    List<Suspect>? suspects,
    List<Clue>? clues,
    String? twist,
    String? killerName,
  }) {
    return StoryModel(
      title: title ?? this.title,
      intro: intro ?? this.intro,
      crimeDescription: crimeDescription ?? this.crimeDescription,
      suspects: suspects ?? this.suspects,
      clues: clues ?? this.clues,
      twist: twist ?? this.twist,
      killerName: killerName ?? this.killerName,
    );
  }
}
