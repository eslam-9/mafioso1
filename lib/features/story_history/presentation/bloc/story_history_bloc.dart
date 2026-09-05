import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_saved_stories_usecase.dart';
import '../../domain/usecases/save_played_story_usecase.dart';
import '../../domain/usecases/rate_story_usecase.dart';
import 'story_history_event.dart';
import 'story_history_state.dart';

class StoryHistoryBloc extends Bloc<StoryHistoryEvent, StoryHistoryState> {
  final GetSavedStoriesUseCase getSavedStories;
  final SavePlayedStoryUseCase savePlayedStory;
  final RateStoryUseCase rateStory;

  StoryHistoryBloc({
    required this.getSavedStories,
    required this.savePlayedStory,
    required this.rateStory,
  }) : super(StoryHistoryInitial()) {
    on<LoadSavedStories>(_onLoadSavedStories);
    on<SaveStory>(_onSaveStory);
    on<RateStory>(_onRateStory);
  }

  Future<void> _onLoadSavedStories(
    LoadSavedStories event,
    Emitter<StoryHistoryState> emit,
  ) async {
    emit(StoryHistoryLoading());
    try {
      final stories = await getSavedStories();
      emit(StoryHistoryLoaded(stories));
    } catch (e) {
      emit(StoryHistoryError(e.toString()));
    }
  }

  Future<void> _onSaveStory(
    SaveStory event,
    Emitter<StoryHistoryState> emit,
  ) async {
    try {
      await savePlayedStory(event.story);
      // Reload stories if currently loaded
      if (state is StoryHistoryLoaded) {
        add(LoadSavedStories());
      }
    } catch (e) {
      // Background save error, don't necessarily disrupt UI unless on history screen
    }
  }

  Future<void> _onRateStory(
    RateStory event,
    Emitter<StoryHistoryState> emit,
  ) async {
    try {
      await rateStory(event.id, event.rating);
      // Reload stories if currently loaded
      if (state is StoryHistoryLoaded) {
        add(LoadSavedStories());
      }
    } catch (e) {
      // Error handling
    }
  }
}
