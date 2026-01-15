import 'package:flutter/foundation.dart';

class AppLogger {
  static void logNavigation(String route) {
    if (kDebugMode) {
      print('🧭 [Navigation] Navigating to: $route');
    }
  }

  static void logApiCall(String endpoint, {Map<String, dynamic>? params}) {
    if (kDebugMode) {
      print('🌐 [API] Calling: $endpoint');
      if (params != null) {
        print('🌐 [API] Params: $params');
      }
    }
  }

  static void logBlocEvent(String blocName, String eventName) {
    if (kDebugMode) {
      print('📦 [BLoC] $blocName - Event: $eventName');
    }
  }

  static void logBlocState(String blocName, String stateName) {
    if (kDebugMode) {
      print('📦 [BLoC] $blocName - State: $stateName');
    }
  }

  static void logError(String context, Object error, {StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('❌ [Error] $context: $error');
      if (stackTrace != null) {
        print('❌ [Error] StackTrace: $stackTrace');
      }
    }
  }

  static void logInfo(String message) {
    if (kDebugMode) {
      print('ℹ️ [Info] $message');
    }
  }
}
