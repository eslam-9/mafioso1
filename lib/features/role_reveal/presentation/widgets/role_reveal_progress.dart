import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';

class RoleRevealProgress extends StatelessWidget {
  final int currentIndex;
  final int totalPlayers;

  const RoleRevealProgress({
    super.key,
    required this.currentIndex,
    required this.totalPlayers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: (currentIndex + 1) / totalPlayers,
          backgroundColor: AppColors.smokeGray,
          color: AppColors.bloodRed,
        ).animate().fadeIn(),
        const SizedBox(height: 8),
        Text(
          'player_of_total'.tr(
            namedArgs: {
              'current': (currentIndex + 1).toString(),
              'total': totalPlayers.toString(),
            },
          ),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColors.lightGray),
        ).animate().fadeIn(),
      ],
    );
  }
}
