import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';

class RoundInfoWidget extends StatelessWidget {
  final int round;
  final int aliveCount;
  final int revealedClues;
  final int totalClues;

  const RoundInfoWidget({
    super.key,
    required this.round,
    required this.aliveCount,
    required this.revealedClues,
    required this.totalClues,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              context,
              'round'.tr(),
              round.toString(),
              Icons.refresh,
            ),
            _buildStatItem(
              context,
              'alive'.tr(),
              aliveCount.toString(),
              Icons.people,
            ),
            _buildStatItem(
              context,
              'clues'.tr(),
              '$revealedClues/$totalClues',
              Icons.lightbulb,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: AppColors.bloodRed, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
