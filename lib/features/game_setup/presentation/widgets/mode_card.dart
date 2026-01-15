import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utils/logger.dart';
import '../bloc/game_setup_bloc.dart';
import '../bloc/game_setup_event.dart';
import '../../domain/entities/game_config.dart';

class ModeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final GameMode mode;

  const ModeCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          final bloc = context.read<GameSetupBloc>();
          final currentState = bloc.state;
          // Create config with updated mode
          final config = GameConfig(
            mode: mode,
            suspectCount: currentState.suspectCount,
            playerNames: currentState.playerNames,
          );
          bloc.add(SetGameMode(mode));
          AppLogger.logNavigation(RouteNames.playerSetup);
          Navigator.pushNamed(
            context,
            RouteNames.playerSetup,
            arguments: config,
          );
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.bloodRed.withOpacity(0.1),
        highlightColor: AppColors.bloodRed.withOpacity(0.2),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.darkRed.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 64,
                color: AppColors.bloodRed,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.lightGray,
                    ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideX();
  }
}
