import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';

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
    final isArabic = context.locale.languageCode == 'ar';
    final double fontScale = isArabic ? 1.4 : 1.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'story'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: (Theme.of(context).textTheme.titleLarge?.fontSize ?? 22) * fontScale,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              intro,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.9),
                height: 1.6,
                fontSize: (Theme.of(context).textTheme.bodyLarge?.fontSize ?? 16) * fontScale,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              crimeDescription,
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
    ).animate().fadeIn(delay: 200.ms).scale(delay: 200.ms);
  }
}
