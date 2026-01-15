import 'package:equatable/equatable.dart';
import '../../domain/entities/game_config.dart';

class GameSetupState extends Equatable {
  final GameMode selectedMode;
  final int suspectCount;
  final List<String> playerNames;
  final bool isValid;

  const GameSetupState({
    this.selectedMode = GameMode.withoutDetective,
    this.suspectCount = 4,
    this.playerNames = const [],
    this.isValid = false,
  });

  int get totalPlayers =>
      selectedMode == GameMode.withDetective ? suspectCount + 1 : suspectCount;

  GameSetupState copyWith({
    GameMode? selectedMode,
    int? suspectCount,
    List<String>? playerNames,
    bool? isValid,
  }) {
    return GameSetupState(
      selectedMode: selectedMode ?? this.selectedMode,
      suspectCount: suspectCount ?? this.suspectCount,
      playerNames: playerNames ?? this.playerNames,
      isValid: isValid ?? this.isValid,
    );
  }

  GameConfig toGameConfig() {
    return GameConfig(
      mode: selectedMode,
      suspectCount: suspectCount,
      playerNames: playerNames.map((n) => n.trim()).toList(),
    );
  }

  @override
  List<Object?> get props => [selectedMode, suspectCount, playerNames, isValid];
}
