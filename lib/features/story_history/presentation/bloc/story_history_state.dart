import 'package:equatable/equatable.dart';
import '../../domain/entities/played_story.dart';

abstract class StoryHistoryState extends Equatable {
  const StoryHistoryState();

  @override
  List<Object?> get props => [];
}

class StoryHistoryInitial extends StoryHistoryState {}

class StoryHistoryLoading extends StoryHistoryState {}

class StoryHistoryLoaded extends StoryHistoryState {
  final List<PlayedStory> stories;

  const StoryHistoryLoaded(this.stories);

  @override
  List<Object?> get props => [stories];
}

class StoryHistoryError extends StoryHistoryState {
  final String message;

  const StoryHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
