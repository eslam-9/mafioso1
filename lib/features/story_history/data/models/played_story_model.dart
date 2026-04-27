import 'package:hive_ce/hive.dart';
import 'dart:convert';
import '../../domain/entities/played_story.dart';
import '../../../story/data/models/story_model.dart';
import '../../../story/data/models/clue_model.dart';
import '../../../story/data/models/suspect_model.dart';
import '../../../story/domain/entities/story.dart';

part 'played_story_model.g.dart';

@HiveType(typeId: 0)
class PlayedStoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String storyJson;

  @HiveField(2)
  final DateTime playedAt;

  @HiveField(3)
  final int? userRating;

  @HiveField(4)
  final bool isUploaded;

  PlayedStoryModel({
    required this.id,
    required this.storyJson,
    required this.playedAt,
    this.userRating,
    this.isUploaded = false,
  });

  /// Converts this Hive model to the domain [PlayedStory] entity.
  PlayedStory toEntity() {
    return PlayedStory(
      id: id,
      story: StoryModel.fromJson(jsonDecode(storyJson) as Map<String, dynamic>),
      playedAt: playedAt,
      userRating: userRating,
      isUploaded: isUploaded,
    );
  }

  /// Creates a [PlayedStoryModel] from a domain [PlayedStory] entity.
  factory PlayedStoryModel.fromEntity(PlayedStory entity) {
    final storyModel = _storyToModel(entity.story);
    return PlayedStoryModel(
      id: entity.id,
      storyJson: jsonEncode(storyModel.toJson()),
      playedAt: entity.playedAt,
      userRating: entity.userRating,
      isUploaded: entity.isUploaded,
    );
  }

  PlayedStoryModel copyWith({int? userRating, bool? isUploaded}) {
    return PlayedStoryModel(
      id: id,
      storyJson: storyJson,
      playedAt: playedAt,
      userRating: userRating ?? this.userRating,
      isUploaded: isUploaded ?? this.isUploaded,
    );
  }

  static StoryModel _storyToModel(Story story) {
    return StoryModel(
      title: story.title,
      intro: story.intro,
      crimeDescription: story.crimeDescription,
      suspects: story.suspects
          .map(
            (s) => SuspectModel(
              name: s.name,
              suspiciousBehavior: s.suspiciousBehavior,
            ),
          )
          .toList(),
      clues: story.clues
          .map((c) => ClueModel(text: c.text, difficulty: c.difficulty))
          .toList(),
      twist: story.twist,
      killerName: story.killerName,
    );
  }
}
