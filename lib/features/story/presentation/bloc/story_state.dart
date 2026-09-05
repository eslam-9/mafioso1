import 'package:equatable/equatable.dart';
import '../../../../core/errors/app_error.dart';
import '../../domain/entities/story.dart';

class StoryState extends Equatable {
  final bool isLoading;
  final Story? story;
  final AppError? error;

  const StoryState({this.isLoading = false, this.story, this.error});

  StoryState copyWith({bool? isLoading, Story? story, AppError? error}) {
    return StoryState(
      isLoading: isLoading ?? this.isLoading,
      story: story ?? this.story,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, story, error];
}
