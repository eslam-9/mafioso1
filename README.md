# 🎭 Mafioso - Murder Mystery Game

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.8.1+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.8.1+-0175C2?logo=dart)
![Platform](https://img.shields.io/badge/Platform-Android%20|%20iOS%20|%20Web%20|%20Desktop-blue)

**An interactive murder mystery game built with Flutter**

*AI-powered story generation with full offline support in Egyptian Arabic*

</div>

---

## 📖 Overview

**Mafioso** is a multiplayer murder mystery game where players take on roles of suspects, detectives, and killers. Features AI-generated stories using Google's Gemini API with complete offline fallback support.

### 🎯 Key Features

- 🤖 **AI Story Generation** - Unique mysteries via Gemini API
- 📴 **Offline-First** - Pre-loaded fallback stories
- 🎭 **Role-Based Gameplay** - Killer, Detective, Innocent
- 🔍 **Progressive Clues** - 5 difficulty levels
- 🗳️ **Voting System** - Democratic elimination
- 🎨 **Dark Theme** - Immersive mafia aesthetic
- 🔊 **Sound Effects** - Audio feedback
- 🌍 **Cross-Platform** - Android, iOS, Web, Desktop

## 🏗️ Architecture

**Pattern**: MVVM (Model-View-ViewModel) with Riverpod

```
lib/
├── app/                          # Configuration
│   ├── app_providers.dart        # Dependency injection
│   ├── app_router.dart           # GoRouter navigation
│   └── app_theme.dart            # Material theme
├── models/                       # Data models
│   ├── player.dart               # Player with roles
│   ├── game_config.dart          # Game settings
│   ├── story.dart                # Story structure
│   └── vote_result.dart          # Vote results
├── services/                     # Business logic
│   ├── gemini_service.dart       # AI integration
│   ├── sound_service.dart        # Audio
│   ├── connectivity_service.dart # Network
│   └── error_handler.dart        # Error management
├── repositories/                 # Data layer
│   └── story_repository.dart     # Story management
├── viewmodels/                   # State management
│   ├── game_setup_viewmodel.dart
│   ├── story_viewmodel.dart
│   ├── role_reveal_viewmodel.dart
│   └── game_viewmodel.dart
├── views/                        # UI screens
│   ├── home/                     # Landing page
│   ├── setup/                    # Game setup
│   ├── story/                    # Story generation
│   ├── roles/                    # Role reveal
│   └── game/                     # Main game & summary
└── widgets/                      # Reusable components
```

## 🚀 Installation

### Prerequisites
- Flutter SDK 3.8.1+
- Dart SDK 3.8.1+
- Gemini API key (optional)

### Setup

```bash
# 1. Clone repository
git clone https://github.com/yourusername/mafioso.git
cd mafioso

# 2. Install dependencies
flutter pub get

# 3. Run app
flutter run

# 4. Build for production
flutter build apk         # Android
flutter build ios         # iOS
flutter build web         # Web
flutter build windows     # Windows
```

### API Configuration (Optional)

For AI story generation, get a key from [Google AI Studio](https://makersuite.google.com/app/apikey)

Update `lib/app/app_providers.dart`:
```dart
static const String geminiApiKey = 'YOUR_API_KEY';
```

> ⚠️ **Production**: Use environment variables instead of hardcoding

## 🎯 How to Play

### Game Flow

1. **Select Mode** - With/without detective
2. **Setup Players** - 4-6 players, enter names
3. **Generate Story** - AI or offline
4. **Reveal Roles** - Secret role assignment
   - 🔪 **Killer** - Survive without being caught
   - 🕵️ **Detective** - Guide investigation (optional)
   - 👤 **Innocent** - Find the killer
5. **Investigation** - Read story, reveal 5 clues progressively
6. **Vote** - Eliminate suspects democratically
7. **Win Conditions**
   - **Innocents**: Eliminate the killer
   - **Killer**: Survive until 2 players remain

## 📦 Dependencies

### Core
- **flutter_riverpod** ^2.6.1 - State management
- **go_router** ^14.6.2 - Navigation
- **dio** ^5.7.0 - HTTP client
- **flutter_animate** ^4.5.0 - Animations
- **audioplayers** ^6.1.0 - Sound effects
- **google_fonts** ^6.2.1 - Typography
- **connectivity_plus** ^6.1.0 - Network detection
- **shared_preferences** ^2.3.3 - Local storage

### Dev
- **flutter_test** - Testing framework
- **mockito** ^5.4.4 - Mocking
- **build_runner** ^2.4.8 - Code generation
- **riverpod_generator** ^2.6.2 - Riverpod codegen

## 🎨 Customization

### Theme
Edit `lib/app/app_theme.dart`:
```dart
static const Color primaryRed = Color(0xFF8B0000);
static const Color bloodRed = Color(0xFFDC143C);
static const Color darkBackground = Color(0xFF0D0D0D);
```

### Offline Stories
Edit `assets/data/stories_offline.json`:
```json
{
  "stories": [{
    "title": "عنوان القصة",
    "intro": "مقدمة...",
    "suspects": [...],
    "clues": [
      {"text": "دليل", "difficulty": "veryEasy"}
    ],
    "killerName": "القاتل"
  }]
}
```

### Sound Effects
Add to `assets/audio/`:
- `role_reveal.mp3`, `vote.mp3`, `win.mp3`, `lose.mp3`

## 🔧 Configuration

### Environment Variables (Recommended)
```yaml
# pubspec.yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

```env
# .env
GEMINI_API_KEY=your_key_here
```

```dart
// main.dart
await dotenv.load(fileName: ".env");
final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
```

### Offline Fallback
Automatic when:
- No internet
- API fails
- Invalid key
- Quota exceeded

## 📱 Platforms

| Platform | Status | Min Version |
|----------|--------|-------------|
| Android | ✅ | API 21+ |
| iOS | ✅ | 12.0+ |
| Web | ✅ | Modern browsers |
| Windows | ✅ | 10+ |
| macOS | ✅ | 10.14+ |
| Linux | ✅ | Ubuntu 20.04+ |

## 🐛 Troubleshooting

### Story Generation Issues
```bash
# Check logs
flutter run --verbose

# Solutions:
- Verify internet connection
- Check API key validity
- Confirm API quota
- App auto-falls back to offline
```

### Audio Issues
- Verify files in `assets/audio/`
- Check `pubspec.yaml` includes assets
- Test device volume

### Build Errors
```bash
flutter clean
flutter pub get
flutter run
```

### Provider Errors
- Wrap app with `ProviderScope`
- Use `Consumer` or `context.watch()`
- Avoid `context.read()` in `initState`

## 🧪 Testing

```bash
# Run all tests
flutter test

# With coverage
flutter test --coverage

# Specific test
flutter test test/viewmodels/game_viewmodel_test.dart
```

## 📚 Documentation

- [PROJECT_ANALYSIS.md](PROJECT_ANALYSIS.md) - Code analysis
- [TESTING_AND_ERROR_HANDLING.md](TESTING_AND_ERROR_HANDLING.md) - Testing guide
- [WEB_PLATFORM_INFO.md](WEB_PLATFORM_INFO.md) - Web deployment
- [CHECK_INTERNET.md](CHECK_INTERNET.md) - Connectivity

## 🔑 Key Features Explained

### AI Story Generation
- Uses Gemini 2.5 Flash model
- Generates stories in Egyptian Arabic
- Adapts to player count (4-6)
- 5 difficulty-based clues
- Automatic offline fallback

### State Management
- Riverpod for reactive state
- ViewModels extend ChangeNotifier
- Clean separation of concerns
- Testable architecture

### Game Logic
- Role assignment algorithm
- Vote counting system
- Win condition detection
- Round progression
- Player elimination

## 🚀 Performance

- Lazy loading of stories
- Efficient state updates
- Optimized animations
- Asset preloading
- Memory management

## 🔒 Security Notes

⚠️ **Important**: 
- Don't commit API keys
- Use environment variables
- Implement rate limiting
- Validate user inputs
- Sanitize story content

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Add tests for new features
4. Submit a pull request

## 📄 License

MIT License - see [LICENSE](LICENSE) file

## 👥 Authors

Built with ❤️ using Flutter

## 🙏 Acknowledgments

- Google Gemini AI for story generation
- Flutter team for the framework
- Riverpod for state management
- Community contributors

---

<div align="center">

**🎭 Enjoy the mystery! Can you find the killer? 🔍**

[Report Bug](https://github.com/yourusername/mafioso/issues) • [Request Feature](https://github.com/yourusername/mafioso/issues)

</div>
