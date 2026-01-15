import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
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
          'suspects'.tr(),
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
            child:
                Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.bloodRed,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          suspect.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          suspect.suspiciousBehavior,
                          style: TextStyle(color: AppColors.lightGray),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: (300 + index * 100).ms)
                    .slideX(begin: -0.2, end: 0),
          );
        }),
      ],
    );
  }
}
