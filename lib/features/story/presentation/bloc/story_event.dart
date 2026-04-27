import 'package:equatable/equatable.dart';
import '../../../game_setup/domain/entities/game_config.dart';

abstract class StoryEvent extends Equatable {
  const StoryEvent();

  @override
  List<Object?> get props => [];
}

class GenerateStory extends StoryEvent {
  final GameConfig config;
  final String languageCode;

  const GenerateStory(this.config, {this.languageCode = 'en'});

  @override
  List<Object?> get props => [config, languageCode];
}

class ResetStory extends StoryEvent {
  const ResetStory();
}

class SetExistingStory extends StoryEvent {
  final dynamic story; // Can be Story object or Map

  const SetExistingStory(this.story);

  @override
  List<Object?> get props => [story];
}
