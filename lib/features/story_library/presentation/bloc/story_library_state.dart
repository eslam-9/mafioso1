import 'package:equatable/equatable.dart';
import '../../domain/entities/community_story.dart';

abstract class StoryLibraryState extends Equatable {
  const StoryLibraryState();
  @override
  List<Object?> get props => [];
}

class StoryLibraryInitial extends StoryLibraryState {}

class StoryLibraryLoading extends StoryLibraryState {}

class StoryLibraryLoaded extends StoryLibraryState {
  final List<CommunityStory> stories;
  final bool hasMore;
  final int? playerCountFilter;

  const StoryLibraryLoaded({
    required this.stories,
    this.hasMore = true,
    this.playerCountFilter,
  });

  @override
  List<Object?> get props => [stories, hasMore, playerCountFilter];
}

class StoryLibraryError extends StoryLibraryState {
  final String message;
  const StoryLibraryError(this.message);
  @override
  List<Object?> get props => [message];
}
