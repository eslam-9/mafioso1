# Theming Documentation

This project uses a robust theming system built on Flutter's `ThemeData`, managed by `flutter_bloc` for state management, and customized with specific color palettes and typography.

## Architecture

The theming system follows the Clean Architecture principles used throughout the app, located in `lib/core/theme`.

- **State Management**: `ThemeCubit` controls the current theme mode (Light/Dark).
- **Theme Definitions**: Separate classes (`LightTheme`, `DarkTheme`) define the specific `ThemeData` for each mode.
- **Persistence**: Currently, the theme defaults to Dark mode on app start (as seen in `ThemeCubit`'s initial state).

### Directory Structure

```
lib/core/theme/
├── app_colors.dart     # Centralized color palette
├── app_spacing.dart    # Spacing and layout constants
├── light_theme.dart    # Light theme configuration
├── dark_theme.dart     # Dark theme configuration
└── theme_cubit.dart    # State management for theme switching
```

## Theme Definitions

### App Colors (`app_colors.dart`)
All colors used in the app are defined as static constants in `AppColors`. This ensures consistency and makes it easy to update the brand colors globally.

**Key Colors:**
- `primaryRed`: `#8B0000`
- `bloodRed`: `#DC143C` (Used for errors and highlights)
- `deepBlack`: `#0A0A0A` (Dark background)
- `charcoal`: `#1A1A1A` (Dark surface/card)

### Typography
The app uses **Google Fonts Crimson Text** as the primary font family. This is applied globally via the `textTheme` in both `LightTheme` and `DarkTheme`.

## Usage

### Accessing the Theme
You can access the current theme data using the standard Flutter context utility:

```dart
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;
```

### Switching Themes
To toggle between Light and Dark modes, use the `ThemeCubit`.

```dart
context.read<ThemeCubit>().toggleTheme();
```

Or to set a specific mode:

```dart
context.read<ThemeCubit>().setTheme(AppThemeMode.dark);
```

### Custom Extensions
The definitions include static helpers for complex decorations like gradients, which are not part of standard `ThemeData`.

**Example: Background Gradient**
```dart
Container(
  decoration: Theme.of(context).brightness == Brightness.dark
      ? DarkTheme.backgroundGradient
      : LightTheme.backgroundGradient,
  child: ...
)
```

## Adding New Styles

1.  **New Color**: Add the color definition to `lib/core/theme/app_colors.dart`.
2.  **Component Theme**: To style a Material component globally (e.g., `Checkbox`), update the `ThemeData` within `light_theme.dart` and `dark_theme.dart` by adding the corresponding theme data (e.g., `checkboxTheme: ...`).

## Setup in App
The theme is injected at the root of the application in `lib/app.dart` using `MultiBlocProvider` and `MaterialApp`:

```dart
BlocBuilder<ThemeCubit, ThemeState>(
  builder: (context, themeState) {
    return MaterialApp(
      // ...
      theme: themeState.themeData,
      // ...
    );
  },
);
```
