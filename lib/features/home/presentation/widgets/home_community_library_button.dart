import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mafioso/core/constants/route_names.dart';
import 'package:mafioso/core/utils/logger.dart';

class HomeCommunityLibraryButton extends StatelessWidget {
  const HomeCommunityLibraryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250.w,
      child: OutlinedButton(
        onPressed: () {
          AppLogger.logNavigation(RouteNames.communityLibrary);
          Navigator.pushNamed(context, RouteNames.communityLibrary);
        },
        child: Text('community_library'.tr()),
      ),
    ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.3, end: 0);
  }
}
