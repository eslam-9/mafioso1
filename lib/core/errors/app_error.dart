import 'package:equatable/equatable.dart';

class AppError extends Equatable {
  final String key;
  final Map<String, String> namedArgs;

  const AppError(this.key, {Map<String, String>? namedArgs})
      : namedArgs = namedArgs ?? const {};

  @override
  List<Object?> get props => [key, namedArgs];
}

