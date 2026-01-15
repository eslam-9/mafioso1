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
    return StoryModel(
      title: json['title'] as String,
      intro: json['intro'] as String,
      crimeDescription: json['crimeDescription'] as String,
      suspects: (json['suspects'] as List)
          .map((s) => SuspectModel.fromJson(s as Map<String, dynamic>))
          .toList(),
      clues: (json['clues'] as List)
          .map((c) => ClueModel.fromJson(c as Map<String, dynamic>))
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
