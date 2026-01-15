import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/theme/app_spacing.dart';

import '../widgets/home_title.dart';
import '../widgets/home_subtitle.dart';
import '../widgets/home_start_button.dart';
import '../widgets/home_how_to_play_button.dart';
import '../widgets/home_footer.dart';
import '../widgets/language_switcher_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.logNavigation(RouteNames.home);

    return Scaffold(
      body: Builder(
        builder: (context) {
          // Access context.locale to make this widget rebuild on language change
          final _ = context.locale;

          return SafeArea(
            child: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(AppSpacing.pagePadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const HomeTitle(),
                        SizedBox(height: AppSpacing.medium),
                        const HomeSubtitle(),
                        SizedBox(height: AppSpacing.xxlarge),
                        HomeStartButton(),
                        SizedBox(height: AppSpacing.large),
                        HomeHowToPlayButton(),
                        SizedBox(height: AppSpacing.xxlarge),
                        const HomeFooter(),
                      ],
                    ),
                  ),
                ),
                const LanguageSwitcherButton(),
              ],
            ),
          );
        },
      ),
    );
  }
}
