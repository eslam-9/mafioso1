import 'package:flutter/foundation.dart';

class AppLogger {
  static void logNavigation(String route) {
    if (kDebugMode) {
      debugPrint('🧭 [Navigation] Navigating to: $route');
    }
  }

  static void logApiCall(String endpoint, {Map<String, dynamic>? params}) {
    if (kDebugMode) {
      debugPrint('🌐 [API] Calling: $endpoint');
      if (params != null) {
        debugPrint('🌐 [API] Params: $params');
      }
    }
  }

  static void logBlocEvent(String blocName, String eventName) {
    if (kDebugMode) {
      debugPrint('📦 [BLoC] $blocName - Event: $eventName');
    }
  }

  static void logBlocState(String blocName, String stateName) {
    if (kDebugMode) {
      debugPrint('📦 [BLoC] $blocName - State: $stateName');
    }
  }

  static void logError(String context, Object error, {StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('❌ [Error] $context: $error');
      if (stackTrace != null) {
        debugPrint('❌ [Error] StackTrace: $stackTrace');
      }
    }
  }

  static void logInfo(String message) {
    if (kDebugMode) {
      debugPrint('ℹ️ [Info] $message');
    }
  }
}
