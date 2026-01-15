import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';

class StoryCardWidget extends StatelessWidget {
  final String intro;
  final String crimeDescription;

  const StoryCardWidget({
    super.key,
    required this.intro,
    required this.crimeDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'story'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.bloodRed,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              intro,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.lightGray,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              crimeDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.lightGray.withOpacity(0.9),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).scale(delay: 200.ms);
  }
}
