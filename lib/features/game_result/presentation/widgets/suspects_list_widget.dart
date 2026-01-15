import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../story/domain/entities/suspect.dart';

class SuspectsListWidget extends StatelessWidget {
  final List<Suspect> suspects;

  const SuspectsListWidget({super.key, required this.suspects});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المشتبه فيهم',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.bloodRed,
                fontWeight: FontWeight.bold,
              ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 16),
        ...suspects.asMap().entries.map((entry) {
          final index = entry.key;
          final suspect = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: AppColors.bloodRed, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          suspect.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      suspect.suspiciousBehavior,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.lightGray,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: (250 + index * 80).ms).slideX(begin: 0.2, end: 0),
          );
        }),
      ],
    );
  }
}
