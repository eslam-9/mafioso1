import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  static const String _key = 'app_theme_mode';

  ThemeCubit()
    : super(ThemeState(themeData: DarkTheme.theme, mode: AppThemeMode.dark)) {
    load();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_key);
    if (savedMode == null) return;

    final mode = AppThemeMode.values.byName(savedMode);
    _emitMode(mode);
  }

  void toggleTheme() {
    final newMode =
        state.mode == AppThemeMode.dark ? AppThemeMode.light : AppThemeMode.dark;
    setTheme(newMode);
  }

  void setTheme(AppThemeMode mode) {
    _emitMode(mode);
    _save(mode);
  }

  void _emitMode(AppThemeMode mode) {
    if (mode == AppThemeMode.light) {
      emit(ThemeState(themeData: LightTheme.theme, mode: AppThemeMode.light));
      return;
    }
    emit(ThemeState(themeData: DarkTheme.theme, mode: AppThemeMode.dark));
  }

  Future<void> _save(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}
