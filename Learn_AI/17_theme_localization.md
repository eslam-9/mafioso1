# 17 — Theme & Localization

## Theme System

### Architecture
```
core/theme/
├── app_colors.dart        # Color constants
├── app_spacing.dart       # Spacing constants
├── dark_theme.dart        # Dark ThemeData
├── light_theme.dart       # Light ThemeData
└── theme_cubit.dart       # Theme state management
```

### Color Palette
```dart
class AppColors {
  // Primary — Blood Red theme
  static const primary = Color(0xFF8B0000);      // Dark red
  static const primaryDark = Color(0xFF5C0000);  // Deeper red
  static const accent = Color(0xFFDC143C);       // Crimson
  
  // Backgrounds
  static const background = Color(0xFF0A0A0A);   // Near black
  static const surface = Color(0xFF1A1A1A);      // Dark gray
  static const surfaceLight = Color(0xFF2A2A2A); // Lighter gray
  
  // Text
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB0B0B0);
}
```

### Spacing System
```dart
class AppSpacing {
  static const double pagePadding = 16.0;
  static const double small = 4.0;
  static const double medium = 8.0;
  static const double large = 16.0;
  static const double xlarge = 24.0;
  static const double xxlarge = 32.0;
}
```

### Theme Toggle
```dart
class ThemeCubit extends Cubit<ThemeState> {
  void toggleTheme() {
    final newMode = state.themeMode == ThemeMode.dark 
        ? ThemeMode.light : ThemeMode.dark;
    emit(ThemeState(themeData: _getTheme(newMode)));
    _prefs.setString('app_theme_mode', newMode.name);
  }
}
```

### Default: Dark Theme
The app defaults to dark theme, matching the murder-mystery aesthetic.

---

## Localization System

### Architecture
```
core/localization/
├── app_localization.dart   # Supported locales config
└── language_cubit.dart     # Language state management

assets/translations/
├── ar.json                 # Arabic (Egyptian dialect)
└── en.json                 # English
```

### Setup
```dart
// main.dart
await AppLocalization.init();
runApp(
  EasyLocalization(
    supportedLocales: AppLocalization.supportedLocales,
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    child: const MafiosoApp(),
  ),
);
```

### Supported Locales
```dart
class AppLocalization {
  static const supportedLocales = [
    Locale('en'),
    Locale('ar'),
  ];
}
```

### Language Cubit
```dart
class LanguageCubit extends Cubit<LanguageState> {
  void setLanguage(Locale locale) {
    emit(LanguageState(locale: locale));
    EasyLocalization.of(context)?.setLocale(locale);
  }
}
```

### Usage in Code
```dart
// String localization
Text('app_title'.tr())
Text('start_game'.tr())

// With arguments
Text('error_with_arg'.tr(args: ['value']))

// Pluralization (in JSON)
"items_count": "{count} items"
```

### Arabic-Specific Considerations
- **RTL Support**: MaterialApp handles RTL automatically when locale is 'ar'
- **Font**: Marhey font family for Arabic (weights 300-700)
- **Font**: Crimson Text for English (via Google Fonts)
- **Dynamic Font Scaling**: Arabic text uses different scaling than English

### Translation Keys Structure
```json
{
  "app_title": "Mafioso",
  "start_game": "Start Game",
  "how_to_play": "How to Play",
  "game_over": "Game Over",
  "innocents_win": "The Innocents Win!",
  "killer_wins": "The Killer Wins!",
  "error_no_internet": "No internet connection",
  // ... 100+ keys
}
```
