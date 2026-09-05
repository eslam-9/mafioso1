import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../story/domain/entities/story.dart';

class StoryCardWidget extends StatelessWidget {
  final Story story;

  const StoryCardWidget({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    final double fontScale = isArabic ? 1.4 : 1.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.menu_book, color: AppColors.bloodRed),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    story.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: (Theme.of(context).textTheme.titleLarge?.fontSize ?? 22) * fontScale,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              story.crimeDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.6,
                fontSize: (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) * fontScale,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }
}
