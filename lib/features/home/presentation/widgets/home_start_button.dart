import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utils/logger.dart';
import '../../../game_setup/domain/entities/game_config.dart';

class HomeStartButton extends StatelessWidget {
  const HomeStartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250.w,
      child: ElevatedButton(
        onPressed: () {
          AppLogger.logNavigation(RouteNames.playerSetup);
          Navigator.pushNamed(
            context,
            RouteNames.playerSetup,
            arguments: GameConfig(
              mode: GameMode.withoutDetective,
              suspectCount: 4,
              playerNames: List<String>.filled(4, ''),
            ),
          );
        },
        child: Text('start_game'.tr()),
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0);
  }
}
