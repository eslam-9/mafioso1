import 'package:flutter/foundation.dart';
import '../models/story.dart';
import '../models/game_config.dart';
import '../repositories/story_repository.dart';
import '../services/error_handler.dart';

enum StoryState {
  initial,
  loading,
  loaded,
  error,
}

class StoryViewModel extends ChangeNotifier {
  final StoryRepository _storyRepository;
  
  StoryState _state = StoryState.initial;
  Story? _story;
  String? _errorMessage;
  
  StoryViewModel({required StoryRepository storyRepository})
      : _storyRepository = storyRepository;
  
  StoryState get state => _state;
  Story? get story => _story;
  String? get errorMessage => _errorMessage;
  
  Future<void> generateStory(GameConfig config) async {
    _state = StoryState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _story = await _storyRepository.getStory(
        suspectCount: config.suspectCount,
        hasDetective: config.hasDetective,
      );
      _state = StoryState.loaded;
    } catch (e, stackTrace) {
      _state = StoryState.error;
      _errorMessage = ErrorHandler.getUserMessage(e, context: 'generating story');
      ErrorHandler.logError(e, stackTrace: stackTrace, context: 'StoryViewModel.generateStory');
    }
    
    notifyListeners();
  }
  
  void reset() {
    _state = StoryState.initial;
    _story = null;
    _errorMessage = null;
    notifyListeners();
  }
}
