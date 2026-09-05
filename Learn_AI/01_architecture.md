# 01 — Architecture

## Overview
Mafioso uses **Clean Architecture** with a **Feature-First** organization. Each feature module is self-contained with its own domain, data, and presentation layers.

## Folder Structure
```
lib/
├── main.dart                    # Entry point
├── app.dart                     # Root MaterialApp
├── core/                        # Cross-cutting concerns
│   ├── ai_provider/             # AiProvider enum
│   ├── constants/               # Route name constants
│   ├── di/                      # GetIt DI container
│   ├── errors/                  # AppError, ErrorHandler, AppErrorException
│   ├── localization/            # AppLocalization, LanguageCubit
│   ├── routing/                 # RouteGenerator
│   ├── services/                # DeviceIdService
│   ├── theme/                   # Themes, AppColors, AppSpacing, ThemeCubit
│   └── utils/                   # AppLogger, RoleLocalizationHelper
├── features/                    # Feature modules
│   ├── game_result/             # Gameplay, voting, summary
│   ├── game_setup/              # Player configuration
│   ├── home/                    # Landing screen
│   ├── role_reveal/             # Role assignment & reveal
│   ├── story/                   # AI story generation
│   ├── story_history/           # Local saved stories
│   ├── story_library/           # Community Supabase library
│   └── voting/                  # Voting entities
├── shared/                      # Cross-feature code
│   ├── errors/                  # AppErrorLocalizer
│   ├── services/                # ConnectivityService, SoundService, UploadQueueService
│   └── widgets/                 # PressScale, PlayerCountStoryFilterBar, StoryStatusBadge
└── hive_registrar.g.dart        # Generated Hive adapters
```

## Layer Responsibilities

### Domain Layer (`features/*/domain/`)
- **entities/**: Pure Dart classes, no framework dependencies. Represent business concepts.
- **repositories/**: Abstract interfaces defining data operation contracts.
- **usecases/**: Single-responsibility classes, each doing ONE thing. Called with `call()` method.

### Data Layer (`features/*/data/`)
- **models/**: Serializable classes (JSON, Hive). Extend or map to domain entities.
- **datasources/**: 
  - `RemoteDataSource`: API calls (Dio, Supabase)
  - `LocalDataSource`: Local storage (Hive, asset bundles)
- **repositories/**: Concrete implementations of domain repository interfaces. Coordinate between datasources.

### Presentation Layer (`features/*/presentation/`)
- **bloc/**: BLoC classes with Events and States. All business logic for UI.
- **pages/**: Full-screen StatefulWidget or StatelessWidget widgets.
- **widgets/**: Smaller, reusable widgets specific to this feature.

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Architecture | Clean Architecture + Feature-First | Scales for teams, clear separation, easy to test |
| State Management | BLoC (flutter_bloc) | Event-driven, testable with bloc_test, explicit state transitions |
| DI | GetIt service locator | Compile-time safety, works outside widget tree |
| Navigation | onGenerateRoute | Simple linear game flow, no deep linking needed |
| Local DB | Hive CE | NoSQL, fast, JSON serialization for complex objects |
| Backend | Supabase | Open-source, PostgreSQL, RLS for security |
| HTTP | Dio | Interceptors, timeout config, separate instances per API |

## Initialization Flow (main.dart)
1. `WidgetsFlutterBinding.ensureInitialized()`
2. `Hive.initFlutter()` + register adapters
3. `Supabase.initialize()` with dart-define credentials
4. `AppLocalization.init()`
5. `di.init()` — register all dependencies
6. `runApp(EasyLocalization(child: MafiosoApp()))`
