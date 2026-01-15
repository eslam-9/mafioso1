import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';

class StorySuspectsInfoWidget extends StatelessWidget {
  final int suspectCount;

  const StorySuspectsInfoWidget({super.key, required this.suspectCount});

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
                Icon(Icons.people, color: AppColors.bloodRed),
                const SizedBox(width: 8),
                Text(
                  'suspects_count'.tr(
                    namedArgs: {'count': suspectCount.toString()},
                  ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'each_player_role'.tr(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.lightGray.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2, end: 0);
  }
}
