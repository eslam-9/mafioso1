import 'package:equatable/equatable.dart';
import '../../domain/entities/story.dart';

class StoryState extends Equatable {
  final bool isLoading;
  final Story? story;
  final String? errorMessage;

  const StoryState({this.isLoading = false, this.story, this.errorMessage});

  StoryState copyWith({bool? isLoading, Story? story, String? errorMessage}) {
    return StoryState(
      isLoading: isLoading ?? this.isLoading,
      story: story ?? this.story,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, story, errorMessage];
}
