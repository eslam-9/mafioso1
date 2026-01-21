import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';

class HomeTitle extends StatelessWidget {
  const HomeTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'app_title'.tr(),
      style: Theme.of(context).textTheme.displayLarge?.copyWith(
        fontSize: 72.sp,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: 8,
        shadows: [
          Shadow(
            color: AppColors.primaryRed.withOpacity(0.8),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).scale(delay: 200.ms);
  }
}
