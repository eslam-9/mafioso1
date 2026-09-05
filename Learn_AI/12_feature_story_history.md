# 12 — Feature: Story History

## Overview
Local storage of played stories with CRUD operations, ratings, and automatic upload queue integration.

## OOB Behavior
- Displays list of saved stories (newest first)
- Each story card shows: title, date played, rating, player count, upload status
- Filter by player count (All, 4, 5, 6)
- Tap story → replay with that story (no AI regeneration)
- Delete story → removes from Hive
- Rate story → updates local rating, triggers upload queue
- Max 50 stories (FIFO eviction)

## Architecture

### Domain
```
domain/
├── entities/
│   └── played_story.dart    # Story + metadata (rating, playedAt, isUploaded)
├── repositories/
│   └── story_history_repository.dart
└── usecases/
    ├── get_saved_stories_usecase.dart
    ├── save_played_story_usecase.dart
    ├── delete_story_usecase.dart
    ├── rate_story_usecase.dart
    ├── get_pending_uploads_usecase.dart
    └── mark_as_uploaded_usecase.dart
```

### Data
```
data/
├── models/
│   └── played_story_model.dart    # HiveObject, stores story as JSON string
├── datasources/
│   └── story_history_local_datasource.dart    # Hive box operations
└── repositories/
    └── story_history_repository_impl.dart
```

### Presentation
```
presentation/
├── bloc/
│   ├── story_history_bloc.dart
│   ├── story_history_event.dart
│   └── story_history_state.dart
├── pages/
│   └── saved_stories_page.dart
└── widgets/
    └── story_rating_widget.dart
```

## Design Patterns
- **Repository Pattern**: Abstract interface with Hive implementation
- **Adapter Pattern**: `PlayedStoryModel` adapts between Hive storage and domain `PlayedStory`
- **Mediator Pattern**: `UploadQueueService` coordinates between history and library features

## SOLID Principles
- **Single Responsibility**: Each UseCase does one operation. DataSource only handles Hive.
- **Open/Closed**: New storage backends can implement `StoryHistoryRepository` without changing domain.
- **Liskov Substitution**: `PlayedStoryModel.toEntity()` returns domain entity — fully substitutable.
- **Interface Segregation**: Repository has focused methods (get, save, delete, rate).
- **Dependency Inversion**: Domain depends on repository abstraction.

## Hive Storage Details
```dart
@HiveType(typeId: 0)
class PlayedStoryModel extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String storyJson;    // Full story as JSON string
  @HiveField(2) final DateTime playedAt;
  @HiveField(3) final int? userRating;
  @HiveField(4) final bool isUploaded;
  @HiveField(5) final String languageCode;
}
```

**Why JSON string for story**: Avoids complex nested Hive objects. Story is serialized once and deserialized on read.

### FIFO Eviction (Max 50 Stories)
```dart
// In local datasource
if (box.length >= 50) {
  final oldestKey = box.keys.first;  // Hive maintains insertion order
  box.delete(oldestKey);
}
```

## BLoC Details
### Events
- `LoadSavedStories` — Fetch all from Hive
- `SaveStory(PlayedStory)` — Save new story
- `DeleteStory(String id)` — Remove story
- `RateStory(String id, int rating)` — Update rating

### State
```dart
abstract class StoryHistoryState extends Equatable {}
class StoryHistoryInitial extends StoryHistoryState {}
class StoryHistoryLoading extends StoryHistoryState {}
class StoryHistoryLoaded(List<PlayedStory>) extends StoryHistoryState {}
class StoryHistoryError(String message) extends StoryHistoryState {}
```

## Upload Queue Integration
```dart
// After rating a story
await rateStory(event.id, event.rating);
unawaited(uploadQueueService.flushQueue());  // Fire-and-forget
```

## Data Flow
```
SavedStoriesPage → BlocProvider(StoryHistoryBloc from DI)
  → dispatches LoadSavedStories
  → BLoC calls GetSavedStoriesUseCase
  → UseCase calls Repository
  → Repository calls LocalDataSource (Hive)
  → Returns List<PlayedStory>
  → BLoC emits Loaded state
  → UI displays list
  
User rates story → RateStory event
  → BLoC calls RateStoryUseCase
  → Repository updates Hive
  → triggers UploadQueueService.flushQueue()
```

## Edge Cases
- **Hive box full**: Oldest story evicted (FIFO)
- **Story JSON corruption**: Caught during deserialization, story skipped
- **Rating before upload**: Story queued for upload with rating
- **Delete before upload**: Story removed locally, upload cancelled
