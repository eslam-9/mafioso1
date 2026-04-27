import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/delete_story_usecase.dart';
import '../../domain/usecases/get_saved_stories_usecase.dart';
import '../../domain/usecases/save_played_story_usecase.dart';
import '../../domain/usecases/rate_story_usecase.dart';
import 'story_history_event.dart';
import 'story_history_state.dart';

class StoryHistoryBloc extends Bloc<StoryHistoryEvent, StoryHistoryState> {
  final GetSavedStoriesUseCase getSavedStories;
  final SavePlayedStoryUseCase savePlayedStory;
  final DeleteStoryUseCase deleteStory;
  final RateStoryUseCase rateStory;

  StoryHistoryBloc({
    required this.getSavedStories,
    required this.savePlayedStory,
    required this.deleteStory,
    required this.rateStory,
  }) : super(StoryHistoryInitial()) {
    on<LoadSavedStories>(_onLoadSavedStories);
    on<SaveStory>(_onSaveStory);
    on<DeleteStory>(_onDeleteStory);
    on<RateStory>(_onRateStory);
  }

  Future<void> _onLoadSavedStories(
    LoadSavedStories event,
    Emitter<StoryHistoryState> emit,
  ) async {
    AppLogger.logBlocEvent('StoryHistoryBloc', 'LoadSavedStories');
    emit(StoryHistoryLoading());
    try {
      final stories = await getSavedStories();
      AppLogger.logInfo(
        'StoryHistoryBloc: loaded ${stories.length} saved stories',
      );
      emit(StoryHistoryLoaded(stories));
    } catch (e) {
      AppLogger.logError('StoryHistoryBloc.LoadSavedStories', e);
      emit(StoryHistoryError(e.toString()));
    }
  }

  Future<void> _onDeleteStory(
    DeleteStory event,
    Emitter<StoryHistoryState> emit,
  ) async {
    AppLogger.logBlocEvent('StoryHistoryBloc', 'DeleteStory(${event.id})');
    try {
      await deleteStory(event.id);
      AppLogger.logInfo('StoryHistoryBloc: deleted story id=${event.id}');
      if (state is StoryHistoryLoaded) {
        add(LoadSavedStories());
      }
    } catch (e) {
      AppLogger.logError('StoryHistoryBloc.DeleteStory', e);
      if (state is StoryHistoryLoaded) {
        emit(StoryHistoryError(e.toString()));
      }
    }
  }

  Future<void> _onSaveStory(
    SaveStory event,
    Emitter<StoryHistoryState> emit,
  ) async {
    AppLogger.logBlocEvent(
      'StoryHistoryBloc',
      'SaveStory(${event.story.id})',
    );
    try {
      await savePlayedStory(event.story);
      AppLogger.logInfo(
        'StoryHistoryBloc: saved story id=${event.story.id} rated=${event.story.userRating != null} uploaded=${event.story.isUploaded}',
      );
      // Reload stories if currently loaded
      if (state is StoryHistoryLoaded) {
        add(LoadSavedStories());
      }
    } catch (e) {
      AppLogger.logError('StoryHistoryBloc.SaveStory', e);
      // Background save error, don't necessarily disrupt UI unless on history screen
    }
  }

  Future<void> _onRateStory(
    RateStory event,
    Emitter<StoryHistoryState> emit,
  ) async {
    AppLogger.logBlocEvent(
      'StoryHistoryBloc',
      'RateStory(${event.id}, ${event.rating})',
    );
    try {
      await rateStory(event.id, event.rating);
      AppLogger.logInfo(
        'StoryHistoryBloc: rated story id=${event.id} rating=${event.rating}',
      );
      // Reload stories if currently loaded
      if (state is StoryHistoryLoaded) {
        add(LoadSavedStories());
      }
    } catch (e) {
      AppLogger.logError('StoryHistoryBloc.RateStory', e);
      // Error handling
    }
  }
}
