import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';

class GameStatsWidget extends StatelessWidget {
  final int round;
  final int eliminatedCount;
  final int revealedClues;
  final int totalClues;

  const GameStatsWidget({
    super.key,
    required this.round,
    required this.eliminatedCount,
    required this.revealedClues,
    required this.totalClues,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: AppColors.bloodRed),
                const SizedBox(width: 12),
                Text(
                  'إحصائيات اللعبة',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.bloodRed,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatRow(context, 'إجمالي الجولات', round.toString()),
            _buildStatRow(context, 'اللاعبين المستبعدين', eliminatedCount.toString()),
            _buildStatRow(context, 'الأدلة المكشوفة', '$revealedClues/$totalClues'),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 1000.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightGray,
                ),
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
}
