import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/route_names.dart';

class HomeSavedStoriesButton extends StatelessWidget {
  const HomeSavedStoriesButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.book_outlined),
      label: Text('saved_stories'.tr()),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(250.w, 48.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () => Navigator.pushNamed(context, RouteNames.savedStories),
    );
  }
}
