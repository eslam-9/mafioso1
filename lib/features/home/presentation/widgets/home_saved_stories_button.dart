import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mafioso/core/constants/route_names.dart';
import 'package:mafioso/core/utils/logger.dart';

class HomeSavedStoriesButton extends StatelessWidget {
  const HomeSavedStoriesButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250.w,
      child: OutlinedButton(
        onPressed: () {
          AppLogger.logNavigation(RouteNames.savedStories);
          Navigator.pushNamed(context, RouteNames.savedStories);
        },
        child: Text('saved_stories'.tr()),
      ),
    );
  }
}
