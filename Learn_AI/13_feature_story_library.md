# 13 — Feature: Story Library (Community)

## Overview
Browse, rate, and play community-uploaded stories from Supabase. Features Bayesian-averaged ratings, pagination, and content-hash deduplication.

## OOB Behavior
- Displays paginated list of community stories
- Sorted by Bayesian rating (prevents new stories with 1 five-star rating from ranking above established stories)
- Filter by language (matches app locale) and player count (4/5/6)
- Tap story → replay with that story
- Rate story → upsert rating (one per device per story)
- Pull-to-refresh
- Infinite scroll (load more on scroll)

## Architecture

### Domain
```
domain/
├── entities/
│   └── community_story.dart    # Story + bayesianRating, totalVotes, uploadedAt
├── repositories/
│   └── story_library_repository.dart
└── usecases/
    ├── get_community_stories_usecase.dart
    ├── upload_story_usecase.dart
    └── rate_community_story_usecase.dart
```

### Data
```
data/
├── datasources/
│   └── story_library_remote_datasource.dart    # Supabase operations
└── repositories/
    └── story_library_repository_impl.dart
```

### Presentation
```
presentation/
├── bloc/
│   ├── story_library_bloc.dart
│   ├── story_library_event.dart
│   └── story_library_state.dart
├── pages/
│   └── story_library_page.dart
└── widgets/
    └── (uses shared widgets: StoryStatusBadge, PlayerCountStoryFilterBar)
```

## Design Patterns
- **Repository Pattern**: Abstract interface with Supabase implementation
- **Pagination Pattern**: Offset-based pagination with `page/limit`
- **Deduplication Pattern**: SHA-256 content hash prevents duplicate uploads
- **Bayesian Rating**: Prevents manipulation of rating system

## SOLID Principles
- **Single Responsibility**: DataSource only does Supabase calls. Repository coordinates. UseCases are single-operation.
- **Open/Closed**: New remote backends can implement `StoryLibraryRepository`.
- **Liskov Substitution**: `CommunityStory` is a pure data class, substitutable anywhere.
- **Interface Segregation**: Repository has 3 focused methods.
- **Dependency Inversion**: Domain depends on abstraction.

## Supabase Schema
```sql
-- Table: community_stories
id (uuid, primary key)
content_hash (text, unique)     -- SHA-256 of story content
title, intro, crime_description, twist, killer_name
language_code (text)
suspect_count (int)
story_json (jsonb)              -- Full story JSON
uploaded_by_device (text)
created_at (timestamp)

-- Table: story_ratings
id (uuid, primary key)
story_id (uuid, foreign key)
device_id (text)
rating (int, 1-5)
created_at (timestamp)
-- Unique constraint: (story_id, device_id)

-- View: community_stories_with_ratings
-- Joins stories with aggregated ratings, calculates bayesian_rating
```

## Bayesian Rating Formula
```
bayesian_rating = (C * M + R * r) / (C + R)
Where:
  C = minimum votes required (confidence threshold)
  M = global average rating
  R = actual votes for this story
  r = average rating for this story
```
**Why**: A story with 1 five-star vote shouldn't rank above a story with 100 four-star votes.

## Content Hash Deduplication
```dart
static String _computeHash(Map<String, dynamic> storyJson, String languageCode) {
  final canonical = jsonEncode({
    'title': storyJson['title'],
    'intro': storyJson['intro'],
    'crimeDescription': storyJson['crimeDescription'],
    'killerName': storyJson['killerName'],
    'twist': storyJson['twist'],
    'languageCode': languageCode,
  });
  return sha256.convert(utf8.encode(canonical)).toString();
}
```

**Upload flow with dedup**:
```dart
try {
  // Try INSERT
  final response = await client.from('community_stories').insert({...}).select('id').single();
  return response['id'];
} on PostgrestException catch (e) {
  if (e.code == '23505') {  // Unique constraint violation
    // Story already exists — fetch existing ID by hash
    final existing = await client.from('community_stories')
      .select('id')
      .eq('content_hash', contentHash)
      .single();
    return existing['id'];
  }
  rethrow;
}
```

## BLoC Details
### Events
- `LoadStories({page, playerCount})` — Initial load
- `LoadMore` — Pagination
- `FilterByPlayerCount(int?)` — Filter
- `RateStory(String id, int rating)` — Rate

### State
```dart
abstract class StoryLibraryState extends Equatable {}
class StoryLibraryInitial extends StoryLibraryState {}
class StoryLibraryLoading extends StoryLibraryState {}
class StoryLibraryLoaded(List<CommunityStory>, bool hasMore) extends StoryLibraryState {}
class StoryLibraryError(String message) extends StoryLibraryState {}
```

## Data Flow
```
StoryLibraryPage → BlocProvider(StoryLibraryBloc)
  → dispatches LoadStories(page: 0, languageCode: appLocale)
  → BLoC calls GetCommunityStoriesUseCase
  → UseCase calls Repository
  → Repository calls RemoteDataSource (Supabase)
  → Supabase queries community_stories_with_ratings view
  → Returns List<CommunityStory>
  → BLoC emits Loaded state
  
User scrolls to bottom → LoadMore
  → BLoC increments page, appends to list
  
User rates story → RateStory
  → BLoC calls RateCommunityStoryUseCase
  → Supabase upserts rating
```

## Edge Cases
- **No internet**: BLoC should emit error state
- **Duplicate upload**: Content hash prevents duplicates, fetches existing ID
- **Rating manipulation**: One rating per device (upsert on composite key)
- **RLS denied**: UploadQueueService blocks further retries for that story
- **Empty results**: Shows empty state message
