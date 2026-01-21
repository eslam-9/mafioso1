import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/localization/language_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class LanguageSwitcherButton extends StatelessWidget {
  const LanguageSwitcherButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, state) {
        final currentLang = state.locale.languageCode;
        final newLang = currentLang == 'ar' ? 'en' : 'ar';
        return IconButton(
          onPressed: () {
            final newLocale = Locale(newLang);
            context.read<LanguageCubit>().setLanguage(newLocale);
            context.setLocale(newLocale);
          },
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                newLang.toUpperCase() == "AR" ? "EN" : "AR",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.language,
                color: Theme.of(context).colorScheme.primary,
                size: 24.sp,
              ),
            ],
          ),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surface.withOpacity(0.7),
            padding: EdgeInsets.all(12.w),
            minimumSize: Size(
              AppSpacing.minTouchTarget,
              AppSpacing.minTouchTarget,
            ),
          ),
          tooltip: 'Switch to $newLang',
        );
      },
    );
  }
}
