import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/theme_cubit.dart';
import 'core/routing/route_generator.dart';
import 'core/localization/app_localization.dart';
import 'core/localization/language_cubit.dart';

class MafiosoApp extends StatelessWidget {
  const MafiosoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => ThemeCubit()),
            BlocProvider(create: (context) => LanguageCubit()),
          ],
          child: Builder(
            builder: (context) {
              final locale = context.locale;
              final languageCubit = context.read<LanguageCubit>();
              if (languageCubit.state.locale != locale) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  languageCubit.setLanguage(locale);
                });
              }
              return BlocBuilder<LanguageCubit, LanguageState>(
                builder: (context, languageState) {
                  return BlocBuilder<ThemeCubit, ThemeState>(
                    builder: (context, themeState) {
                      return MaterialApp(
                        title: 'app_title'.tr(),
                        theme: themeState.themeData,
                        debugShowCheckedModeBanner: false,
                        locale: languageState.locale,
                        supportedLocales: AppLocalization.supportedLocales,
                        localizationsDelegates: [
                          GlobalMaterialLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                          EasyLocalization.of(context)!.delegate,
                        ],
                        onGenerateRoute: RouteGenerator.generateRoute,
                        initialRoute: '/',
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
