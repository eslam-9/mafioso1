import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/widgets/press_scale.dart';

class OnlineModeSelectionPage extends StatelessWidget {
  const OnlineModeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.logNavigation(RouteNames.onlineMode);

    return Scaffold(
      appBar: AppBar(title: Text('play_online'.tr())),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PressScale(
              child: SizedBox(
                width: 250.w,
                child: ElevatedButton(
                  onPressed: () {
                    AppLogger.logNavigation(RouteNames.createRoom);
                    Navigator.pushNamed(context, RouteNames.createRoom);
                  },
                  child: Text('create_room'.tr()),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            PressScale(
              child: SizedBox(
                width: 250.w,
                child: OutlinedButton(
                  onPressed: () {
                    AppLogger.logNavigation(RouteNames.joinRoom);
                    Navigator.pushNamed(context, RouteNames.joinRoom);
                  },
                  child: Text('join_room'.tr()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
