import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:easy_localization/easy_localization.dart';
import 'app.dart';
import 'core/di/injection_container.dart' as di;
import 'core/localization/app_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await AppLocalization.init();
  await di.init();
  runApp(
    EasyLocalization(
      supportedLocales: AppLocalization.supportedLocales,
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MafiosoApp(),
    ),
  );
}
