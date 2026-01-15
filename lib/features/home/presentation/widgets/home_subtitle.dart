import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';

class HomeSubtitle extends StatelessWidget {
  const HomeSubtitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'app_subtitle'.tr(),
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.lightGray,
            letterSpacing: 2,
          ),
    ).animate().fadeIn(delay: 400.ms);
  }
}
