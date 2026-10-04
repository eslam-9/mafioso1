import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../bloc/game_setup_bloc.dart';
import '../bloc/game_setup_state.dart';

class ContinueButton extends StatelessWidget {
  final dynamic existingStory;

  const ContinueButton({super.key, this.existingStory});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameSetupBloc, GameSetupState>(
      builder: (context, state) {
        return ElevatedButton(
          onPressed: state.isValid
              ? () {
                  final config = state.toGameConfig();
                  
                  // Analytics
                  di.getIt<AnalyticsService>().logGameStarted(
                    mode: config.hasDetective ? 'with_detective' : 'without_detective',
                    playerCount: config.totalPlayers,
                  );

                  AppLogger.logNavigation(RouteNames.storyGeneration);
                  Navigator.pushNamed(
                    context,
                    RouteNames.storyGeneration,
                    arguments: {
                      'config': config,
                      'existingStory': existingStory,
                    },
                  );
                }
              : null,
          child: Text('continue'.tr()),
        ).animate().fadeIn(delay: 800.ms);
      },
    );
  }
}
