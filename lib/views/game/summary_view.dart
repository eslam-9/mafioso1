import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/app_router.dart';
import '../../app/app_providers.dart';
import '../../app/app_theme.dart';
import '../../models/vote_result.dart';
import '../../services/sound_service.dart';
import '../../widgets/background_widget.dart';

class SummaryView extends ConsumerStatefulWidget {
  const SummaryView({super.key});

  @override
  ConsumerState<SummaryView> createState() => _SummaryViewState();
}

class _SummaryViewState extends ConsumerState<SummaryView> {
  bool _soundPlayed = false;

  @override
  void initState() {
    super.initState();
  }

  void _playResultSound() {
    if (!mounted || _soundPlayed) return;
    _soundPlayed = true;

    try {
      final gameViewModel = ref.read(gameViewModelProvider);
      final soundService = ref.read(soundServiceProvider);
      if (gameViewModel.gameState == GameState.innocentsWin) {
        soundService.playSound(SoundEffect.win);
      } else {
        soundService.playSound(SoundEffect.lose);
      }
    } catch (e) {
      // Sound service might not be available
    }
  }

  @override
  Widget build(BuildContext context) {
    // Play sound after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _playResultSound();
      }
    });

    final viewModel = ref.watch(gameViewModelProvider);
    final killer = viewModel.getKiller();
    final isInnocentsWin = viewModel.gameState == GameState.innocentsWin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('انتهت اللعبة'),
        automaticallyImplyLeading: false,
      ),
      body: BackgroundWidget(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Result Banner
                Card(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isInnocentsWin
                            ? [Colors.green.withOpacity(0.3), AppTheme.charcoal]
                            : [
                                AppTheme.bloodRed.withOpacity(0.3),
                                AppTheme.charcoal,
                              ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                              isInnocentsWin
                                  ? Icons.check_circle
                                  : Icons.dangerous,
                              size: 80,
                              color: isInnocentsWin
                                  ? Colors.green
                                  : AppTheme.bloodRed,
                            )
                            .animate()
                            .scale(duration: 600.ms)
                            .shake(delay: 600.ms),

                        const SizedBox(height: 24),

                        Text(
                          isInnocentsWin ? 'الأبرياء كسبوا!' : 'القاتل كسب!',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: isInnocentsWin
                                    ? Colors.green
                                    : AppTheme.bloodRed,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 200.ms),

                        const SizedBox(height: 16),

                        Text(
                          isInnocentsWin
                              ? 'القاتل اتقبض عليه!'
                              : 'القاتل هرب من العدالة!',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppTheme.lightGray),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 400.ms),
                      ],
                    ),
                  ),
                ).animate().fadeIn().scale(),

                const SizedBox(height: 24),

                // Killer Reveal
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.dangerous, color: AppTheme.bloodRed),
                            const SizedBox(width: 12),
                            Text(
                              'القاتل كان...',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: AppTheme.bloodRed,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.deepBlack.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person,
                                color: AppTheme.bloodRed,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                killer?.name ?? 'مجهول',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 24),

                // Story Twist
                if (viewModel.story?.twist != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.auto_stories,
                                color: AppTheme.bloodRed,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'الحقيقة',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: AppTheme.bloodRed,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            viewModel.story!.twist,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppTheme.lightGray,
                                  height: 1.5,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.2, end: 0),

                const SizedBox(height: 24),

                // Game Stats
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.bar_chart, color: AppTheme.bloodRed),
                            const SizedBox(width: 12),
                            Text(
                              'إحصائيات اللعبة',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: AppTheme.bloodRed,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildStatRow(
                          context,
                          'إجمالي الجولات',
                          viewModel.currentRound.toString(),
                        ),
                        _buildStatRow(
                          context,
                          'اللاعبين المستبعدين',
                          (viewModel.players.length -
                                  viewModel.alivePlayers.length)
                              .toString(),
                        ),
                        _buildStatRow(
                          context,
                          'الأدلة المكشوفة',
                          '${viewModel.revealedClues.length}/${viewModel.availableClues.length}',
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 1000.ms).slideX(begin: 0.2, end: 0),

                const SizedBox(height: 32),

                // Action Buttons
                ElevatedButton(
                  onPressed: () => _playAgain(context),
                  child: const Text('العب تاني'),
                ).animate().fadeIn(delay: 1200.ms),

                const SizedBox(height: 16),

                OutlinedButton(
                  onPressed: () => context.go(AppRouter.home),
                  child: const Text('القائمة الرئيسية'),
                ).animate().fadeIn(delay: 1400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.lightGray),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _playAgain(BuildContext context) {
    // Reset all view models
    ref.read(gameSetupViewModelProvider).reset();
    ref.read(storyViewModelProvider).reset();
    ref.read(roleRevealViewModelProvider).reset();
    ref.read(gameViewModelProvider).reset();

    // Navigate to game mode selection
    context.go(AppRouter.gameMode);
  }
}
