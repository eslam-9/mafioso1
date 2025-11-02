import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/app_router.dart';
import '../../app/app_providers.dart';
import '../../app/app_theme.dart';
import '../../models/player.dart';
import '../../services/sound_service.dart';
import '../../viewmodels/role_reveal_viewmodel.dart';
import '../../widgets/background_widget.dart';

class RoleRevealView extends ConsumerStatefulWidget {
  const RoleRevealView({super.key});

  @override
  ConsumerState<RoleRevealView> createState() => _RoleRevealViewState();
}

class _RoleRevealViewState extends ConsumerState<RoleRevealView> {
  bool _isRevealed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('كشف الأدوار'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.storyGeneration),
        ),
      ),
      body: BackgroundWidget(
        child: SafeArea(
          child: Builder(
            builder: (context) {
              final viewModel = ref.watch(roleRevealViewModelProvider);
              final player = viewModel.currentPlayer;

              if (player == null) {
                return Center(
                  child: Text(
                    'مفيش لاعبين',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Progress Indicator
                    LinearProgressIndicator(
                      value:
                          (viewModel.currentPlayerIndex + 1) /
                          viewModel.players.length,
                      backgroundColor: AppTheme.smokeGray,
                      color: AppTheme.bloodRed,
                    ).animate().fadeIn(),

                    const SizedBox(height: 16),

                    Text(
                      'لاعب ${viewModel.currentPlayerIndex + 1} من ${viewModel.players.length}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.lightGray,
                      ),
                    ).animate().fadeIn(),

                    Expanded(
                      child: Center(
                        child: _isRevealed
                            ? _buildRoleCard(context, player)
                            : _buildNameCard(context, player),
                      ),
                    ),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _handleButtonPress(context),
                        child: Text(_getButtonText(viewModel)),
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNameCard(BuildContext context, Player player) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(32),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person,
              size: 100,
              color: AppTheme.bloodRed,
            ).animate().scale(duration: 600.ms),

            const SizedBox(height: 24),

            Text(
              player.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 16),

            Text(
              'اضغط تحت عشان تكشف دورك',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.lightGray),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildRoleCard(BuildContext context, Player player) {
    final roleColor = _getRoleColor(player.role);

    return Card(
      child: Container(
        padding: const EdgeInsets.all(32),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [roleColor.withOpacity(0.2), AppTheme.charcoal],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getRoleIcon(player.role),
              size: 100,
              color: roleColor,
            ).animate().scale(duration: 600.ms).shake(delay: 600.ms),

            const SizedBox(height: 24),

            Text(
              player.roleDisplayName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: roleColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.deepBlack.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  if (player.storyCharacterName != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_outline, color: AppTheme.bloodRed, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'شخصيتك في القصة:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppTheme.bloodRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      player.storyCharacterName!,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.charcoal.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        player.storyCharacterBehavior ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightGray,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: AppTheme.smokeGray),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    player.roleDescription,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.lightGray,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    ).animate().fadeIn().scale();
  }

  Color _getRoleColor(PlayerRole role) {
    switch (role) {
      case PlayerRole.killer:
        return AppTheme.bloodRed;
      case PlayerRole.detective:
        return Colors.blue;
      case PlayerRole.innocent:
        return Colors.green;
    }
  }

  IconData _getRoleIcon(PlayerRole role) {
    switch (role) {
      case PlayerRole.killer:
        return Icons.dangerous;
      case PlayerRole.detective:
        return Icons.search;
      case PlayerRole.innocent:
        return Icons.shield;
    }
  }

  String _getButtonText(RoleRevealViewModel viewModel) {
    if (!_isRevealed) {
      return 'اكشف الدور';
    } else if (viewModel.hasNextPlayer) {
      return 'اللاعب الجاي';
    } else {
      return 'ابدأ اللعبة';
    }
  }

  void _handleButtonPress(BuildContext context) {
    final viewModel = ref.read(roleRevealViewModelProvider);

    if (!_isRevealed) {
      // Play sound and reveal role
      try {
        ref.read(soundServiceProvider).playSound(SoundEffect.roleReveal);
      } catch (e) {
        // Sound service might not be available
      }

      setState(() {
        _isRevealed = true;
      });
      viewModel.markCurrentAsRevealed();
    } else if (viewModel.hasNextPlayer) {
      // Move to next player
      viewModel.nextPlayer();
      setState(() {
        _isRevealed = false;
      });
    } else {
      // Start the game
      final storyViewModel = ref.read(storyViewModelProvider);
      final gameViewModel = ref.read(gameViewModelProvider);

      gameViewModel.initGame(viewModel.players, storyViewModel.story!);
      context.go(AppRouter.game);
    }
  }
}
