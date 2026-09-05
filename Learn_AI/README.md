# Learn AI — Mafioso Documentation

> **Purpose**: This folder serves as a comprehensive documentary for any AI or developer continuing work on the Mafioso Flutter app. Every feature, design pattern, SOLID principle application, and architectural decision is documented here.

---

## Project Overview

**Mafioso** is a local multiplayer murder-mystery party game built with Flutter. It features AI-generated stories (Google Gemini and/or Groq) with offline fallback, a complete game loop (setup → story → role reveal → investigation → voting → results), local story history with ratings, and a community library backed by Supabase.

### Quick Stats
- **Flutter SDK**: ^3.8.1
- **Architecture**: Clean Architecture (Feature-First)
- **State Management**: BLoC Pattern (flutter_bloc)
- **Dependency Injection**: GetIt
- **Navigation**: Imperative (onGenerateRoute)
- **Local Storage**: Hive CE
- **Backend**: Supabase
- **Localization**: Arabic (Egyptian) + English

---

## Table of Contents

| File | Content |
|------|---------|
| `01_architecture.md` | Overall architecture, folder structure, layer responsibilities |
| `02_state_management.md` | BLoC pattern, all BLoCs/Cubits, events, states |
| `03_dependency_injection.md` | GetIt setup, registration patterns, service locator |
| `04_navigation.md` | Route system, navigation flow, route arguments |
| `05_error_handling.md` | Error system, localization, recovery strategies |
| `06_feature_home.md` | Home screen feature |
| `07_feature_game_setup.md` | Player setup & game configuration |
| `08_feature_story_generation.md` | AI story generation with fallback |
| `09_feature_role_reveal.md` | Sequential role reveal system |
| `10_feature_gameplay.md` | Game loop, clues, voting, rounds |
| `11_feature_summary.md` | Game results, stats, rating, save |
| `12_feature_story_history.md` | Local saved stories, CRUD, ratings |
| `13_feature_story_library.md` | Community library, Supabase, uploads |
| `14_design_patterns.md` | All design patterns used with examples |
| `15_solid_principles.md` | SOLID principles application throughout |
| `16_core_services.md` | Connectivity, Sound, UploadQueue, DeviceId |
| `17_theme_localization.md` | Theming system and localization setup |
| `18_production_readiness.md` | Production assessment, gaps, recommendations |

---

## Architecture Pattern: Clean Architecture (Feature-First)

```
lib/
├── main.dart                    # Entry point — initializes Hive, Supabase, DI, Localization
├── app.dart                     # Root MaterialApp with ScreenUtil, BLoC providers
├── core/                        # Cross-cutting concerns
│   ├── ai_provider/             # AI provider enum (gemini, groq)
│   ├── constants/               # Route name constants
│   ├── di/                      # Dependency injection (GetIt)
│   ├── errors/                  # Error handling system
│   ├── localization/            # i18n setup, LanguageCubit
│   ├── routing/                 # Route generator (onGenerateRoute)
│   ├── services/                # Core services (DeviceIdService)
│   ├── theme/                   # Dark/Light themes, colors, spacing, ThemeCubit
│   └── utils/                   # Logger utility
├── features/                    # Feature modules
│   ├── game_result/             # Gameplay & voting (domain/data/presentation)
│   ├── game_setup/              # Player configuration
│   ├── home/                    # Landing screen
│   ├── role_reveal/             # Secret role distribution
│   ├── story/                   # AI story generation
│   ├── story_history/           # Saved/local played stories
│   ├── story_library/           # Community stories (Supabase)
│   └── voting/                  # Voting domain entities
├── shared/                      # Cross-feature shared code
│   ├── errors/                  # Error localizer
│   ├── services/                # Connectivity, Sound, UploadQueue
│   └── widgets/                 # Reusable widgets (PressScale, filters, badges)
└── hive_registrar.g.dart        # Generated Hive adapters
```

### Layer Responsibilities

**Domain Layer** (`features/*/domain/`):
- `entities/` — Pure business objects (no framework dependencies)
- `repositories/` — Abstract repository interfaces (contracts)
- `usecases/` — Single-responsibility interactor classes

**Data Layer** (`features/*/data/`):
- `models/` — Data models with serialization (Hive, JSON)
- `datasources/` — Remote (API) and Local (Hive, assets) data sources
- `repositories/` — Concrete repository implementations

**Presentation Layer** (`features/*/presentation/`):
- `bloc/` — BLoC (events, states, bloc class)
- `pages/` — Full-screen widgets
- `widgets/` — Feature-specific sub-widgets

---

## Key Design Decisions

1. **Feature-First over Layer-First**: Each feature is self-contained with its own domain/data/presentation layers. This scales better for team development.
2. **BLoC over Provider/Riverpod**: Chosen for explicit event-driven state management, testability with `bloc_test`, and clear separation of UI from business logic.
3. **GetIt over Provider for DI**: Service locator pattern chosen for compile-time safety and ability to inject into non-widget classes (use cases, repositories).
4. **onGenerateRoute over go_router**: Simpler navigation for a linear game flow. No deep linking needed currently.
5. **Hive over SharedPreferences/SQLite**: NoSQL local storage for complex story objects with JSON serialization.
6. **Supabase over Firebase**: Open-source, PostgreSQL-based, with Row-Level Security for community features.

---

## Game Flow

```
Home → Game Mode Selection → Player Setup → Story Generation → Role Reveal → 
Gameplay (Clues + Voting Rounds) → Summary → (Save + Rate + Upload)
```

---

## How to Use This Documentation

Each feature file (`06_` through `13_`) follows this structure:
1. **Overview** — What the feature does
2. **OOB (Out-of-the-Box) Behavior** — Default behavior without customization
3. **Architecture** — Domain/Data/Presentation breakdown
4. **Design Patterns** — Patterns used in this feature
5. **SOLID Principles** — How SOLID is applied
6. **Key Files** — Important files and their responsibilities
7. **Data Flow** — How data moves through the feature
8. **Edge Cases** — Known edge cases and how they're handled
