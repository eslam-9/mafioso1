import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'app.dart';
import 'core/di/injection_container.dart' as di;
import 'core/localization/app_localization.dart';

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/story_history/data/models/played_story_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Local storage
  await Hive.initFlutter();
  Hive.registerAdapter(PlayedStoryModelAdapter());

  // Remote backend
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

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
