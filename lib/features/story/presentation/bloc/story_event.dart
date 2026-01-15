import 'package:equatable/equatable.dart';
import '../../../game_setup/domain/entities/game_config.dart';

abstract class StoryEvent extends Equatable {
  const StoryEvent();

  @override
  List<Object?> get props => [];
}

class GenerateStory extends StoryEvent {
  final GameConfig config;

  const GenerateStory(this.config);

  @override
  List<Object?> get props => [config];
}

class ResetStory extends StoryEvent {
  const ResetStory();
}
