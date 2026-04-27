import 'package:equatable/equatable.dart';
import '../../domain/entities/community_story.dart';

abstract class StoryLibraryEvent extends Equatable {
  const StoryLibraryEvent();
  @override
  List<Object?> get props => [];
}

class LoadCommunityStories extends StoryLibraryEvent {}

class LoadMoreCommunityStories extends StoryLibraryEvent {}

class RateCommunityStory extends StoryLibraryEvent {
  final String storyId;
  final int rating;
  const RateCommunityStory(this.storyId, this.rating);
  @override
  List<Object?> get props => [storyId, rating];
}

class SelectCommunityStory extends StoryLibraryEvent {
  final CommunityStory story;
  const SelectCommunityStory(this.story);
  @override
  List<Object?> get props => [story];
}
