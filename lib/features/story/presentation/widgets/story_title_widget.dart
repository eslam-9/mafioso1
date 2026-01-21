import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StoryTitleWidget extends StatelessWidget {
  final String title;

  const StoryTitleWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }
}
