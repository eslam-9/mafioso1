import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utils/logger.dart';

class SummaryActions extends StatelessWidget {
  const SummaryActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            AppLogger.logNavigation(RouteNames.gameMode);
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteNames.gameMode,
              (route) => false,
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
