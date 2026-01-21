import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mafioso/core/theme/app_colors.dart';
import 'package:mafioso/core/theme/app_spacing.dart';
import 'package:mafioso/core/theme/theme_cubit.dart';

class ThemeSwitchButton extends StatelessWidget {
  const ThemeSwitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        var mode = state.mode;
        return IconButton(
          onPressed: () {
            context.read<ThemeCubit>().toggleTheme();
          },
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                (mode == AppThemeMode.light)
                    ? Icons.dark_mode
                    : Icons.light_mode,
                color: Theme.of(context).colorScheme.primary,
                size: 24.sp,
              ),
            ],
          ),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.charcoal.withOpacity(0.7),
            padding: EdgeInsets.all(12.w),
            minimumSize: Size(
              AppSpacing.minTouchTarget,
              AppSpacing.minTouchTarget,
            ),
          ),
          tooltip: 'Switch to ',
        );
      },
    );
  }
}
