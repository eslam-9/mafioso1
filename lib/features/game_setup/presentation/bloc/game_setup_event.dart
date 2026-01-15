import 'package:equatable/equatable.dart';
import '../../domain/entities/game_config.dart';

abstract class GameSetupEvent extends Equatable {
  const GameSetupEvent();

  @override
  List<Object?> get props => [];
}

class SetGameMode extends GameSetupEvent {
  final GameMode mode;

  const SetGameMode(this.mode);

  @override
  List<Object?> get props => [mode];
}

class SetSuspectCount extends GameSetupEvent {
  final int count;

  const SetSuspectCount(this.count);

  @override
  List<Object?> get props => [count];
}

class SetPlayerName extends GameSetupEvent {
  final int index;
  final String name;

  const SetPlayerName(this.index, this.name);

  @override
  List<Object?> get props => [index, name];
}

class ValidateNames extends GameSetupEvent {
  const ValidateNames();
}

class ResetGameSetup extends GameSetupEvent {
  const ResetGameSetup();
}
