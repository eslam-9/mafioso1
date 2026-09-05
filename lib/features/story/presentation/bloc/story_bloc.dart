import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/app_error.dart';
import '../../domain/entities/story.dart';
import '../../domain/usecases/generate_story_usecase.dart';
import '../../domain/entities/story.dart';
import '../../data/models/story_model.dart';
import 'story_event.dart';
import 'story_state.dart';

class StoryBloc extends Bloc<StoryEvent, StoryState> {
  final GenerateStoryUseCase generateStoryUseCase;

  StoryBloc({required this.generateStoryUseCase}) : super(const StoryState()) {
    on<GenerateStory>(_onGenerateStory);
    on<UseExistingStory>(_onUseExistingStory);
    on<ResetStory>(_onResetStory);
    on<SetExistingStory>(_onSetExistingStory);
  }

  void _onSetExistingStory(SetExistingStory event, Emitter<StoryState> emit) {
    AppLogger.logBlocEvent('StoryBloc', 'SetExistingStory');
    try {
      if (event.story is Story) {
        emit(state.copyWith(story: event.story as Story, isLoading: false));
      } else if (event.story is Map<String, dynamic>) {
        final story = StoryModel.fromJson(event.story as Map<String, dynamic>);
        emit(state.copyWith(story: story, isLoading: false));
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load existing story',
        ),
      );
    }
  }

  Future<void> _onGenerateStory(
    GenerateStory event,
    Emitter<StoryState> emit,
  ) async {
    AppLogger.logBlocEvent('StoryBloc', 'GenerateStory');
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final story = await generateStoryUseCase(
        suspectCount: event.config.suspectCount,
        hasDetective: event.config.hasDetective,
        languageCode: event.languageCode,
      );

      AppLogger.logBlocState('StoryBloc', 'StoryLoaded: ${story.title}');
      emit(state.copyWith(isLoading: false, story: story));
    } catch (e, stackTrace) {
      AppLogger.logError('StoryBloc', e, stackTrace: stackTrace);
      ErrorHandler.logError(
        e,
        stackTrace: stackTrace,
        context: 'StoryBloc.generateStory',
      );

      final AppError error = ErrorHandler.toAppError(e);
      AppLogger.logBlocState('StoryBloc', 'StoryError: ${error.key}');
      emit(state.copyWith(isLoading: false, error: error));
    }
  }

  void _onUseExistingStory(UseExistingStory event, Emitter<StoryState> emit) {
    final Story story = event.story;
    AppLogger.logBlocEvent('StoryBloc', 'UseExistingStory');
    AppLogger.logBlocState('StoryBloc', 'ExistingStoryLoaded: ${story.title}');
    emit(StoryState(isLoading: false, story: story, error: null));
  }

  void _onResetStory(ResetStory event, Emitter<StoryState> emit) {
    AppLogger.logBlocEvent('StoryBloc', 'ResetStory');
    emit(const StoryState());
  }
}
