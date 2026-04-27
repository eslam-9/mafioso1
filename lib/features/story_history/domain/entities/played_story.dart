import 'package:equatable/equatable.dart';
import '../../../story/domain/entities/story.dart';

class PlayedStory extends Equatable {
  final String id;
  final Story story;
  final String languageCode;
  final DateTime playedAt;
  final int? userRating;
  final bool isUploaded;

  const PlayedStory({
    required this.id,
    required this.story,
    required this.languageCode,
    required this.playedAt,
    this.userRating,
    this.isUploaded = false,
  });

  PlayedStory copyWith({
    String? id,
    Story? story,
    String? languageCode,
    DateTime? playedAt,
    int? userRating,
    bool? isUploaded,
  }) {
    return PlayedStory(
      id: id ?? this.id,
      story: story ?? this.story,
      languageCode: languageCode ?? this.languageCode,
      playedAt: playedAt ?? this.playedAt,
      userRating: userRating ?? this.userRating,
      isUploaded: isUploaded ?? this.isUploaded,
    );
  }

  @override
  List<Object?> get props => [
    id,
    story,
    languageCode,
    playedAt,
    userRating,
    isUploaded,
  ];
}
