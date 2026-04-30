import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';

class StoryTitleWidget extends StatelessWidget {
  final String title;

  const StoryTitleWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    final double fontScale = isArabic ? 1.4 : 1.0;

    return Text(
      title,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
        fontSize: (Theme.of(context).textTheme.headlineMedium?.fontSize ?? 28) * fontScale,
      ),
      textAlign: TextAlign.center,
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }
}
