import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppLocalization {
  static Future<void> init() async {
    await EasyLocalization.ensureInitialized();
  }

  static List<Locale> get supportedLocales => const [
        Locale('ar'),
        Locale('en'),
      ];
}
