import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/assign_roles_usecase.dart';
import '../../domain/entities/player.dart';
import 'role_reveal_event.dart';
import 'role_reveal_state.dart';

class RoleRevealBloc extends Bloc<RoleRevealEvent, RoleRevealState> {
  final AssignRolesUseCase assignRolesUseCase;

  RoleRevealBloc({required this.assignRolesUseCase}) : super(const RoleRevealState()) {
    on<AssignRoles>(_onAssignRoles);
    on<NextPlayer>(_onNextPlayer);
    on<MarkCurrentRevealed>(_onMarkCurrentRevealed);
    on<ResetRoleReveal>(_onReset);
  }

  void _onAssignRoles(AssignRoles event, Emitter<RoleRevealState> emit) {
    AppLogger.logBlocEvent('RoleRevealBloc', 'AssignRoles');
    
    final players = assignRolesUseCase(
      config: event.config,
      story: event.story,
    );

    emit(state.copyWith(players: players, currentPlayerIndex: 0));
  }

  void _onNextPlayer(NextPlayer event, Emitter<RoleRevealState> emit) {
    if (!state.hasNextPlayer) return;
    
    AppLogger.logBlocEvent('RoleRevealBloc', 'NextPlayer');
    
    final updatedPlayers = List<Player>.from(state.players);
    updatedPlayers[state.currentPlayerIndex] = updatedPlayers[state.currentPlayerIndex]
        .copyWith(hasRevealed: true);

    emit(state.copyWith(
      players: updatedPlayers,
      currentPlayerIndex: state.currentPlayerIndex + 1,
    ));
  }

  void _onMarkCurrentRevealed(MarkCurrentRevealed event, Emitter<RoleRevealState> emit) {
    if (state.currentPlayer == null) return;
    
    AppLogger.logBlocEvent('RoleRevealBloc', 'MarkCurrentRevealed');
    
    final updatedPlayers = List<Player>.from(state.players);
    updatedPlayers[state.currentPlayerIndex] = updatedPlayers[state.currentPlayerIndex]
        .copyWith(hasRevealed: true);

    emit(state.copyWith(players: updatedPlayers));
  }

  void _onReset(ResetRoleReveal event, Emitter<RoleRevealState> emit) {
    AppLogger.logBlocEvent('RoleRevealBloc', 'Reset');
    emit(const RoleRevealState());
  }
}
