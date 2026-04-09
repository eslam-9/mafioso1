import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/game_config.dart';
import 'game_setup_event.dart';
import 'game_setup_state.dart';

class GameSetupBloc extends Bloc<GameSetupEvent, GameSetupState> {
  GameSetupBloc() : super(const GameSetupState()) {
    on<SetGameMode>(_onSetGameMode);
    on<SetSuspectCount>(_onSetSuspectCount);
    on<SetPlayerName>(_onSetPlayerName);
    on<ValidateNames>(_onValidateNames);
    on<ResetGameSetup>(_onReset);
  }

  void _onSetGameMode(SetGameMode event, Emitter<GameSetupState> emit) {
    AppLogger.logBlocEvent('GameSetupBloc', 'SetGameMode');

    final newTotalPlayers = event.mode == GameMode.withDetective
        ? state.suspectCount + 1
        : state.suspectCount;

    final updatedPlayerNames = _updatePlayerNames(
      state.playerNames,
      newTotalPlayers,
    );

    emit(
      state.copyWith(selectedMode: event.mode, playerNames: updatedPlayerNames),
    );

    add(const ValidateNames());
  }

  void _onSetSuspectCount(SetSuspectCount event, Emitter<GameSetupState> emit) {
    if (event.count < 4 || event.count > 6) return;

    AppLogger.logBlocEvent('GameSetupBloc', 'SetSuspectCount: ${event.count}');

    final newTotalPlayers = state.selectedMode == GameMode.withDetective
        ? event.count + 1
        : event.count;

    final updatedPlayerNames = _updatePlayerNames(
      state.playerNames,
      newTotalPlayers,
    );

    emit(
      state.copyWith(
        suspectCount: event.count,
        playerNames: updatedPlayerNames,
      ),
    );

    add(const ValidateNames());
  }

  void _onSetPlayerName(SetPlayerName event, Emitter<GameSetupState> emit) {
    if (event.index < 0 || event.index >= state.playerNames.length) return;

    AppLogger.logBlocEvent('GameSetupBloc', 'SetPlayerName: ${event.index}');

    final updatedNames = List<String>.from(state.playerNames);
    updatedNames[event.index] = event.name;

    emit(state.copyWith(playerNames: updatedNames));
    add(const ValidateNames());
  }

  void _onValidateNames(ValidateNames event, Emitter<GameSetupState> emit) {
    final isValid = _validateNames(state.playerNames);
    emit(state.copyWith(isValid: isValid));
  }

  void _onReset(ResetGameSetup event, Emitter<GameSetupState> emit) {
    AppLogger.logBlocEvent('GameSetupBloc', 'Reset');
    emit(const GameSetupState());
  }

  List<String> _updatePlayerNames(
    List<String> currentNames,
    int requiredCount,
  ) {
    if (currentNames.length > requiredCount) {
      return currentNames.sublist(0, requiredCount);
    } else {
      final updated = List<String>.from(currentNames);
      while (updated.length < requiredCount) {
        updated.add('');
      }
      return updated;
    }
  }

  bool _validateNames(List<String> names) {
    if (names.any((name) => name.trim().isEmpty)) {
      return false;
    }

    final uniqueNames = names.map((n) => n.trim().toLowerCase()).toSet();
    return uniqueNames.length == names.length;
  }
}
