import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
            _buildStatItem(context, 'الجولة', round.toString(), Icons.refresh),
            _buildStatItem(context, 'على قيد الحياة', aliveCount.toString(), Icons.people),
            _buildStatItem(context, 'الأدلة', '$revealedClues/$totalClues', Icons.lightbulb),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.bloodRed, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.lightGray,
              ),
        ),
      ],
    );
  }
}
