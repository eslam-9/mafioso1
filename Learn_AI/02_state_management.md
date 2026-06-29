# 02 — State Management (BLoC Pattern)

## Overview
All state management uses the **BLoC (Business Logic Component)** pattern via `flutter_bloc ^8.1.6` with `equatable` for value equality.

## BLoC/Cubit Registry

### 1. GameSetupBloc
- **Location**: `features/game_setup/presentation/bloc/`
- **Purpose**: Manages game mode selection, suspect count (4-6), player name entry & validation
- **Events**: `SetGameMode`, `SetSuspectCount`, `SetPlayerName`, `ValidateNames`, `ResetGameSetup`
- **State**: `GameSetupState` — single class with `copyWith`
  - `selectedMode: GameMode`
  - `suspectCount: int`
  - `playerNames: List<String>`
  - `isValid: bool`
- **Key Logic**: Auto-validates names on every change. Names must be non-empty and unique.

### 2. StoryBloc
- **Location**: `features/story/presentation/bloc/`
- **Purpose**: Handles AI story generation with loading/error states
- **Events**: `GenerateStory`, `UseExistingStory`, `ResetStory`
- **State**: `StoryState` — single class with `copyWith`
  - `isLoading: bool`
  - `story: Story?`
  - `error: AppError?`
- **Key Logic**: Calls `GenerateStoryUseCase`, catches errors, emits error state.

### 3. RoleRevealBloc
- **Location**: `features/role_reveal/presentation/bloc/`
- **Purpose**: Manages role assignment and sequential pass-the-device reveal
- **Events**: `AssignRoles`, `NextPlayer`, `MarkCurrentRevealed`, `ResetRoleReveal`
- **State**: `RoleRevealState` — single class with `copyWith`
  - `players: List<Player>`
  - `currentPlayerIndex: int`
  - `isRevealed: bool`
- **Key Logic**: Uses `AssignRolesUseCase` to shuffle roles. Tracks reveal progress.

### 4. GameBloc
- **Location**: `features/game_result/presentation/bloc/`
- **Purpose**: Manages clue reveals, vote submission, game state transitions
- **Events**: `InitGame`, `RevealNextClue`, `SubmitVotes`, `ResetGame`
- **State**: `GameState` (presentation) — single class with `copyWith`
  - `players: List<Player>`
  - `story: Story?`
  - `gameState: domain.GameState` (playing, innocentsWin, killerWins)
  - `currentRound: int`
  - `voteHistory: List<VoteResult>`
  - `revealedClues: List<Clue>`
  - `error: AppError?`
- **Key Logic**: Sorts clues by difficulty. Processes votes, eliminates players, determines win/loss.

### 5. StoryHistoryBloc
- **Location**: `features/story_history/presentation/bloc/`
- **Purpose**: CRUD for saved stories, rating, upload queue trigger
- **Events**: `LoadSavedStories`, `SaveStory`, `DeleteStory`, `RateStory`
- **State**: Sealed-class-style hierarchy
  - `StoryHistoryInitial`
  - `StoryHistoryLoading`
  - `StoryHistoryLoaded(List<PlayedStory>)`
  - `StoryHistoryError(String)`
- **Key Logic**: Triggers `UploadQueueService.flushQueue()` after rating.

### 6. StoryLibraryBloc
- **Location**: `features/story_library/presentation/bloc/`
- **Purpose**: Community stories pagination, filtering, rating
- **Events**: `LoadStories`, `LoadMore`, `FilterByPlayerCount`, `RateStory`
- **State**: Sealed-class-style hierarchy
  - `StoryLibraryInitial`
  - `StoryLibraryLoading`
  - `StoryLibraryLoaded(List<CommunityStory>, hasMore)`
  - `StoryLibraryError(String)`
- **Key Logic**: Bayesian-averaged sorting, pagination with `page/limit`.

### 7. ThemeCubit (Cubit, not BLoC)
- **Location**: `core/theme/theme_cubit.dart`
- **Purpose**: Light/dark theme toggle with persistence
- **Methods**: `toggleTheme()`, `setTheme(ThemeMode)`
- **State**: `ThemeState(themeData: ThemeData)`

### 8. LanguageCubit (Cubit, not BLoC)
- **Location**: `core/localization/language_cubit.dart`
- **Purpose**: Arabic/English language toggle
- **Methods**: `setLanguage(Locale)`
- **State**: `LanguageState(locale: Locale)`

## BLoC Patterns Used

### Pattern 1: Single State Class with copyWith
Used by: GameSetupBloc, StoryBloc, RoleRevealBloc, GameBloc
```dart
emit(state.copyWith(isLoading: true, error: null));
```

### Pattern 2: Sealed-Class-State Hierarchy
Used by: StoryHistoryBloc, StoryLibraryBloc
```dart
abstract class StoryHistoryState extends Equatable {}
class StoryHistoryInitial extends StoryHistoryState {}
class StoryHistoryLoading extends StoryHistoryState {}
class StoryHistoryLoaded extends StoryHistoryState {}
class StoryHistoryError extends StoryHistoryState {}
```

### Pattern 3: Event Dispatching from Within Handlers
Used by: GameSetupBloc (auto-validates), StoryHistoryBloc (reload after delete)
```dart
emit(state.copyWith(playerNames: updatedNames));
add(const ValidateNames()); // dispatch another event
```

### Pattern 4: Fire-and-Forget with unawaited
Used by: StoryHistoryBloc (upload queue)
```dart
unawaited(uploadQueueService.flushQueue());
```

## Error Handling in BLoCs
Every async BLoC handler follows this pattern:
```dart
try {
  final result = await useCase();
  emit(state.copyWith(data: result));
} catch (e, stackTrace) {
  AppLogger.logError('BlocName', e, stackTrace: stackTrace);
  ErrorHandler.logError(e, stackTrace: stackTrace, context: 'BlocName.handler');
  emit(state.copyWith(error: ErrorHandler.toAppError(e)));
}
```

## BLoC Provisioning
- **Global Cubits** (ThemeCubit, LanguageCubit): Provided in `app.dart` via `MultiBlocProvider`
- **Feature BLoCs**: Provided in route wrappers via `BlocProvider` in `route_generator.dart`
- **GameBloc**: Created inline in `GamePage` (not registered in DI)
- **RoleRevealBloc**: Created inline in `RoleRevealPage`
- **GameSetupBloc**: Created inline in `PlayerSetupPage`
