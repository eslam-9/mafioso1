import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/rating_service.dart';

/// A custom dialog that prompts the user to rate the app on the Google Play Store.
class RateAppDialog extends StatelessWidget {
  const RateAppDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    final double fontScale = isArabic ? 1.2 : 1.0;
    final ratingService = getIt<RatingService>();

    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.primaryRed, width: 2),
      ),
      title: Column(
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 72)
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                end: const Offset(1.1, 1.1),
                duration: 1000.ms,
                curve: Curves.easeInOut,
              ),
          const SizedBox(height: 16),
          Text(
            'rate_dialog_title'.tr(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 22 * fontScale,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Text(
        'rate_dialog_body'.tr(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
          fontSize: 16 * fontScale,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ).animate().fadeIn(delay: 200.ms),
      actionsAlignment: MainAxisAlignment.spaceAround,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () async {
                await ratingService.markAsRated();
                if (context.mounted) {
                  Navigator.pop(context);
                }
                await ratingService.openPlayStore();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: AppColors.bloodRed.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'rate_now'.tr(),
                style: TextStyle(
                  fontSize: 16 * fontScale,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await ratingService.markAsRemindLater();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      side: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'maybe_later'.tr(),
                      style: TextStyle(fontSize: 14 * fontScale),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      await ratingService.markAsDeclined();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'no_thanks'.tr(),
                      style: TextStyle(fontSize: 14 * fontScale),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 450.ms),
          ],
        ),
      ],
    );
  }
}
