import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/game_setup_bloc.dart';
import '../bloc/game_setup_event.dart';
import '../bloc/game_setup_state.dart';

class SuspectCountButton extends StatelessWidget {
  final int count;

  const SuspectCountButton({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameSetupBloc, GameSetupState>(
      builder: (context, state) {
        final isSelected = state.suspectCount == count;

        return InkWell(
          onTap: () {
            context.read<GameSetupBloc>().add(SetSuspectCount(count));
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryRed : AppColors.smokeGray,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.bloodRed
                    : AppColors.darkRed.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                count.toString(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
