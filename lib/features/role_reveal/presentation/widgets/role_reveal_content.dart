import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mafioso/core/utils/role_localization_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/player.dart';

class RoleRevealContent extends StatelessWidget {
  final Player player;

  const RoleRevealContent({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final roleColor = _getRoleColor(player.role);

    return Card(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                roleColor.withValues(alpha: 0.2),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getRoleIcon(player.role),
                size: 100,
                color: roleColor,
              ).animate().scale(duration: 600.ms).shake(delay: 600.ms),
              const SizedBox(height: 24),
              Text(
                _getRoleName(player.role),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: roleColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.deepBlack.withValues(alpha: 0.5)
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    if (player.storyCharacterName != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_outline,
                            color: AppColors.bloodRed,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'your_story_character'.tr(),
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        player.storyCharacterName!,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (player.storyCharacterBehavior != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? AppColors.charcoal.withValues(alpha: 0.5)
                                : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            player.storyCharacterBehavior!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withValues(alpha: 0.8),
                                  height: 1.5,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Divider(color: AppColors.smokeGray),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      RoleLocalizationHelper.getRoleDescription(player.role),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().scale();
  }

  Color _getRoleColor(PlayerRole role) {
    switch (role) {
      case PlayerRole.killer:
        return AppColors.bloodRed;
      case PlayerRole.detective:
        return Colors.blue;
      case PlayerRole.innocent:
        return Colors.green;
    }
  }

  String _getRoleName(PlayerRole role) {
    switch (role) {
      case PlayerRole.killer:
        return 'role_killer'.tr();
      case PlayerRole.detective:
        return 'role_detective'.tr();
      case PlayerRole.innocent:
        return 'role_innocent'.tr();
    }
  }

  IconData _getRoleIcon(PlayerRole role) {
    switch (role) {
      case PlayerRole.killer:
        return Icons.dangerous;
      case PlayerRole.detective:
        return Icons.search;
      case PlayerRole.innocent:
        return Icons.shield;
    }
  }
}
