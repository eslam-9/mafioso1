# 11 — Feature: Summary

## Overview
Displays game results after the game ends: winner announcement, killer reveal, story twist, game stats, and options to rate, save, replay, or return home.

## OOB Behavior
- Shows win/loss banner (green for innocents win, red for killer wins)
- Reveals killer's identity
- Shows story twist
- Displays game stats: rounds played, eliminations, clues revealed
- Story rating widget (1-5 stars)
- Rating triggers story save + upload queue
- Actions: Play Again, Home, Saved Stories, Community Library
- Win/lose sound plays on entry

## Architecture
**Presentation-heavy** with direct service access (needs refactoring).

```
presentation/
├── pages/
│   └── summary_page.dart    # StatefulWidget with side effects
└── widgets/
    ├── summary_result_banner.dart
    ├── killer_reveal_widget.dart
    ├── story_twist_widget.dart
    ├── game_stats_widget.dart
    └── summary_actions.dart
```

## Design Patterns
- **Builder Pattern**: Page builds side effects in `didChangeDependencies`
- **Facade Pattern**: `SummaryPage` coordinates multiple services (SoundService, StoryHistoryBloc)

## SOLID Principles — VIOLATIONS
- **Single Responsibility**: `SummaryPage` handles UI, sound playback, story saving, and rating — too many responsibilities
- **Dependency Inversion**: Directly calls `di.getIt<SoundService>()` and `di.getIt<StoryHistoryBloc>()` instead of receiving through constructor or BLoC provider

## Key Implementation Details

### Stable Story ID Generation
```dart
String _buildStableStoryId(Story story) {
  final canonical = jsonEncode({
    'title': story.title,
    'intro': story.intro,
    // ... all story fields in canonical order
  });
  final digest = sha256.convert(utf8.encode(canonical)).toString();
  return 'local_$digest';
}
```
**Why**: Ensures the same story always gets the same ID, preventing duplicate saves.

### Side Effects in didChangeDependencies
```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  _handleGameInit();  // Plays sound, saves story
}
```
**Why**: Called once when page is first built with full context. Guarded by `_soundPlayed` and `_storySaved` flags to prevent duplicates.

### Sound Playback
```dart
final soundService = di.getIt<SoundService>();
if (gameState.gameState == domain.GameState.innocentsWin) {
  soundService.playSound(SoundEffect.win);
} else {
  soundService.playSound(SoundEffect.lose);
}
```

### Story Save
```dart
final playedStory = PlayedStory(
  id: _playedStoryId!,
  story: gameState.story!,
  languageCode: context.locale.languageCode,
  playedAt: DateTime.now(),
);
di.getIt<StoryHistoryBloc>().add(SaveStory(playedStory));
```

## Data Flow
```
SummaryPage receives gameState from route args
  → didChangeDependencies fires
  → plays win/lose sound (once)
  → builds stable story ID from SHA-256 hash
  → creates PlayedStory entity
  → dispatches SaveStory to StoryHistoryBloc
  
User rates story → RateStory event
  → StoryHistoryBloc updates rating
  → triggers UploadQueueService.flushQueue()
  
User taps action → navigate to respective screen
```

## Edge Cases
- **No story data**: Shows error message
- **Sound service unavailable**: Silently caught
- **Duplicate save**: Guarded by `_storySaved` flag
- **Rating without connectivity**: Queued for later upload

## Recommended Refactoring
1. Create a `SummaryBloc` to handle sound and save logic
2. Inject `SoundService` through BLoC constructor
3. Move side effects out of `StatefulWidget` into BLoC
4. Use `BlocProvider` instead of direct `getIt` access
