import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/app_spacing.dart';
import '../../../../features/game_setup/domain/entities/game_config.dart';
import '../../../../features/story/domain/entities/story.dart';
import '../bloc/role_reveal_bloc.dart';
import '../bloc/role_reveal_event.dart';
import '../bloc/role_reveal_state.dart';
import '../../domain/usecases/assign_roles_usecase.dart';
import '../widgets/role_reveal_progress.dart';
import '../widgets/role_reveal_content.dart';
import '../widgets/role_reveal_action_button.dart';
import '../../domain/entities/player.dart';

class RoleRevealPage extends StatefulWidget {
  const RoleRevealPage({super.key});

  @override
  State<RoleRevealPage> createState() => _RoleRevealPageState();
}

class _RoleRevealPageState extends State<RoleRevealPage> {
  bool _isRevealed = false;

  @override
  Widget build(BuildContext context) {
    AppLogger.logNavigation(RouteNames.roleReveal);

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! Map || args['config'] == null || args['story'] == null) {
      return Scaffold(
        appBar: AppBar(title: Text('role_reveal'.tr())),
        body: Center(child: Text('error_no_data'.tr())),
      );
    }

    final config = args['config'] as GameConfig;
    final story = args['story'] as Story;

    return Scaffold(
      appBar: AppBar(
        title: Text('role_reveal'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: BlocProvider(
          create: (context) {
            final bloc = RoleRevealBloc(
              assignRolesUseCase: di.getIt<AssignRolesUseCase>(),
            );
            bloc.add(AssignRoles(config: config, story: story));
            return bloc;
          },
          child: BlocBuilder<RoleRevealBloc, RoleRevealState>(
            builder: (context, state) {
              if (state.currentPlayer == null) {
                return Center(child: Text('error_no_players'.tr()));
              }

              return Padding(
                padding: EdgeInsets.all(AppSpacing.pagePadding),
                child: Column(
                  children: [
                    RoleRevealProgress(
                      currentIndex: state.currentPlayerIndex,
                      totalPlayers: state.players.length,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Center(
                        child: _isRevealed
                            ? RoleRevealContent(player: state.currentPlayer!)
                            : RoleRevealNameCard(player: state.currentPlayer!),
                      ),
                    ),
                    RoleRevealActionButton(
                      isRevealed: _isRevealed,
                      hasNextPlayer: state.hasNextPlayer,
                      onReveal: () {
                        context.read<RoleRevealBloc>().add(
                          const MarkCurrentRevealed(),
                        );
                        setState(() => _isRevealed = true);
                      },
                      onNext: () {
                        context.read<RoleRevealBloc>().add(const NextPlayer());
                        setState(() => _isRevealed = false);
                      },
                      onStartGame: () {
                        AppLogger.logNavigation(RouteNames.game);
                        Navigator.pushNamed(
                          context,
                          RouteNames.game,
                          arguments: {'players': state.players, 'story': story},
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Temporary widget - will be moved to separate file
class RoleRevealNameCard extends StatelessWidget {
  final Player player;

  const RoleRevealNameCard({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(32),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person, size: 100, color: Colors.red),
            const SizedBox(height: 24),
            Text(
              player.name,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text('press_to_reveal'.tr()),
          ],
        ),
      ),
    );
  }
}
