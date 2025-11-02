import 'package:flutter/foundation.dart';

/// Error handling utility for the application
class ErrorHandler {
  /// Converts technical errors to user-friendly messages
  static String getUserMessage(dynamic error, {String? context}) {
    if (error is String) {
      return _parseErrorMessage(error);
    }

    if (error is Exception) {
      return _parseException(error, context: context);
    }

    // Generic fallback
    if (context != null) {
      return 'حصل خطأ أثناء $context. حاول تاني.';
    }

    return 'حصل خطأ مش متوقع. حاول تاني.';
  }

  /// Parse string error messages
  static String _parseErrorMessage(String error) {
    // Network errors
    if (error.toLowerCase().contains('network') ||
        error.toLowerCase().contains('connection')) {
      return 'مش قادرين نتصل. اتأكد من النت.';
    }

    if (error.toLowerCase().contains('timeout')) {
      return 'الطلب خد وقت كتير. حاول تاني.';
    }

    // API errors
    if (error.toLowerCase().contains('api') ||
        error.toLowerCase().contains('gemini')) {
      return 'مش قادرين نعمل قصة. هنستخدم القصص الأوفلاين.';
    }

    // Validation errors
    if (error.toLowerCase().contains('invalid') ||
        error.toLowerCase().contains('validation')) {
      return 'البيانات مش صح. راجع اللي كتبته.';
    }

    // Permission errors
    if (error.toLowerCase().contains('permission') ||
        error.toLowerCase().contains('denied')) {
      return 'الإذن مرفوض. راجع الإعدادات.';
    }

    return error;
  }

  /// Parse exceptions to user-friendly messages
  static String _parseException(Exception error, {String? context}) {
    final errorString = error.toString().toLowerCase();

    // Network-related exceptions
    if (errorString.contains('socketexception') ||
        errorString.contains('connection')) {
      return 'مفيش نت. هنستخدم القصص الأوفلاين.';
    }

    if (errorString.contains('timeout')) {
      return 'الطلب خد وقت كتير. حاول تاني.';
    }

    // HTTP exceptions
    if (errorString.contains('404')) {
      return 'الحاجة اللي طلبتها مش موجودة.';
    }

    if (errorString.contains('401') || errorString.contains('403')) {
      return 'المصادقة فشلت. اتأكد من الـ API key.';
    }

    if (errorString.contains('500') || errorString.contains('502') || errorString.contains('503')) {
      return 'خطأ في السيرفر. حاول بعدين.';
    }

    // Format exceptions
    if (errorString.contains('format') || errorString.contains('json')) {
      return 'مش قادرين نقرا الرد. حاول تاني.';
    }

    // Generic exception with context
    if (context != null) {
      return 'فشل $context. حاول تاني.';
    }

    return 'حصل خطأ. حاول تاني.';
  }

  /// Check if error is recoverable
  static bool isRecoverable(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Network errors are usually recoverable
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      return true;
    }

    // Server errors might be temporary
    if (errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503')) {
      return true;
    }

    // Format errors might be recoverable
    if (errorString.contains('format') || errorString.contains('json')) {
      return true;
    }

    return false;
  }

  /// Log error for debugging (in production, use proper logging)
  static void logError(dynamic error, {StackTrace? stackTrace, String? context}) {
    // In production, integrate with proper logging service (e.g., Firebase Crashlytics)
    if (context != null) {
      debugPrint('Error in $context: $error');
    } else {
      debugPrint('Error: $error');
    }

    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
  }
}

