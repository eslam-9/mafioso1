import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:uuid/uuid.dart';
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
import '../../../story_history/presentation/widgets/story_rating_widget.dart';
import '../../../story_history/presentation/bloc/story_history_bloc.dart';
import '../../../story_history/presentation/bloc/story_history_event.dart';
import '../../../story_history/domain/entities/played_story.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  bool _soundPlayed = false;
  bool _storySaved = false;
  String? _playedStoryId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _handleGameInit();
  }

  void _handleGameInit() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['gameState'] is presentation.GameState) {
      final gameState = args['gameState'] as presentation.GameState;

      // Play Sound
      if (!_soundPlayed) {
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
        _soundPlayed = true;
      }

      // Save Story
      if (!_storySaved && gameState.story != null) {
        _storySaved = true;
        _playedStoryId = const Uuid().v4();

        final playedStory = PlayedStory(
          id: _playedStoryId!,
          story: gameState.story!,
          playedAt: DateTime.now(),
        );

        di.getIt<StoryHistoryBloc>().add(SaveStory(playedStory));
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
              if (_playedStoryId != null) ...[
                SizedBox(height: AppSpacing.large),
                Container(
                  padding: EdgeInsets.all(AppSpacing.medium),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: StoryRatingWidget(
                    onRatingSelected: (rating) {
                      di.getIt<StoryHistoryBloc>().add(
                        RateStory(_playedStoryId!, rating),
                      );
                    },
                  ),
                ),
              ],
              SizedBox(height: AppSpacing.xlarge),
              SummaryActions(),
            ],
          ),
        ),
      ),
    );
  }
}
