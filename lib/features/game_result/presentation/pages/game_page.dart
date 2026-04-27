import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utils/logger.dart';
import '../../../role_reveal/domain/entities/player.dart' as player_entity;
import '../../../story/domain/entities/story.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart' as presentation;
import '../widgets/game_tabs.dart';
import '../widgets/elimination_dialog.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.logNavigation(RouteNames.game);

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! Map || args['players'] == null || args['story'] == null) {
      return Scaffold(
        appBar: AppBar(title: Text('investigation'.tr())),
        body: Center(child: Text('error_no_data'.tr())),
      );
    }

    final players = args['players'] as List<player_entity.Player>;
    final story = args['story'] as Story;

    return Scaffold(
      appBar: AppBar(
        title: Text('investigation'.tr()),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'story_and_clues'.tr()),
            Tab(text: 'voting'.tr()),
          ],
        ),
      ),
      body: BlocProvider(
        create: (context) {
          final bloc = GameBloc();
          bloc.add(InitGame(players: players, story: story));
          return bloc;
        },
        child: BlocListener<GameBloc, presentation.GameState>(
          listener: (context, state) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }

            // Check if there's a new vote result with an elimination
            if (state.voteHistory.isNotEmpty) {
              final lastVote = state.voteHistory.last;
              if (lastVote.eliminatedPlayerId != null) {
                // Find the eliminated player
                final eliminatedPlayer = state.players.firstWhere(
                  (p) => p.id == lastVote.eliminatedPlayerId,
                );

                final wasKiller =
                    eliminatedPlayer.role == player_entity.PlayerRole.killer;

                // Show elimination dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => EliminationDialog(
                    eliminatedPlayer: eliminatedPlayer,
                    wasKiller: wasKiller,
                  ),
                ).then((_) {
                  if (!context.mounted) return;
                  // After dialog is closed, check if game is over
                  if (state.isGameOver) {
                    AppLogger.logNavigation(RouteNames.summary);
                    Navigator.pushNamed(
                      context,
                      RouteNames.summary,
                      arguments: {'gameState': state},
                    );
                  }
                });
                return; // Return to prevent immediate navigation before dialog
              }
            }

            // Fallback for game over without elimination (if possible)
            if (state.isGameOver) {
              AppLogger.logNavigation(RouteNames.summary);
              Navigator.pushNamed(
                context,
                RouteNames.summary,
                arguments: {'gameState': state},
              );
            }
          },
          child: BlocBuilder<GameBloc, presentation.GameState>(
            builder: (context, gameState) {
              // Get alive players
              final alivePlayers = gameState.players
                  .where((p) => p.isAlive)
                  .toList();

              return GameTabs(
                tabController: _tabController,
                alivePlayers: alivePlayers,
                onVotesSubmitted: (votes) {
                  AppLogger.logInfo(
                    'Submitting ${votes.length} votes to GameBloc',
                  );
                  context.read<GameBloc>().add(SubmitVotes(votes));
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
