import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/role_localization_helper.dart';
import '../../../role_reveal/domain/entities/player.dart';

class EliminationDialog extends StatelessWidget {
  final Player eliminatedPlayer;
  final bool wasKiller;

  const EliminationDialog({
    super.key,
    required this.eliminatedPlayer,
    required this.wasKiller,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: wasKiller ? AppColors.bloodRed : AppColors.lightGray,
          width: 2,
        ),
      ),
      title: Column(
        children: [
          Icon(
            wasKiller ? Icons.check_circle : Icons.cancel,
            color: wasKiller ? AppColors.bloodRed : AppColors.lightGray,
            size: 64,
          ).animate().scale(duration: 500.ms),
          const SizedBox(height: 16),
          Text(
            'player_eliminated'.tr(),
            style: TextStyle(
              color: wasKiller ? AppColors.bloodRed : AppColors.lightGray,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            eliminatedPlayer.name,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: wasKiller
                  ? AppColors.bloodRed
                  : (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.smokeGray
                        : Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              RoleLocalizationHelper.getRoleDisplayName(eliminatedPlayer.role),
              style: TextStyle(
                color:
                    wasKiller || Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            wasKiller
                ? 'killer_eliminated_message'.tr()
                : 'innocent_eliminated_message'.tr(),
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.8),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ).animate().fadeIn(delay: 300.ms),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: wasKiller
                  ? AppColors.bloodRed
                  : (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.smokeGray
                        : Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(
              'continue'.tr(),
              style: TextStyle(
                fontSize: 18,
                color:
                    wasKiller || Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
