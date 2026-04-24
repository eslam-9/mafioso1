import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafioso/features/game_result/presentation/bloc/game_bloc.dart';
import 'package:mafioso/features/game_result/presentation/bloc/game_event.dart';
import 'package:mafioso/features/game_result/presentation/bloc/game_state.dart';
import 'package:mafioso/features/role_reveal/domain/entities/player.dart';
import 'package:mafioso/features/story/domain/entities/clue.dart';
import 'package:mafioso/features/story/domain/entities/story.dart';
import 'package:mafioso/features/story/domain/entities/suspect.dart';
import 'package:mafioso/features/voting/domain/entities/vote.dart';

void main() {
  final story = Story(
    title: 'The Manor',
    intro: 'A cold night at the manor.',
    crimeDescription: 'The host was found dead in the library.',
    suspects: const [
      Suspect(
        name: 'Alice',
        suspiciousBehavior: 'She was seen leaving the library.',
      ),
    ],
    clues: const [
      Clue(text: 'A muddy footprint.', difficulty: ClueDifficulty.easy),
    ],
    twist: 'The murder weapon was hidden inside a cane.',
    killerName: 'Alice',
  );

  final players = const [
    Player(id: '1', name: 'Player 1', role: PlayerRole.killer),
    Player(id: '2', name: 'Player 2', role: PlayerRole.innocent),
  ];

  blocTest<GameBloc, GameState>(
    'emits recoverable error state when submitting empty votes',
    build: () => GameBloc(),
    seed: () => GameState(players: players, story: story),
    act: (bloc) => bloc.add(const SubmitVotes([])),
    expect: () => [
      isA<GameState>().having(
        (state) => state.errorMessage,
        'errorMessage',
        isNotNull,
      ),
    ],
  );

  blocTest<GameBloc, GameState>(
    'clears error state after successful vote submission',
    build: () => GameBloc(),
    seed: () => GameState(
      players: players,
      story: story,
      errorMessage: 'old error',
    ),
    act: (bloc) => bloc.add(
      const SubmitVotes([
        Vote(
          voterId: '2',
          voterName: 'Player 2',
          accusedId: '1',
          accusedName: 'Player 1',
        ),
      ]),
    ),
    expect: () => [
      isA<GameState>().having(
        (state) => state.errorMessage,
        'errorMessage',
        isNull,
      ),
    ],
  );
}
