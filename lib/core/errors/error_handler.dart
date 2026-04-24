import 'package:easy_localization/easy_localization.dart';
import '../utils/logger.dart';

class ErrorHandler {
  static String getUserMessage(dynamic error, {String? context}) {
    final directMessage = _tryExtractDirectMessage(error);
    if (directMessage != null) return directMessage;

    final translation = _inferTranslation(error, context: context);
    if (translation.namedArgs == null) return translation.key.tr();
    return translation.key.tr(namedArgs: translation.namedArgs!);
  }

  static bool isRecoverable(dynamic error) {
    final key = _inferTranslation(error, context: null).key;
    return key == 'error_no_internet' ||
        key == 'error_request_timeout' ||
        key == 'error_server_error' ||
        key == 'error_invalid_json' ||
        key == 'error_api_failed_code';
  }

  static void logError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
  }) {
    AppLogger.logError(context ?? 'Unknown', error, stackTrace: stackTrace);
  }

  static _Translation _inferTranslation(dynamic error, {String? context}) {
    if (context != null && context.startsWith('error_')) {
      return _Translation(context);
    }

    final errorString = error.toString();
    final lower = errorString.toLowerCase();

    final dioStatusCode = _tryExtractHttpStatusCode(errorString);
    if (dioStatusCode != null) {
      if (dioStatusCode == 401 || dioStatusCode == 403) {
        return const _Translation('error_auth_failed');
      }
      if (dioStatusCode == 404) return const _Translation('error_not_found');
      if (dioStatusCode >= 500 && dioStatusCode < 600) {
        return const _Translation('error_server_error');
      }
      if (dioStatusCode >= 400) {
        return _Translation(
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
      return const _Translation('error_no_internet');
    }

    if (lower.contains('timeout') ||
        lower.contains('timed out') ||
        lower.contains('connecttimeout') ||
        lower.contains('receivetimeout') ||
        lower.contains('sendtimeout')) {
      return const _Translation('error_request_timeout');
    }

    if (lower.contains('format') || lower.contains('json')) {
      return const _Translation('error_invalid_json');
    }

    if (lower.contains('invalid') ||
        lower.contains('validation') ||
        lower.contains('required') ||
        lower.contains('missing')) {
      return const _Translation('error_invalid_data');
    }

    if (lower.contains('permission') || lower.contains('denied')) {
      return const _Translation('error_permission_denied');
    }

    return const _Translation('error_unexpected');
  }

  static int? _tryExtractHttpStatusCode(String errorString) {
    // Common Dio message: "DioException [bad response]: ... status code: 401"
    final match = RegExp(r'status code:\\s*(\\d{3})', caseSensitive: false)
        .firstMatch(errorString);
    if (match == null) return null;
    return int.tryParse(match.group(1) ?? '');
  }

  static String? _tryExtractDirectMessage(dynamic error) {
    if (error is String && error.trim().isNotEmpty) return error;

    if (error is ArgumentError) {
      final message = error.message;
      if (message is String && message.trim().isNotEmpty) return message;
    }

    if (error is StateError && error.message.trim().isNotEmpty) {
      return error.message;
    }

    if (error is FormatException && error.message.trim().isNotEmpty) {
      return error.message;
    }

    return null;
  }
}

class _Translation {
  final String key;
  final Map<String, String>? namedArgs;

  const _Translation(this.key, {this.namedArgs});
}

