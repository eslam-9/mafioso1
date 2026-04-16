import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/game_setup_bloc.dart';
import '../bloc/game_setup_state.dart';
import '../../domain/entities/game_config.dart';
import 'mode_card.dart';

class ModeSelector extends StatelessWidget {
  const ModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'choose_game_mode'.tr(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.bloodRed,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 60),
              BlocBuilder<GameSetupBloc, GameSetupState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      ModeCard(
                        title: 'with_detective'.tr(),
                        description: 'with_detective_desc'.tr(),
                        icon: Icons.search,
                        mode: GameMode.withDetective,
                      ),
                      const SizedBox(height: 24),
                      ModeCard(
                        title: 'without_detective'.tr(),
                        description: 'without_detective_desc'.tr(),
                        icon: Icons.groups,
                        mode: GameMode.withoutDetective,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
