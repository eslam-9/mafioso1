import 'package:easy_localization/easy_localization.dart';

import '../../core/errors/app_error.dart';

class AppErrorLocalizer {
  static String localize(AppError error) {
    if (error.namedArgs.isEmpty) return error.key.tr();
    return error.key.tr(namedArgs: error.namedArgs);
  }
}

