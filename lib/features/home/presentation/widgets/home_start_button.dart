import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utils/logger.dart';
import '../../../game_setup/domain/entities/game_config.dart';
import '../../../../shared/widgets/press_scale.dart';

class HomeStartButton extends StatelessWidget {
  const HomeStartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PressScale(
      child: SizedBox(
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
      ),
    );
  }
}
