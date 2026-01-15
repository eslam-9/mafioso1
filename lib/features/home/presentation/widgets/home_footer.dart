import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';

class HomeFooter extends StatelessWidget {
  const HomeFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'footer_question'.tr(),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppColors.lightGray.withOpacity(0.8),
        fontStyle: FontStyle.italic,
      ),
    ).animate().fadeIn(delay: 1000.ms);
  }
}
