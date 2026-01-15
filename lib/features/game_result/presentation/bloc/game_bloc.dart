import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/utils/logger.dart';
import '../../../role_reveal/domain/entities/player.dart' as player_entity;
import '../../../story/domain/entities/clue.dart';
import '../../../voting/domain/entities/vote_result.dart';
import '../../domain/entities/game_state.dart' as domain;
import 'game_event.dart';
import 'game_state.dart' as presentation;

class GameBloc extends Bloc<GameEvent, presentation.GameState> {
  GameBloc() : super(const presentation.GameState()) {
    on<InitGame>(_onInitGame);
    on<RevealNextClue>(_onRevealNextClue);
    on<SubmitVotes>(_onSubmitVotes);
    on<ResetGame>(_onReset);
  }

  void _onInitGame(InitGame event, Emitter<presentation.GameState> emit) {
    AppLogger.logBlocEvent('GameBloc', 'InitGame');
    emit(presentation.GameState(
      players: event.players,
      story: event.story,
      gameState: domain.GameState.playing,
      currentRound: 1,
      voteHistory: const [],
      revealedClues: const [],
    ));
  }

  void _onRevealNextClue(
    RevealNextClue event,
    Emitter<presentation.GameState> emit,
  ) {
    if (!state.canRevealMoreClues || state.story == null) return;

    AppLogger.logBlocEvent('GameBloc', 'RevealNextClue');

    try {
      final nextClueIndex = state.revealedClues.length;
      if (nextClueIndex >= state.story!.clues.length) return;

      final updatedClues = List<Clue>.from(state.revealedClues)
        ..add(state.story!.clues[nextClueIndex]);

      emit(state.copyWith(revealedClues: updatedClues));
    } catch (e, stackTrace) {
      AppLogger.logError('GameBloc', e, stackTrace: stackTrace);
      ErrorHandler.logError(e, stackTrace: stackTrace, context: 'GameBloc.revealNextClue');
    }
  }

  Future<void> _onSubmitVotes(
    SubmitVotes event,
    Emitter<presentation.GameState> emit,
  ) async {
    if (event.votes.isEmpty) {
      throw ArgumentError('قايمة الأصوات مينفعش تكون فاضية');
    }

    if (state.players.isEmpty) {
      throw StateError('مفيش لاعبين متبدئين');
    }

    AppLogger.logBlocEvent('GameBloc', 'SubmitVotes');

    try {
      final result = VoteResult(
        round: state.currentRound,
        votes: event.votes,
        gameState: state.gameState,
      );

      final mostVotedId = result.mostVotedPlayerId;

      if (mostVotedId != null) {
        final eliminatedPlayer = state.players.firstWhere(
          (p) => p.id == mostVotedId,
          orElse: () => throw StateError('اللاعب اللي اتصوت عليه مش موجود'),
        );

        final updatedPlayers = state.players.map((p) {
          if (p.id == mostVotedId) {
            return p.copyWith(isAlive: false);
          }
          return p;
        }).toList();

        domain.GameState newGameState = state.gameState;
        int newRound = state.currentRound;

        if (eliminatedPlayer.role == player_entity.PlayerRole.killer) {
          newGameState = domain.GameState.innocentsWin;
        } else {
          final aliveCount = updatedPlayers.where((p) => p.isAlive).length;
          final killerAlive = updatedPlayers.any((p) => p.role == player_entity.PlayerRole.killer && p.isAlive);

          if (killerAlive && aliveCount <= 2) {
            newGameState = domain.GameState.killerWins;
          }
        }

        final finalResult = VoteResult(
          round: state.currentRound,
          votes: event.votes,
          eliminatedPlayerId: eliminatedPlayer.id,
          eliminatedPlayerName: eliminatedPlayer.name,
          gameState: newGameState,
        );

        final updatedHistory = List<VoteResult>.from(state.voteHistory)..add(finalResult);

        if (newGameState == domain.GameState.playing) {
          newRound = state.currentRound + 1;
        }

        emit(state.copyWith(
          players: updatedPlayers,
          gameState: newGameState,
          currentRound: newRound,
          voteHistory: updatedHistory,
        ));
      } else {
        final finalResult = VoteResult(
          round: state.currentRound,
          votes: event.votes,
          gameState: state.gameState,
        );

        final updatedHistory = List<VoteResult>.from(state.voteHistory)..add(finalResult);

        emit(state.copyWith(
          currentRound: state.currentRound + 1,
          voteHistory: updatedHistory,
        ));
      }
    } catch (e, stackTrace) {
      AppLogger.logError('GameBloc', e, stackTrace: stackTrace);
      ErrorHandler.logError(e, stackTrace: stackTrace, context: 'GameBloc.submitVotes');
      rethrow;
    }
  }

  void _onReset(ResetGame event, Emitter<presentation.GameState> emit) {
    AppLogger.logBlocEvent('GameBloc', 'Reset');
    emit(const presentation.GameState());
  }
}
