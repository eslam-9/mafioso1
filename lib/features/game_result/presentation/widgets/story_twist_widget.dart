import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';

class StoryTwistWidget extends StatelessWidget {
  final String twist;

  const StoryTwistWidget({super.key, required this.twist});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'truth'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.bloodRed,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              twist,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.lightGray,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
}
