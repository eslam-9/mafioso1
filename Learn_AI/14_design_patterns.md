# 14 — Design Patterns Used

## 1. Repository Pattern
**Where**: Every feature's data layer
**What**: Abstract repository interfaces in domain, concrete implementations in data
**Example**:
```dart
// Domain
abstract class StoryRepository {
  Future<Story> getStory({...});
}

// Data
class StoryRepositoryImpl implements StoryRepository {
  final StoryRemoteDataSource? remoteDataSource;
  final StoryLocalDataSource localDataSource;
  
  Future<Story> getStory({...}) async {
    // Coordinate between datasources
  }
}
```

## 2. Dependency Injection (Service Locator)
**Where**: `core/di/injection_container.dart`
**What**: GetIt registers and resolves dependencies
**Example**:
```dart
getIt.registerLazySingleton<StoryRepository>(
  () => StoryRepositoryImpl(
    remoteDataSource: getIt<StoryRemoteDataSource>(),
    localDataSource: getIt<StoryLocalDataSource>(),
  ),
);
```

## 3. Factory Pattern
**Where**: UseCase registrations in DI
**What**: New instance created every time
**Example**:
```dart
getIt.registerFactory<GenerateStoryUseCase>(
  () => GenerateStoryUseCase(getIt<StoryRepository>()),
);
```

## 4. Singleton Pattern
**Where**: Services, repositories, Dio instances
**What**: Single instance shared across app
**Example**:
```dart
getIt.registerLazySingleton<SoundService>(() => SoundService()..init());
```

## 5. Observer Pattern
**Where**: BLoC pattern throughout
**What**: BLoC emits state changes, UI observes and rebuilds
**Example**:
```dart
BlocBuilder<StoryBloc, StoryState>(
  builder: (context, state) {
    if (state.isLoading) return LoadingWidget();
    if (state.error != null) return ErrorWidget(state.error!);
    return StoryContentWidget(state.story!);
  },
)
```

## 6. Strategy Pattern
**Where**: AI provider selection
**What**: Different algorithms (Gemini vs Groq) selected at runtime
**Example**:
```dart
enum AiProvider { gemini, groq }

for (final provider in providersToTry) {
  final story = await remoteDataSource.generateStory(..., aiProvider: provider);
}
```

## 7. Adapter Pattern
**Where**: `PlayedStoryModel`
**What**: Adapts domain entity to Hive storage format
**Example**:
```dart
class PlayedStoryModel extends HiveObject {
  PlayedStory toEntity() { /* Hive model → domain entity */ }
  factory PlayedStoryModel.fromEntity(PlayedStory entity) { /* domain → Hive */ }
}
```

## 8. Builder Pattern
**Where**: Route wrapper widgets
**What**: Wrappers build BLoC providers around pages
**Example**:
```dart
class _StoryGenerationPageWrapper extends StatelessWidget {
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<StoryBloc>(),
      child: const StoryGenerationPage(),
    );
  }
}
```

## 9. Template Method Pattern
**Where**: `AppError` with localization keys
**What**: Base error class defines structure, subclasses provide specific keys
**Example**:
```dart
class AppError extends Equatable {
  final String key;  // Template for localization
  final Map<String, String> namedArgs;  // Variables to fill template
}
```

## 10. Facade Pattern
**Where**: `ErrorHandler`
**What**: Simplifies complex error type mapping behind static methods
**Example**:
```dart
// Complex pattern matching hidden behind simple API
final AppError error = ErrorHandler.toAppError(exception);
```

## 11. Mediator Pattern
**Where**: `UploadQueueService`
**What**: Coordinates between story history and story library features
**Example**:
```dart
class UploadQueueService {
  // Gets pending from history, uploads to library, marks as uploaded
  Future<void> flushQueue() async {
    final pending = await getPendingUploads();  // From history
    for (final story in pending) {
      await uploadStory(...);  // To library
      await markAsUploaded(story.id);  // Back to history
    }
  }
}
```

## 12. Cascading Fallback Pattern
**Where**: `StoryRepositoryImpl.getStory()`
**What**: Try multiple sources in order, fall back on failure
**Example**:
```
Web check → Connectivity check → API keys check → Gemini → Groq → Offline
```

## 13. Composition Pattern
**Where**: All UI pages
**What**: Pages composed of many small, focused widgets
**Example**:
```dart
// HomePage composed of:
HomeTitle()
HomeSubtitle()
HomeStartButton()
HomeHowToPlayButton()
HomeSavedStoriesButton()
HomeCommunityLibraryButton()
HomeFooter()
```

## 14. State Machine Pattern
**Where**: `GameBloc`
**What**: Game transitions between defined states
**Example**:
```dart
enum GameState { playing, innocentsWin, killerWins }
// playing → (killer eliminated) → innocentsWin
// playing → (killer alive, ≤2 players) → killerWins
```
