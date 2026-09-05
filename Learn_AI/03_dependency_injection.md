# 03 — Dependency Injection (GetIt)

## Overview
Uses **GetIt** (`get_it ^7.7.0`) as a service locator. Two registration patterns:
- `registerLazySingleton<T>()` — Created once on first access, reused
- `registerFactory<T>()` — New instance every time `get<T>()` is called

## Registration Structure

### Main Container (`lib/core/di/injection_container.dart`)
```dart
final getIt = GetIt.instance;

Future<void> init() async {
  initStoryHistory(); // Separate module registration
  
  // External
  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => prefs);
  
  // Core services
  getIt.registerLazySingleton<DeviceIdService>(() => DeviceIdService(getIt()));
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  getIt.registerLazySingleton<SoundService>(() => SoundService()..init());
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  
  // Network — separate Dio instances per API
  getIt.registerLazySingleton<Dio>(() => Dio(...), instanceName: 'geminiDio');
  getIt.registerLazySingleton<Dio>(() => Dio(...), instanceName: 'groqDio');
  
  // Conditional AI data source registration
  if (hasAnyRemoteAiKey) {
    getIt.registerLazySingleton<StoryRemoteDataSource>(() => ...);
  }
  
  // Repositories, UseCases, BLoCs
  // ...
}
```

### Story History Module (`lib/features/story_history/story_history_injection.dart`)
```dart
final sl = GetIt.instance; // Separate reference, same instance

void initStoryHistory() {
  sl.registerFactory(() => StoryHistoryBloc(...));
  sl.registerLazySingleton(() => GetSavedStoriesUseCase(sl()));
  // ... more registrations
}
```

## Registration Patterns

### Pattern 1: Factory for BLoCs
```dart
getIt.registerFactory<StoryBloc>(
  () => StoryBloc(generateStoryUseCase: getIt<GenerateStoryUseCase>()),
);
```
**Why**: BLoCs should be fresh per screen/navigation to avoid stale state.

### Pattern 2: LazySingleton for UseCases
```dart
getIt.registerLazySingleton<GetCommunityStoriesUseCase>(
  () => GetCommunityStoriesUseCase(getIt<StoryLibraryRepository>()),
);
```
**Why**: UseCases are stateless, safe to share.

### Pattern 3: LazySingleton for Repositories
```dart
getIt.registerLazySingleton<StoryRepository>(
  () => StoryRepositoryImpl(
    remoteDataSource: hasAnyRemoteAiKey ? getIt<StoryRemoteDataSource>() : null,
    localDataSource: getIt<StoryLocalDataSource>(),
    connectivityService: getIt<ConnectivityService>(),
  ),
);
```
**Why**: Repositories are stateless coordinators.

### Pattern 4: Named Instances for Dio
```dart
getIt.registerLazySingleton<Dio>(() => Dio(...), instanceName: 'geminiDio');
getIt.registerLazySingleton<Dio>(() => Dio(...), instanceName: 'groqDio');
// Access: getIt<Dio>(instanceName: 'geminiDio')
```
**Why**: Prevents shared state (interceptors, headers) between APIs.

### Pattern 5: Conditional Registration
```dart
if (hasAnyRemoteAiKey) {
  getIt.registerLazySingleton<StoryRemoteDataSource>(() => ...);
}
// Repository accepts nullable remoteDataSource
getIt.registerLazySingleton<StoryRepository>(
  () => StoryRepositoryImpl(
    remoteDataSource: hasAnyRemoteAiKey ? getIt<StoryRemoteDataSource>() : null,
    ...
  ),
);
```
**Why**: App works offline without API keys.

## Access Patterns

### In BLoCs (Constructor Injection — Preferred)
```dart
class StoryBloc extends Bloc<StoryEvent, StoryState> {
  final GenerateStoryUseCase generateStoryUseCase;
  StoryBloc({required this.generateStoryUseCase}) : super(...) { ... }
}
```

### In Route Wrappers
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

### In Pages (Direct Access — Avoid When Possible)
```dart
// SummaryPage — should be refactored to use BLoC providers
final soundService = di.getIt<SoundService>();
di.getIt<StoryHistoryBloc>().add(SaveStory(playedStory));
```

## Startup Side Effects
```dart
getIt<UploadQueueService>()
  ..startListening()    // Listen for connectivity changes
  ..flushQueue();       // Process pending uploads immediately
```
These run immediately after DI initialization in `main.dart`.
