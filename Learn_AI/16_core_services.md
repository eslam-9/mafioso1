# 16 — Core Services

## 1. ConnectivityService
**Location**: `shared/services/connectivity_service.dart`

### Purpose
Checks internet connectivity with dual verification: connectivity_plus status + actual DNS lookup.

### Implementation
```dart
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> isConnected() async {
    // 1. Check connectivity_plus status
    final result = await _connectivity.checkConnectivity();
    final hasConnection = result.contains(wifi) || result.contains(mobile);
    
    // 2. If status check fails, do actual DNS test
    if (!hasConnection) return await _testInternetConnection();
    
    return true;
  }
  
  Future<bool> _testInternetConnection() async {
    // DNS lookup to google.com
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  }
  
  Stream<bool> get connectivityStream => 
    _connectivity.onConnectivityChanged.map(...);
}
```

### Design Decisions
- Dual verification handles emulator false negatives
- DNS test has 5-second timeout
- Stream exposes connectivity changes for reactive use

---

## 2. SoundService
**Location**: `shared/services/sound_service.dart`

### Purpose
Plays sound effects for game events.

### Implementation
```dart
class SoundService {
  final AudioPlayer _player = AudioPlayer();
  bool _isMuted = false;

  Future<void> playSound(SoundEffect effect) async {
    if (_isMuted) return;
    await _player.play(AssetSource(_getSoundPath(effect)));
  }

  void toggleMute() => _isMuted = !_isMuted;
}
```

### Sound Effects
| Effect | File | When |
|--------|------|------|
| roleReveal | audio/role_reveal.mp3 | Player sees their role |
| vote | audio/vote.mp3 | Vote submitted |
| win | audio/win.mp3 | Innocents win |
| lose | audio/lose.mp3 | Killer wins |
| buttonClick | audio/button_click.mp3 | Button tap |

### Known Limitation
Uses single `AudioPlayer` instance — cannot overlap sounds. If a sound is already playing, the new one replaces it.

---

## 3. UploadQueueService
**Location**: `shared/services/upload_queue_service.dart`

### Purpose
Automatically retries pending story uploads when connectivity is restored.

### Implementation
```dart
class UploadQueueService {
  final GetPendingUploadsUseCase getPendingUploads;
  final MarkAsUploadedUseCase markAsUploaded;
  final UploadStoryUseCase uploadStory;
  final RateCommunityStoryUseCase rateCommunityStory;
  final DeviceIdService deviceIdService;
  final Connectivity connectivity;

  final Set<String> _blockedLocalIds = {};  // RLS-denied stories

  void startListening() {
    connectivity.onConnectivityChanged.listen((results) {
      if (hasConnection) flushQueue();
    });
  }

  Future<void> flushQueue() async {
    final pending = await getPendingUploads();
    for (final story in pending) {
      await _uploadSingle(story, deviceId);
    }
  }

  Future<void> _uploadSingle(PlayedStory story, String deviceId) async {
    final storyId = await uploadStory(storyModel.toJson(), deviceId, lang);
    if (story.userRating != null) {
      await rateCommunityStory(storyId, story.userRating!, deviceId);
    }
    await markAsUploaded(story.id);
  }
}
```

### RLS Denial Handling
```dart
bool _isRlsDenied(Object e) {
  if (e is PostgrestException) return e.code == '42501';
  return e.toString().contains('row-level security');
}

if (_isRlsDenied(e)) {
  _blockedLocalIds.add(story.id);  // Stop retrying this story
}
```

### Startup
Registered as lazy singleton, then immediately started:
```dart
getIt<UploadQueueService>()
  ..startListening()
  ..flushQueue();
```

---

## 4. DeviceIdService
**Location**: `core/services/device_id_service.dart`

### Purpose
Generates and persists anonymous device identifier for Supabase operations.

### Implementation
```dart
class DeviceIdService {
  final SharedPreferences _prefs;
  static const _key = 'anonymous_device_id';

  String get deviceId {
    var id = _prefs.getString(_key);
    if (id == null) {
      id = Uuid().v4();  // Generate UUID v4
      _prefs.setString(_key, id);
    }
    return id;
  }
}
```

### Usage
- Supabase story uploads (`uploaded_by_device`)
- Supabase ratings (upsert on `story_id, device_id`)
- Preventing duplicate ratings per device

---

## 5. AppLogger
**Location**: `core/utils/logger.dart`

### Purpose
Centralized logging with context and stack trace support.

### Methods
```dart
AppLogger.logInfo(String message);
AppLogger.logError(String context, Object error, {StackTrace? stackTrace});
AppLogger.logBlocEvent(String blocName, String event);
AppLogger.logBlocState(String blocName, String state);
AppLogger.logNavigation(String routeName);
```

### Design
- Prefixes logs with timestamp and context
- In production, should be replaced with crash reporting (Sentry/Crashlytics)
