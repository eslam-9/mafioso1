import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/di/injection_container.dart' as di;
import 'core/localization/app_localization.dart';
import 'core/services/auth_service.dart';

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/story_history/data/models/played_story_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Catch Flutter framework errors and send to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Local storage
  await Hive.initFlutter();
  Hive.registerAdapter(PlayedStoryModelAdapter());

  // Remote backend
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    publishableKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  await AppLocalization.init();

  await di.init();
  
  await di.getIt<AuthService>().signInAnonymouslyIfNeeded();
  
  runApp(
    EasyLocalization(
      startLocale: const Locale('ar'),
      supportedLocales: AppLocalization.supportedLocales,
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      child: const MafiosoApp(),
    ),
  );
}
