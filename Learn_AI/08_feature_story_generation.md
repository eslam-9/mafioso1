# 08 — Feature: Story Generation

## Overview
Generates AI-powered murder mystery stories with a cascading fallback system: Gemini → Groq → Offline Assets.

## OOB Behavior
- On web platform: always uses offline stories (CORS limitations)
- With no internet: uses offline stories
- With no API keys: uses offline stories
- With Gemini key: tries Gemini first, falls back to Groq
- With both keys: tries Gemini, then Groq on failure
- Shows loading animation during generation
- Shows error state with retry option
- On success: displays story and continue button

## Architecture

### Domain
```
domain/
├── entities/
│   ├── story.dart         # Pure story entity
│   ├── clue.dart          # Clue with difficulty level
│   └── suspect.dart       # Suspect with name & behavior
├── repositories/
│   └── story_repository.dart    # Abstract interface
└── usecases/
    └── generate_story_usecase.dart
```

### Data
```
data/
├── models/
│   ├── story_model.dart    # Extends Story, JSON serializable
│   ├── clue_model.dart
│   └── suspect_model.dart
├── datasources/
│   ├── story_remote_datasource.dart   # Gemini + Groq API calls
│   └── story_local_datasource.dart    # Offline JSON assets
└── repositories/
    └── story_repository_impl.dart     # Coordinates datasources
```

### Presentation
```
presentation/
├── bloc/
│   ├── story_bloc.dart
│   ├── story_event.dart
│   └── story_state.dart
├── pages/
│   └── story_generation_page.dart
└── widgets/
    ├── story_content_widget.dart
    ├── story_title_widget.dart
    ├── story_card_widget.dart
    ├── story_suspects_info_widget.dart
    ├── story_loading_widget.dart
    ├── story_error_widget.dart
    └── story_continue_button.dart
```

## Design Patterns
- **Strategy Pattern**: AI provider selection (Gemini vs Groq) via `AiProvider` enum
- **Repository Pattern**: Abstract `StoryRepository` interface with `StoryRepositoryImpl`
- **Cascading Fallback**: Try remote → fallback to local
- **Factory Pattern**: `GenerateStoryUseCase` created as factory in DI

## SOLID Principles
- **Single Responsibility**: 
  - `StoryRemoteDataSource` — only API calls
  - `StoryLocalDataSource` — only asset loading
  - `StoryRepositoryImpl` — only coordination logic
  - `GenerateStoryUseCase` — only story generation orchestration
- **Open/Closed**: New AI providers can be added by extending `AiProvider` enum without modifying repository interface.
- **Liskov Substitution**: `StoryModel extends Story` — fully substitutable.
- **Interface Segregation**: `StoryRepository` has only 1 method: `getStory()`.
- **Dependency Inversion**: Domain depends on `StoryRepository` abstraction, not concrete implementation.

## Cascading Fallback Logic (StoryRepositoryImpl)
```dart
Future<Story> getStory({...}) async {
  // 1. Web platform → offline only
  if (kIsWeb) return localDataSource.getOfflineStory(...);
  
  // 2. No connectivity → offline
  if (!await connectivityService.isConnected()) return localDataSource.getOfflineStory(...);
  
  // 3. No API keys → offline
  if (remoteDataSource == null) return localDataSource.getOfflineStory(...);
  
  // 4. Try Gemini, then Groq
  for (final provider in [gemini, groq]) {
    if (remoteDataSource.canUse(provider)) {
      try { return await remoteDataSource.generateStory(..., provider); }
      catch (e) { /* log and try next */ }
    }
  }
  
  // 5. All failed → offline
  return localDataSource.getOfflineStory(...);
}
```

## AI Provider Details
### Gemini
- Model: `gemini-2.5-flash`
- Endpoint: `https://generativelanguage.googleapis.com/v1beta`
- Uses structured output with JSON schema validation

### Groq
- Model: `meta-llama/llama-4-scout-17b-16e-instruct`
- Endpoint: `https://api.groq.com/openai/v1`
- OpenAI-compatible API format

## Offline Stories
- Bundled in `assets/data/stories_offline.json` (Arabic) and `stories_offline_en.json` (English)
- Selected based on `languageCode` parameter
- Shuffled suspects for variety on replay

## Data Flow
```
StoryGenerationPage → BlocProvider(StoryBloc from DI)
  → dispatch GenerateStory(config, languageCode)
  → StoryBloc calls GenerateStoryUseCase
  → UseCase calls StoryRepository.getStory()
  → Repository tries: Web check → connectivity → API keys → Gemini → Groq → offline
  → Returns Story or throws
  → BLoC emits loaded or error state
  → UI displays accordingly
```

## Edge Cases
- **Web platform**: CORS prevents API calls → always offline
- **Partial API key**: Only one key provided → uses only that provider
- **API response parsing failure**: Caught, falls back to next provider
- **Offline story not found for suspect count**: Should not happen (assets cover 4-6)
