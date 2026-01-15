import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/services/sound_service.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../bloc/game_state.dart' as presentation;
import '../../domain/entities/game_state.dart' as domain;
import '../widgets/summary_result_banner.dart';
import '../widgets/killer_reveal_widget.dart';
import '../widgets/story_twist_widget.dart';
import '../widgets/game_stats_widget.dart';
import '../widgets/summary_actions.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  bool _soundPlayed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_soundPlayed) {
        _playResultSound();
        _soundPlayed = true;
      }
    });
  }

  void _playResultSound() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['gameState'] is presentation.GameState) {
      final gameState = args['gameState'] as presentation.GameState;
      try {
        final soundService = di.getIt<SoundService>();
        if (gameState.gameState == domain.GameState.innocentsWin) {
          soundService.playSound(SoundEffect.win);
        } else {
          soundService.playSound(SoundEffect.lose);
        }
      } catch (e) {
        // Sound service might not be available
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.logNavigation(RouteNames.summary);

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! Map || args['gameState'] == null) {
      return Scaffold(
        appBar: AppBar(title: Text('game_over'.tr())),
        body: Center(child: Text('error_no_data'.tr())),
      );
    }

    final gameState = args['gameState'] as presentation.GameState;
    final isInnocentsWin = gameState.gameState == domain.GameState.innocentsWin;
    final killer = gameState.players.firstWhere(
      (p) => p.role.name == 'killer',
      orElse: () => gameState.players.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('game_over'.tr()),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SummaryResultBanner(isInnocentsWin: isInnocentsWin),
              SizedBox(height: AppSpacing.large),
              KillerRevealWidget(killerName: killer.name),
              SizedBox(height: AppSpacing.large),
              if (gameState.story?.twist != null)
                StoryTwistWidget(twist: gameState.story!.twist),
              SizedBox(height: AppSpacing.large),
              GameStatsWidget(
                round: gameState.currentRound,
                eliminatedCount:
                    gameState.players.length - gameState.alivePlayers.length,
                revealedClues: gameState.revealedClues.length,
                totalClues: gameState.availableClues.length,
              ),
              SizedBox(height: AppSpacing.xlarge),
              SummaryActions(),
            ],
          ),
        ),
      ),
    );
  }
}
