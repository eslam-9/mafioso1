import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';

class SummaryResultBanner extends StatelessWidget {
  final bool isInnocentsWin;

  const SummaryResultBanner({super.key, required this.isInnocentsWin});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isInnocentsWin ? Colors.green.shade900 : Colors.red.shade900,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              isInnocentsWin ? Icons.celebration : Icons.dangerous,
              size: 80,
              color: Theme.of(context).colorScheme.onPrimary,
            ).animate().scale(delay: 200.ms, duration: 500.ms),
            const SizedBox(height: 16),
            Text(
              isInnocentsWin ? 'innocents_won'.tr() : 'killer_won'.tr(),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 8),
            Text(
              isInnocentsWin ? 'killer_caught'.tr() : 'killer_escaped'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    ).animate().fadeIn().scale();
  }
}
