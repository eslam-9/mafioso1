import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/generate_story_usecase.dart';
import 'story_event.dart';
import 'story_state.dart';

class StoryBloc extends Bloc<StoryEvent, StoryState> {
  final GenerateStoryUseCase generateStoryUseCase;

  StoryBloc({required this.generateStoryUseCase}) : super(const StoryState()) {
    on<GenerateStory>(_onGenerateStory);
    on<ResetStory>(_onResetStory);
  }

  Future<void> _onGenerateStory(
    GenerateStory event,
    Emitter<StoryState> emit,
  ) async {
    AppLogger.logBlocEvent('StoryBloc', 'GenerateStory');
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final story = await generateStoryUseCase(
        suspectCount: event.config.suspectCount,
        hasDetective: event.config.hasDetective,
      );

      AppLogger.logBlocState('StoryBloc', 'StoryLoaded: ${story.title}');
      emit(state.copyWith(isLoading: false, story: story));
    } catch (e, stackTrace) {
      AppLogger.logError('StoryBloc', e, stackTrace: stackTrace);
      ErrorHandler.logError(e, stackTrace: stackTrace, context: 'StoryBloc.generateStory');
      
      final errorMessage = ErrorHandler.getUserMessage(e, context: 'generating story');
      AppLogger.logBlocState('StoryBloc', 'StoryError: $errorMessage');
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    }
  }

  void _onResetStory(ResetStory event, Emitter<StoryState> emit) {
    AppLogger.logBlocEvent('StoryBloc', 'ResetStory');
    emit(const StoryState());
  }
}
