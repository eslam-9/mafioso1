# Mafioso - Clean Architecture + BLoC Refactor Plan

## 📋 Executive Summary

**Current Architecture:** MVVM + Riverpod + GoRouter  
**Target Architecture:** Clean Architecture + BLoC + generateRoute  
**Goal:** Refactor without changing functionality, improve maintainability and scalability

---

## 🗂️ Target Folder Structure

```
lib/
├── main.dart                          # App entry point
├── app.dart                           # MaterialApp with theme & localization
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart        # App-wide constants
│   │   └── route_names.dart          # All route name constants
│   │
│   ├── theme/
│   │   ├── app_theme.dart            # Theme configuration
│   │   ├── light_theme.dart          # Light theme data
│   │   ├── dark_theme.dart           # Dark theme data
│   │   └── theme_cubit.dart          # Theme state management
│   │
│   ├── localization/
│   │   ├── app_localization.dart     # Localization setup
│   │   └── generated/                # Generated locale files
│   │
│   ├── routing/
│   │   ├── route_names.dart          # Route name constants
│   │   └── route_generator.dart     # onGenerateRoute implementation
│   │
│   ├── widgets/
│   │   ├── background_widget.dart    # Background gradient widget
│   │   ├── loading_widget.dart        # Reusable loading indicator
│   │   ├── error_widget.dart         # Reusable error display
│   │   └── animated_button.dart      # Reusable animated button
│   │
│   ├── utils/
│   │   ├── logger.dart               # Centralized logging
│   │   └── validators.dart           # Input validators
│   │
│   ├── network/
│   │   ├── dio_client.dart           # Dio configuration
│   │   └── api_exceptions.dart       # Network exception handling
│   │
│   ├── errors/
│   │   ├── failure.dart              # Base failure class
│   │   ├── exceptions.dart           # Custom exceptions
│   │   └── error_handler.dart        # Error handling utilities
│   │
│   └── di/
│       └── injection_container.dart  # GetIt dependency injection
│
├── features/
│   ├── home/
│   │   ├── presentation/
│   │   │   ├── bloc/
│   │   │   │   └── home_bloc.dart    # Home feature BLoC (if needed)
│   │   │   ├── pages/
│   │   │   │   └── home_page.dart    # Home screen (50-100 lines)
│   │   │   └── widgets/
│   │   │       ├── home_title.dart   # Title widget
│   │   │       └── how_to_play_dialog.dart # Dialog widget
│   │   ├── domain/
│   │   │   └── entities/             # Home entities (if any)
│   │   └── data/                     # Home data (if any)
│   │
│   ├── game_setup/
│   │   ├── presentation/
│   │   │   ├── bloc/
│   │   │   │   ├── game_setup_bloc.dart
│   │   │   │   ├── game_setup_event.dart
│   │   │   │   └── game_setup_state.dart
│   │   │   ├── pages/
│   │   │   │   ├── game_mode_page.dart
│   │   │   │   └── player_setup_page.dart
│   │   │   └── widgets/
│   │   │       ├── mode_selector.dart
│   │   │       ├── suspect_count_selector.dart
│   │   │       └── player_name_input.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── game_config.dart  # Moved from models/
│   │   │   └── repositories/
│   │   │       └── game_setup_repository.dart # Contract
│   │   └── data/
│   │       └── repositories/
│   │           └── game_setup_repository_impl.dart
│   │
│   ├── story/
│   │   ├── presentation/
│   │   │   ├── bloc/
│   │   │   │   ├── story_bloc.dart
│   │   │   │   ├── story_event.dart
│   │   │   │   └── story_state.dart
│   │   │   ├── pages/
│   │   │   │   └── story_generation_page.dart
│   │   │   └── widgets/
│   │   │       ├── story_loading_widget.dart
│   │   │       ├── story_content_widget.dart
│   │   │       └── story_error_widget.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── story.dart        # Moved from models/
│   │   │   │   ├── suspect.dart      # Extracted from story.dart
│   │   │   │   └── clue.dart         # Extracted from story.dart
│   │   │   ├── repositories/
│   │   │   │   └── story_repository.dart # Contract
│   │   │   └── usecases/
│   │   │       └── generate_story_usecase.dart
│   │   └── data/
│   │       ├── models/
│   │       │   ├── story_model.dart  # Data model (extends entity)
│   │       │   ├── suspect_model.dart
│   │       │   └── clue_model.dart
│   │       ├── datasources/
│   │       │   ├── story_remote_datasource.dart  # GeminiService → here
│   │       │   └── story_local_datasource.dart  # Offline stories
│   │       └── repositories/
│   │           └── story_repository_impl.dart
│   │
│   ├── role_reveal/
│   │   ├── presentation/
│   │   │   ├── bloc/
│   │   │   │   ├── role_reveal_bloc.dart
│   │   │   │   ├── role_reveal_event.dart
│   │   │   │   └── role_reveal_state.dart
│   │   │   ├── pages/
│   │   │   │   └── role_reveal_page.dart
│   │   │   └── widgets/
│   │   │       ├── role_card_widget.dart
│   │   │       └── role_reveal_animation.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── player.dart       # Moved from models/
│   │   │   └── usecases/
│   │   │       └── assign_roles_usecase.dart
│   │   └── data/
│   │       └── models/
│   │           └── player_model.dart
│   │
│   ├── voting/
│   │   ├── presentation/
│   │   │   ├── bloc/
│   │   │   │   ├── voting_bloc.dart
│   │   │   │   ├── voting_event.dart
│   │   │   │   └── voting_state.dart
│   │   │   ├── pages/
│   │   │   │   └── voting_page.dart  # Part of game flow
│   │   │   └── widgets/
│   │   │       ├── vote_card_widget.dart
│   │   │       └── vote_result_widget.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── vote_result.dart  # Moved from models/
│   │   │   └── usecases/
│   │   │       └── submit_votes_usecase.dart
│   │   └── data/
│   │       └── models/
│   │           └── vote_result_model.dart
│   │
│   └── game_result/
│       ├── presentation/
│       │   ├── bloc/
│       │   │   ├── game_bloc.dart    # GameViewModel → here
│       │   │   ├── game_event.dart
│       │   │   └── game_state.dart
│       │   ├── pages/
│       │   │   ├── game_page.dart
│       │   │   └── summary_page.dart
│       │   └── widgets/
│       │       ├── clue_reveal_widget.dart
│       │       ├── player_list_widget.dart
│       │       └── game_summary_widget.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── game_state.dart   # GameState enum
│       │   └── usecases/
│       │       ├── reveal_clue_usecase.dart
│       │       └── check_win_condition_usecase.dart
│       └── data/
│           └── models/
│               └── game_state_model.dart
│
└── shared/
    ├── services/
    │   ├── sound_service.dart        # Moved from services/
    │   └── connectivity_service.dart  # Moved from services/
    └── extensions/
        └── string_extensions.dart    # Helper extensions
```

---

## 📦 Package Migration List

### ❌ Packages to REMOVE

1. **flutter_riverpod** (^2.6.1)
   - Reason: Replaced by flutter_bloc

2. **go_router** (^14.6.2)
   - Reason: Replaced by onGenerateRoute

3. **riverpod_lint** (^2.6.0) - dev dependency
   - Reason: No longer using Riverpod

### ✅ Packages to ADD

1. **flutter_bloc** (^8.1.6)
   - Purpose: State management (replaces Riverpod)

2. **equatable** (^2.0.5)
   - Purpose: Value equality for BLoC states & events

3. **get_it** (^7.7.0)
   - Purpose: Dependency injection (replaces Riverpod providers)

4. **easy_localization** (^3.0.4)
   - Purpose: Localization (replaces manual setup)
   - Includes: easy_localization_generator (dev)

5. **flutter_screenutil** (^5.9.0)
   - Purpose: Responsive design (.w, .h, .sp)

6. **flutter_bloc_test** (^9.1.6) - dev dependency
   - Purpose: Testing BLoCs

### ✅ Packages to KEEP

- **flutter_animate** (^4.5.0) - Already in use
- **dio** (^5.7.0) - HTTP client
- **audioplayers** (^6.1.0) - Sound effects
- **google_fonts** (^6.2.1) - Fonts
- **connectivity_plus** (^6.1.0) - Network connectivity
- **shared_preferences** (^2.3.3) - Local storage
- **flutter_dotenv** (^5.1.0) - Environment variables
- **intl** - Localization support
- **mockito** (^5.4.4) - Testing

---

## 🔄 Feature Mapping (Old → New)

### 1. State Management Migration

| Old (Riverpod + ViewModel) | New (BLoC) |
|---------------------------|------------|
| `GameSetupViewModel` | `GameSetupBloc` + `GameSetupState` + `GameSetupEvent` |
| `StoryViewModel` | `StoryBloc` + `StoryState` + `StoryEvent` |
| `RoleRevealViewModel` | `RoleRevealBloc` + `RoleRevealState` + `RoleRevealEvent` |
| `GameViewModel` | `GameBloc` + `GameState` + `GameEvent` |

### 2. Service Migration

| Old | New |
|-----|-----|
| `GeminiService` | `StoryRemoteDataSource` (in `features/story/data/datasources/`) |
| Offline stories logic | `StoryLocalDataSource` (in `features/story/data/datasources/`) |
| `StoryRepository` | Split into: Domain contract + Data implementation |
| `ConnectivityService` | Move to `shared/services/` (unchanged) |
| `SoundService` | Move to `shared/services/` (unchanged) |

### 3. Model → Entity Migration

| Old Location | New Location | Type |
|-------------|-------------|------|
| `models/game_config.dart` | `features/game_setup/domain/entities/game_config.dart` | Entity |
| `models/player.dart` | `features/role_reveal/domain/entities/player.dart` | Entity |
| `models/story.dart` | `features/story/domain/entities/story.dart` | Entity |
| `models/vote_result.dart` | `features/voting/domain/entities/vote_result.dart` | Entity |

**Note:** Entities are pure Dart classes. Data models (with JSON serialization) go in `data/models/` and extend entities.

### 4. Routing Migration

| Old (GoRouter) | New (onGenerateRoute) |
|---------------|----------------------|
| `AppRouter.home` | `RouteNames.home` |
| `AppRouter.gameMode` | `RouteNames.gameMode` |
| `AppRouter.playerSetup` | `RouteNames.playerSetup` |
| `AppRouter.storyGeneration` | `RouteNames.storyGeneration` |
| `AppRouter.roleReveal` | `RouteNames.roleReveal` |
| `AppRouter.game` | `RouteNames.game` |
| `AppRouter.summary` | `RouteNames.summary` |
| `context.go(path)` | `Navigator.pushNamed(context, RouteNames.path)` |
| `GoRouter.router` | `onGenerateRoute` in `RouteGenerator` |

### 5. Dependency Injection Migration

| Old (Riverpod) | New (GetIt) |
|---------------|------------|
| `ProviderScope` | `GetIt` singleton registration |
| `ref.watch(provider)` | `getIt<Type>()` |
| `ref.read(provider)` | `getIt<Type>()` |
| `Provider<T>` | `GetIt.registerLazySingleton<T>()` or `registerFactory<T>()` |
| `ChangeNotifierProvider` | `GetIt.registerFactory<T>()` for BLoCs |

---

## 📝 Detailed Refactor Process

### Phase 1: Core Infrastructure Setup

1. **Update pubspec.yaml**
   - Remove: `flutter_riverpod`, `go_router`, `riverpod_lint`
   - Add: `flutter_bloc`, `equatable`, `get_it`, `easy_localization`, `flutter_screenutil`
   - Run: `flutter pub get`

2. **Create Core Structure**
   - Set up `core/` folder structure
   - Create `core/constants/route_names.dart`
   - Create `core/routing/route_generator.dart`
   - Create `core/theme/theme_cubit.dart` (for theme switching)
   - Create `core/di/injection_container.dart` (GetIt setup)
   - Create `core/localization/` setup with easy_localization

3. **Create Theme System**
   - Split `app_theme.dart` into `light_theme.dart` and `dark_theme.dart`
   - Create `ThemeCubit` for theme state management
   - Update theme to use `flutter_screenutil` for responsive values

### Phase 2: Feature-by-Feature Migration

#### Feature 1: Home
- **Priority:** Low (minimal state)
- **Actions:**
  - Move `views/home/home_view.dart` → `features/home/presentation/pages/home_page.dart`
  - Extract widgets to `features/home/presentation/widgets/`
  - Replace `context.go()` with `Navigator.pushNamed()`
  - Add `const` constructors where possible
  - Split into smaller widgets (max 30 lines each)

#### Feature 2: Game Setup
- **Priority:** High (foundation for other features)
- **Actions:**
  - Create `GameSetupBloc` with events:
    - `SetGameMode(GameMode mode)`
    - `SetSuspectCount(int count)`
    - `SetPlayerName(int index, String name)`
    - `ValidateNames()`
    - `CreateGameConfig()`
    - `Reset()`
  - Create `GameSetupState` with Equatable:
    - `GameSetupInitial`
    - `GameSetupLoaded(GameMode mode, int suspectCount, List<String> playerNames)`
    - `GameSetupValidationFailed(String error)`
  - Move `models/game_config.dart` → `features/game_setup/domain/entities/`
  - Update pages to use `BlocBuilder<GameSetupBloc, GameSetupState>`
  - Replace `GameSetupViewModel` usage with BLoC

#### Feature 3: Story
- **Priority:** High (core feature)
- **Actions:**
  - Create `StoryBloc` with events:
    - `GenerateStory(GameConfig config)`
    - `Reset()`
  - Create `StoryState`:
    - `StoryInitial`
    - `StoryLoading`
    - `StoryLoaded(Story story)`
    - `StoryError(String message)`
  - Refactor `GeminiService` → `StoryRemoteDataSource`
  - Create `StoryLocalDataSource` for offline stories
  - Create domain `StoryRepository` contract
  - Create `GenerateStoryUseCase`
  - Implement `StoryRepositoryImpl` in data layer
  - Move `models/story.dart` → entities, create models in data layer
  - Update `StoryGenerationView` → `StoryGenerationPage` with BLoC

#### Feature 4: Role Reveal
- **Priority:** Medium
- **Actions:**
  - Create `RoleRevealBloc` with events:
    - `AssignRoles(GameConfig config, Story story)`
    - `NextPlayer()`
    - `MarkCurrentRevealed()`
    - `Reset()`
  - Create `RoleRevealState`:
    - `RoleRevealInitial`
    - `RoleRevealInProgress(List<Player> players, int currentIndex)`
    - `RoleRevealComplete(List<Player> players)`
  - Move `models/player.dart` → `features/role_reveal/domain/entities/`
  - Create `AssignRolesUseCase`
  - Update `RoleRevealView` → `RoleRevealPage` with BLoC

#### Feature 5: Game & Voting
- **Priority:** High (main gameplay)
- **Actions:**
  - Create `GameBloc` with events:
    - `InitGame(List<Player> players, Story story)`
    - `RevealNextClue()`
    - `SubmitVotes(List<Vote> votes)`
    - `Reset()`
  - Create `GameState`:
    - `GameInitial`
    - `GamePlaying(List<Player> players, Story story, int round, List<Clue> revealedClues)`
    - `GameWon(GameState gameState, Player? winner)`
    - `GameError(String message)`
  - Move `models/vote_result.dart` → `features/voting/domain/entities/`
  - Create `VotingBloc` if voting logic is complex enough
  - Update `GameView` and `SummaryView` → pages with BLoC

### Phase 3: Dependency Injection Setup

1. **Create `injection_container.dart`**
   ```dart
   // Register in order: DataSources → Repositories → UseCases → BLoCs
   ```

2. **Register Services**
   - `ConnectivityService` (singleton)
   - `SoundService` (singleton)
   - `DioClient` (singleton)

3. **Register Data Sources**
   - `StoryRemoteDataSource` (factory)
   - `StoryLocalDataSource` (singleton)

4. **Register Repositories**
   - `StoryRepositoryImpl` (singleton)

5. **Register Use Cases**
   - `GenerateStoryUseCase` (factory)
   - `AssignRolesUseCase` (factory)

6. **Register BLoCs**
   - All BLoCs as factories (new instance per screen)

### Phase 4: Navigation Migration

1. **Create `RouteNames` class**
   ```dart
   class RouteNames {
     static const String home = '/';
     static const String gameMode = '/game-mode';
     // ... etc
   }
   ```

2. **Create `RouteGenerator`**
   - Implement `onGenerateRoute` function
   - Map routes to pages
   - Handle route arguments
   - Add route guards if needed

3. **Update `main.dart`**
   - Remove `ProviderScope`
   - Initialize GetIt
   - Use `MaterialApp` with `onGenerateRoute`

### Phase 5: Localization Setup

1. **Setup easy_localization**
   - Create `assets/translations/ar.json` and `en.json`
   - Move all hardcoded Arabic strings to translation files
   - Generate `LocaleKeys` using code generation
   - Update all widgets to use `context.tr(LocaleKeys.key)`

2. **Add RTL Support**
   - Configure `MaterialApp` for RTL
   - Test with Arabic locale

### Phase 6: Theming & Responsiveness

1. **Theme System**
   - Create `ThemeCubit` for theme switching
   - Split theme into light/dark
   - Use theme from `BlocBuilder<ThemeCubit, ThemeState>`

2. **Responsive Design**
   - Initialize `ScreenUtil` in `main.dart`
   - Replace hardcoded sizes with `.w`, `.h`, `.sp`
   - Test on different screen sizes

### Phase 7: Code Quality & Testing

1. **Add const constructors** everywhere possible
2. **Split large widgets** (screens max 100 lines, widgets max 30 lines)
3. **Add logging** for navigation, API calls, BLoC events
4. **Write unit tests** for BLoCs using `bloc_test`
5. **Verify UI behavior** matches original

---

## ⚠️ Critical Preservation Points

### Must Preserve:

1. **Game Logic**
   - Role assignment algorithm (random shuffle)
   - Vote counting logic
   - Win condition checks
   - Story adaptation to player count

2. **Offline Fallback**
   - Web platform CORS handling
   - Offline story loading
   - Connectivity checking

3. **Sound Effects**
   - Sound service integration
   - Mute functionality

4. **Error Handling**
   - Error messages in Arabic
   - User-friendly error display
   - Error logging

5. **Animations**
   - Existing `flutter_animate` animations
   - Role reveal animations
   - Card animations

---

## ✅ Verification Checklist

After each feature refactor:

- [ ] UI looks identical to original
- [ ] All user flows work (game setup → story → roles → game → summary)
- [ ] No hardcoded strings (use localization)
- [ ] No hardcoded colors (use theme)
- [ ] All screens < 100 lines
- [ ] All widgets < 30 lines
- [ ] BLoC states use Equatable
- [ ] Navigation uses RouteNames constants
- [ ] No direct Navigator.push() calls
- [ ] All dependencies registered in GetIt
- [ ] Theme switching works (light/dark)
- [ ] RTL support works (Arabic)
- [ ] Responsive design works (.w, .h, .sp)
- [ ] Logging added for key operations
- [ ] Error handling preserved

---

## 🚀 Execution Order

1. ✅ **STOP HERE** - Wait for user confirmation
2. Update `pubspec.yaml` (remove/add packages)
3. Create core infrastructure (routing, DI, theme, localization)
4. Refactor features one by one (Home → Game Setup → Story → Role Reveal → Game)
5. Update navigation throughout
6. Add localization
7. Add theme switching
8. Add responsiveness
9. Final testing & verification

---

## 📊 Estimated Impact

- **Files to Create:** ~60-70 new files
- **Files to Modify:** ~15 existing files
- **Files to Delete:** ~5 old files (viewmodels, old router)
- **Lines of Code:** Similar or slightly more (due to Clean Architecture layers)
- **Breaking Changes:** None (internal refactor only)

---

**Status:** ⏸️ **AWAITING CONFIRMATION TO PROCEED**
