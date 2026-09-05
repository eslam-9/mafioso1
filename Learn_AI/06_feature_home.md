# 06 — Feature: Home Screen

## Overview
The landing screen of the app. Provides entry points to all major features: start game, how-to-play, saved stories, and community library.

## OOB (Out-of-the-Box) Behavior
- Displays app title and subtitle
- "Start Game" button → navigates to game mode selection
- "How to Play" button → shows dialog with game rules
- "Saved Stories" button → navigates to local story history
- "Community Library" button → navigates to Supabase community stories
- Theme toggle button (dark/light)
- Language toggle button (AR/EN)
- Footer with version info

## Architecture
**Presentation only** — no domain or data layers needed.

```
home/
└── presentation/
    ├── pages/
    │   └── home_page.dart
    └── widgets/
        ├── home_title.dart
        ├── home_subtitle.dart
        ├── home_start_button.dart
        ├── home_how_to_play_button.dart
        ├── home_saved_stories_button.dart
        ├── home_community_library_button.dart
        ├── home_footer.dart
        ├── how_to_play_dialog.dart
        ├── how_to_play_item.dart
        ├── theme_switch_button.dart
        └── language_switcher_button.dart
```

## Design Patterns
- **Composition Pattern**: Home page is composed of many small, focused widgets
- **PressScale Widget**: All buttons use shared `PressScale` for consistent tap feedback

## SOLID Principles
- **Single Responsibility**: Each widget handles one UI element
- **Open/Closed**: New home buttons can be added without modifying existing widgets
- **Dependency Inversion**: Uses `context.read<ThemeCubit>()` and `context.read<LanguageCubit>()` — depends on abstractions

## Key Files
| File | Responsibility |
|------|---------------|
| `home_page.dart` | Layout composition of all home widgets |
| `home_start_button.dart` | Primary CTA with PressScale animation |
| `how_to_play_dialog.dart` | Dialog with game rules (localized) |
| `theme_switch_button.dart` | Toggles ThemeCubit |
| `language_switcher_button.dart` | Toggles LanguageCubit + EasyLocalization |

## Data Flow
```
User taps button → Navigator.pushNamed(context, routeName)
User taps theme → context.read<ThemeCubit>().toggleTheme()
User taps language → context.read<LanguageCubit>().setLanguage(locale)
```

## Edge Cases
- Language change: Cubit syncs with `EasyLocalization` locale
- Theme persistence: ThemeCubit reads/writes to SharedPreferences
