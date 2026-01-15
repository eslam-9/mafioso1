import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/game_setup_bloc.dart';
import '../bloc/game_setup_state.dart';
import '../../domain/entities/game_config.dart';

class ModeDisplay extends StatelessWidget {
  const ModeDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameSetupBloc, GameSetupState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  state.selectedMode == GameMode.withDetective
                      ? Icons.search
                      : Icons.groups,
                  color: AppColors.bloodRed,
                ),
                const SizedBox(width: 12),
                Text(
                  state.selectedMode == GameMode.withDetective
                      ? 'with_detective'.tr()
                      : 'without_detective'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn();
      },
    );
  }
}
