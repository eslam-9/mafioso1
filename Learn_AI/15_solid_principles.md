# 15 — SOLID Principles Application

## S — Single Responsibility Principle

### ✅ Well Applied

**UseCases**: Each does exactly one thing
```dart
class GenerateStoryUseCase {
  Future<Story> call({...}) async {
    return repository.getStory(...);  // Only one responsibility
  }
}
```

**BLoCs**: Each manages one feature's state
```dart
class StoryBloc extends Bloc<StoryEvent, StoryState> {
  // Only handles story generation state
}

class GameSetupBloc extends Bloc<GameSetupEvent, GameSetupState> {
  // Only handles game setup state
}
```

**DataSources**: Split by concern
```dart
StoryRemoteDataSource  // Only API calls
StoryLocalDataSource   // Only local storage
```

**Widgets**: Each handles one UI element
```dart
HomeTitle()         // Only displays title
HomeStartButton()   // Only displays start button with tap handler
```

### ⚠️ Violations

**SummaryPage**: Handles UI, sound playback, story saving, and rating
```dart
class _SummaryPageState extends State<SummaryPage> {
  void _handleGameInit() {
    // Plays sound
    // Saves story
    // Multiple responsibilities in one class
  }
}
```
**Fix**: Create `SummaryBloc` to handle these side effects.

**UploadQueueService**: Coordinates uploads, ratings, connectivity, and blocking logic
```dart
class UploadQueueService {
  // Handles upload, rate, mark-as-uploaded, RLS detection, blocking
  // Could be split into UploadCoordinator + RlsHandler
}
```

---

## O — Open/Closed Principle

### ✅ Well Applied

**AI Providers**: Open for extension, closed for modification
```dart
enum AiProvider { gemini, groq }
// Add new provider by extending enum — no repository changes needed

if (remoteDataSource.canUse(AiProvider.gemini)) {
  providersToTry.add(AiProvider.gemini);
}
```

**Game States**: New states can be added without changing BLoC logic
```dart
enum GameState { playing, innocentsWin, killerWins }
// Add 'detectiveWins' without changing existing vote processing
```

**Repository Interfaces**: New implementations without changing domain
```dart
abstract class StoryRepository {
  Future<Story> getStory({...});
}
// Can add MockStoryRepository, TestStoryRepository without changing domain
```

**Error Keys**: New errors added via translation files, no code changes
```dart
// Add new key to ar.json and en.json
// ErrorHandler pattern matching handles new types automatically
```

---

## L — Liskov Substitution Principle

### ✅ Well Applied

**StoryModel extends Story**: Fully substitutable
```dart
class StoryModel extends Story {
  // Can be used anywhere Story is expected
  // Adds toJson(), fromJson() but doesn't change behavior
}
```

**BLoC States**: All states substitutable for base type
```dart
abstract class StoryHistoryState extends Equatable {}
// StoryHistoryInitial, Loading, Loaded, Error all substitutable
```

**Repository Implementations**: Any implementation works
```dart
StoryRepository repo = StoryRepositoryImpl(...);
// Could swap with MockStoryRepository without breaking code
```

---

## I — Interface Segregation Principle

### ✅ Well Applied

**Focused Repository Interfaces**:
```dart
abstract class StoryRepository {
  Future<Story> getStory({...});  // Only 1 method
}

abstract class StoryLibraryRepository {
  Future<List<CommunityStory>> getStories({...});
  Future<String> uploadStory(...);
  Future<void> rateStory(...);  // Only 3 focused methods
}
```

**Focused DataSource Interfaces**:
```dart
abstract class StoryRemoteDataSource {
  Future<Story> generateStory({...});
  bool canUse(AiProvider provider);  // Only 2 methods
}
```

**BLoC Events**: Each event is specific
```dart
// GameSetupBloc events are specific to setup actions
class SetGameMode extends GameSetupEvent {}
class SetSuspectCount extends GameSetupEvent {}
class SetPlayerName extends GameSetupEvent {}
```

---

## D — Dependency Inversion Principle

### ✅ Well Applied

**Domain depends on abstractions**:
```dart
// Domain layer defines the interface
abstract class StoryRepository {
  Future<Story> getStory({...});
}

// Data layer implements it
class StoryRepositoryImpl implements StoryRepository { ... }

// UseCase depends on abstraction, not concrete class
class GenerateStoryUseCase {
  final StoryRepository repository;  // Depends on interface
  GenerateStoryUseCase(this.repository);
}
```

**BLoCs depend on UseCase abstractions**:
```dart
class StoryBloc extends Bloc<StoryEvent, StoryState> {
  final GenerateStoryUseCase generateStoryUseCase;  // Depends on abstraction
  StoryBloc({required this.generateStoryUseCase});
}
```

### ⚠️ Violations

**Direct GetIt access in presentation**:
```dart
// SummaryPage — depends on concrete GetIt, not abstraction
final soundService = di.getIt<SoundService>();
di.getIt<StoryHistoryBloc>().add(SaveStory(playedStory));
```
**Fix**: Inject through BLoC constructor or use `BlocProvider`.

---

## Summary Table

| Principle | Status | Notes |
|-----------|--------|-------|
| **S**ingle Responsibility | ⚠️ Mostly | SummaryPage needs refactoring |
| **O**pen/Closed | ✅ Strong | Easy to extend AI providers, game states, errors |
| **L**iskov Substitution | ✅ Strong | Models and states are fully substitutable |
| **I**nterface Segregation | ✅ Strong | Focused interfaces throughout |
| **D**ependency Inversion | ⚠️ Mostly | Direct GetIt access in some presentation layers |
