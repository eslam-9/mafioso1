import 'package:equatable/equatable.dart';
import '../../domain/entities/played_story.dart';

abstract class StoryHistoryEvent extends Equatable {
  const StoryHistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadSavedStories extends StoryHistoryEvent {}

class SaveStory extends StoryHistoryEvent {
  final PlayedStory story;

  const SaveStory(this.story);

  @override
  List<Object?> get props => [story];
}

class RateStory extends StoryHistoryEvent {
  final String id;
  final int rating;

  const RateStory(this.id, this.rating);

  @override
  List<Object?> get props => [id, rating];
}
