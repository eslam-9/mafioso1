import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../story/domain/entities/clue.dart';

class CluesListWidget extends StatelessWidget {
  final List<Clue> clues;

  const CluesListWidget({super.key, required this.clues});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الأدلة',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.bloodRed,
                fontWeight: FontWeight.bold,
              ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 16),
        if (clues.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'لسه مفيش أدلة اتكشفت. اكشف أدلة عشان تساعد في حل اللغز.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.lightGray,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ).animate().fadeIn(delay: 300.ms),
        ...clues.asMap().entries.map((entry) {
          final index = entry.key;
          final clue = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getClueDifficultyColor(clue.difficulty),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getClueDifficultyLabel(clue.difficulty),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: _getClueDifficultyColor(clue.difficulty),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            clue.text,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.lightGray,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: (300 + index * 100).ms).slideX(begin: -0.2, end: 0),
          );
        }),
      ],
    );
  }

  Color _getClueDifficultyColor(ClueDifficulty difficulty) {
    switch (difficulty) {
      case ClueDifficulty.veryEasy:
        return Colors.green;
      case ClueDifficulty.easy:
        return Colors.lightGreen;
      case ClueDifficulty.medium:
        return Colors.orange;
      case ClueDifficulty.hard:
        return Colors.deepOrange;
      case ClueDifficulty.veryHard:
        return Colors.red;
    }
  }

  String _getClueDifficultyLabel(ClueDifficulty difficulty) {
    switch (difficulty) {
      case ClueDifficulty.veryEasy:
        return 'سهل جداً';
      case ClueDifficulty.easy:
        return 'سهل';
      case ClueDifficulty.medium:
        return 'متوسط';
      case ClueDifficulty.hard:
        return 'صعب';
      case ClueDifficulty.veryHard:
        return 'صعب جداً';
    }
  }
}
