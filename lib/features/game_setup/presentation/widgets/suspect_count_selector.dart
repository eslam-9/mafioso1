import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import 'suspect_count_button.dart';

class SuspectCountSelector extends StatelessWidget {
  final bool isLocked;

  const SuspectCountSelector({super.key, this.isLocked = false});

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isLocked,
      child: Opacity(
        opacity: isLocked ? 0.7 : 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'suspect_count'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.bloodRed,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                SuspectCountButton(count: 4),
                SuspectCountButton(count: 5),
                SuspectCountButton(count: 6),
              ],
            ).animate().fadeIn(delay: 200.ms),
          ],
        ),
      ),
    );
  }
}
