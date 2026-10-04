import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/widgets/press_scale.dart';

class HomePlayOnlineButton extends StatelessWidget {
  const HomePlayOnlineButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PressScale(
      child: SizedBox(
        width: 250.w,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
          ),
          onPressed: () {
            AppLogger.logNavigation(RouteNames.onlineMode);
            Navigator.pushNamed(context, RouteNames.onlineMode);
          },
          child: Text('play_online'.tr()),
        ),
      ),
    );
  }
}
