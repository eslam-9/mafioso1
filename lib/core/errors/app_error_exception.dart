import 'app_error.dart';

class AppErrorException implements Exception {
  final AppError error;

  const AppErrorException(this.error);

  @override
  String toString() => 'AppErrorException(${error.key})';
}

