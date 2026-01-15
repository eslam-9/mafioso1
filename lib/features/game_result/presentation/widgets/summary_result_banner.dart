import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';

class SummaryResultBanner extends StatelessWidget {
  final bool isInnocentsWin;

  const SummaryResultBanner({super.key, required this.isInnocentsWin});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isInnocentsWin
                ? [Colors.green.withOpacity(0.3), AppColors.charcoal]
                : [AppColors.bloodRed.withOpacity(0.3), AppColors.charcoal],
          ),
        ),
        child: Column(
          children: [
            Icon(
              isInnocentsWin ? Icons.check_circle : Icons.dangerous,
              size: 80,
              color: isInnocentsWin ? Colors.green : AppColors.bloodRed,
            )
                .animate()
                .scale(duration: 600.ms)
                .shake(delay: 600.ms),
            const SizedBox(height: 24),
            Text(
              isInnocentsWin ? 'الأبرياء كسبوا!' : 'القاتل كسب!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: isInnocentsWin ? Colors.green : AppColors.bloodRed,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 16),
            Text(
              isInnocentsWin ? 'القاتل اتقبض عليه!' : 'القاتل هرب من العدالة!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.lightGray,
                  ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    ).animate().fadeIn().scale();
  }
}
