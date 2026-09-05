# 05 — Error Handling

## Overview
Multi-layered error handling system with localization support. Errors flow from data layer → domain → presentation → UI.

## Error Classes

### 1. AppError (`core/errors/app_error.dart`)
```dart
class AppError extends Equatable {
  final String key;           // Localization key, e.g., 'error_no_internet'
  final Map<String, String> namedArgs; // For localized string interpolation
  
  const AppError(this.key, {Map<String, String>? namedArgs});
}
```
**Purpose**: Domain-level error representation. Framework-agnostic.

### 2. AppErrorException (`core/errors/app_error_exception.dart`)
```dart
class AppErrorException implements Exception {
  final AppError error;
  const AppErrorException(this.error);
}
```
**Purpose**: Wraps `AppError` as a throwable exception for use in try/catch blocks.

### 3. ErrorHandler (`core/errors/error_handler.dart`)
Static utility with two key methods:

```dart
// Convert any exception to AppError
static AppError toAppError(Object error) {
  // Pattern matching on error types:
  // - SocketException → error_no_internet
  // - TimeoutException → error_request_timeout
  // - DioException → based on status code
  // - FormatException → error_invalid_json
  // - PostgrestException → error_auth_failed
  // - Default → error_unknown
}

// Log with context
static void logError(Object error, {StackTrace? stackTrace, String? context}) {
  AppLogger.logError(context ?? 'ErrorHandler', error, stackTrace: stackTrace);
}
```

### 4. AppErrorLocalizer (`shared/errors/app_error_localizer.dart`)
Maps error keys to localized strings via `easy_localization`:
```dart
String localizeError(AppError error) {
  return tr(error.key, args: error.namedArgs.values);
}
```

## Error Flow

```
Data Source (Dio/Supabase/Hive)
    ↓ throws exception
Repository Impl
    ↓ catch, rethrow or wrap
UseCase
    ↓ may throw AppErrorException
BLoC
    ↓ catch → ErrorHandler.toAppError(e) → emit error state
UI
    ↓ show SnackBar or error widget with localized message
```

## Error Keys (from translations)
| Key | EN | AR |
|-----|-----|-----|
| `error_no_internet` | No internet connection | لا يوجد اتصال بالإنترنت |
| `error_request_timeout` | Request timed out | انتهت مهلة الطلب |
| `error_server_error` | Server error | خطأ في الخادم |
| `error_invalid_json` | Invalid data format | تنسيق البيانات غير صالح |
| `error_auth_failed` | Authentication failed | فشل المصادقة |
| `error_empty_votes` | No votes submitted | لم يتم تقديم أصوات |
| `error_player_not_found` | Player not found | لم يتم العثور على اللاعب |
| `error_unknown` | Unknown error | خطأ غير معروف |

## BLoC Error Handling Pattern
```dart
try {
  final result = await useCase();
  emit(state.copyWith(data: result, error: null));
} catch (e, stackTrace) {
  AppLogger.logError('BlocName', e, stackTrace: stackTrace);
  ErrorHandler.logError(e, stackTrace: stackTrace, context: 'BlocName.handler');
  emit(state.copyWith(error: ErrorHandler.toAppError(e)));
}
```

## UI Error Display Patterns

### SnackBar (Transient Errors)
```dart
if (state.error != null) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppErrorLocalizer.localize(state.error!))),
    );
  });
}
```

### Dedicated Error Widgets (Full-Screen Errors)
```dart
// StoryErrorWidget, etc.
if (state is StoryHistoryError) {
  return Center(child: Text((state as StoryHistoryError).message));
}
```

## Recoverable vs Non-Recoverable
The `ErrorHandler` determines if errors are recoverable:
- **Recoverable**: No internet, timeout — user can retry
- **Non-Recoverable**: Invalid data, auth failure — user must take different action
