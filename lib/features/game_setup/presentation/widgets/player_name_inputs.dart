import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../bloc/game_setup_bloc.dart';
import '../bloc/game_setup_state.dart';
import 'player_name_input.dart';

class PlayerNameInputs extends StatelessWidget {
  const PlayerNameInputs({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameSetupBloc, GameSetupState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'player_names'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 8),
            Text(
              'total_players'.tr(
                namedArgs: {'count': state.totalPlayers.toString()},
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 16),
            ...List.generate(
              state.totalPlayers,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PlayerNameInput(
                  index: index,
                ).animate().fadeIn(delay: (500 + index * 50).ms),
              ),
            ),
          ],
        );
      },
    );
  }
}
