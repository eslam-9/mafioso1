import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utils/logger.dart';
import '../../../game_setup/domain/entities/game_config.dart';

class SummaryActions extends StatelessWidget {
  const SummaryActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            AppLogger.logNavigation(RouteNames.playerSetup);
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteNames.playerSetup,
              ModalRoute.withName(RouteNames.home),
              arguments: GameConfig(
                mode: GameMode.withoutDetective,
                suspectCount: 4,
                playerNames: List<String>.filled(4, ''),
              ),
            );
          },
          child: Text('play_again'.tr()),
        ).animate().fadeIn(delay: 1200.ms),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            AppLogger.logNavigation(RouteNames.home);
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteNames.home,
              (route) => false,
            );
          },
          child: Text('main_menu'.tr()),
        ).animate().fadeIn(delay: 1400.ms),
      ],
    );
  }
}
