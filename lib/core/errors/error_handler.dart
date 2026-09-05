import '../utils/logger.dart';
import 'app_error.dart';
import 'app_error_exception.dart';

class ErrorHandler {
  static AppError toAppError(dynamic error, {String? context}) {
    if (error is AppErrorException) return error.error;

    if (context != null && context.startsWith('error_')) {
      return AppError(context);
    }

    final directKey = _tryExtractDirectKey(error);
    if (directKey != null) return AppError(directKey);

    final inferred = _inferKey(error);
    return inferred;
  }

  static bool isRecoverable(AppError error) {
    return error.key == 'error_no_internet' ||
        error.key == 'error_request_timeout' ||
        error.key == 'error_server_error' ||
        error.key == 'error_invalid_json' ||
        error.key == 'error_api_failed_code';
  }

  static void logError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
  }) {
    AppLogger.logError(context ?? 'Unknown', error, stackTrace: stackTrace);
  }

  static AppError _inferKey(dynamic error) {
    final errorString = error.toString();
    final lower = errorString.toLowerCase();

    final dioStatusCode = _tryExtractHttpStatusCode(errorString);
    if (dioStatusCode != null) {
      if (dioStatusCode == 401 || dioStatusCode == 403) {
        return const AppError('error_auth_failed');
      }
      if (dioStatusCode == 404) return const AppError('error_not_found');
      if (dioStatusCode >= 500 && dioStatusCode < 600) {
        return const AppError('error_server_error');
      }
      if (dioStatusCode >= 400) {
        return AppError(
          'error_api_failed_code',
          namedArgs: {'code': dioStatusCode.toString()},
        );
      }
    }

    if (lower.contains('socketexception') ||
        lower.contains('network') ||
        lower.contains('connection') ||
        lower.contains('failed host lookup') ||
        lower.contains('name not resolved') ||
        lower.contains('dns')) {
      return const AppError('error_no_internet');
    }

    if (lower.contains('timeout') ||
        lower.contains('timed out') ||
        lower.contains('connecttimeout') ||
        lower.contains('receivetimeout') ||
        lower.contains('sendtimeout')) {
      return const AppError('error_request_timeout');
    }

    if (lower.contains('format') || lower.contains('json')) {
      return const AppError('error_invalid_json');
    }

    if (lower.contains('invalid') ||
        lower.contains('validation') ||
        lower.contains('required') ||
        lower.contains('missing')) {
      return const AppError('error_invalid_data');
    }

    if (lower.contains('permission') || lower.contains('denied')) {
      return const AppError('error_permission_denied');
    }

    return const AppError('error_unexpected');
  }

  static int? _tryExtractHttpStatusCode(String errorString) {
    // Common Dio message: "DioException [bad response]: ... status code: 401"
    final match = RegExp(
      r'status code:\\s*(\\d{3})',
      caseSensitive: false,
    ).firstMatch(errorString);
    if (match == null) return null;
    return int.tryParse(match.group(1) ?? '');
  }

  static String? _tryExtractDirectKey(dynamic error) {
    if (error is String && error.trim().startsWith('error_')) return error;

    if (error is ArgumentError) {
      final message = error.message;
      if (message is String && message.trim().startsWith('error_')) {
        return message.trim();
      }
    }

    if (error is StateError && error.message.trim().startsWith('error_')) {
      return error.message.trim();
    }

    if (error is FormatException && error.message.trim().startsWith('error_')) {
      return error.message.trim();
    }

    return null;
  }
}
