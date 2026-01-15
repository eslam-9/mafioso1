import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dark_theme.dart';
import 'light_theme.dart';
import 'package:flutter/material.dart';

enum AppThemeMode { light, dark }

class ThemeState extends Equatable {
  final ThemeData themeData;
  final AppThemeMode mode;

  const ThemeState({required this.themeData, required this.mode});

  ThemeState copyWith({ThemeData? themeData, AppThemeMode? mode}) {
    return ThemeState(
      themeData: themeData ?? this.themeData,
      mode: mode ?? this.mode,
    );
  }

  @override
  List<Object> get props => [themeData, mode];
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
    : super(ThemeState(themeData: DarkTheme.theme, mode: AppThemeMode.dark));

  void toggleTheme() {
    if (state.mode == AppThemeMode.dark) {
      emit(ThemeState(themeData: LightTheme.theme, mode: AppThemeMode.light));
    } else {
      emit(ThemeState(themeData: DarkTheme.theme, mode: AppThemeMode.dark));
    }
  }

  void setTheme(AppThemeMode mode) {
    if (mode == AppThemeMode.light) {
      emit(ThemeState(themeData: LightTheme.theme, mode: AppThemeMode.light));
    } else {
      emit(ThemeState(themeData: DarkTheme.theme, mode: AppThemeMode.dark));
    }
  }
}
