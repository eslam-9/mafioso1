# 04 — Navigation

## Overview
Uses **imperative navigation** with `Navigator.pushNamed()` and `onGenerateRoute` in `MaterialApp`. No `go_router` — the game flow is linear and predictable.

## Route Names (`lib/core/constants/route_names.dart`)
```dart
class RouteNames {
  static const home = '/';
  static const gameMode = '/game-mode';
  static const playerSetup = '/player-setup';
  static const storyGeneration = '/story-generation';
  static const roleReveal = '/role-reveal';
  static const game = '/game';
  static const summary = '/summary';
  static const savedStories = '/saved-stories';
  static const communityLibrary = '/community-library';
}
```

## Route Generator (`lib/core/routing/route_generator.dart`)

### Basic Routes
```dart
case RouteNames.home:
  return _buildRoute(const HomePage(), settings: settings);
```

### Routes with Default Arguments
```dart
case RouteNames.gameMode:
  return _buildRoute(
    const PlayerSetupPage(),
    settings: RouteSettings(
      name: RouteNames.playerSetup,
      arguments: GameConfig(
        mode: GameMode.withoutDetective,
        suspectCount: 4,
        playerNames: List<String>.filled(4, ''),
      ),
    ),
  );
```

### Routes with BLoC Providers (Wrapper Widgets)
```dart
case RouteNames.storyGeneration:
  return _buildRoute(const _StoryGenerationPageWrapper(), settings: settings);

class _StoryGenerationPageWrapper extends StatelessWidget {
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<StoryBloc>(),
      child: const StoryGenerationPage(),
    );
  }
}
```

## Navigation Pattern

### Forward Navigation with Arguments
```dart
Navigator.pushNamed(
  context,
  RouteNames.storyGeneration,
  arguments: {'gameConfig': gameConfig},
);
```

### Reading Arguments in Pages
```dart
final args = ModalRoute.of(context)?.settings.arguments;
if (args is Map && args['gameState'] is presentation.GameState) {
  final gameState = args['gameState'] as presentation.GameState;
}
```

### Back Navigation
```dart
Navigator.pop(context); // Simple back
Navigator.popUntil(context, ModalRoute.withName(RouteNames.home)); // Back to home
```

## Known Limitations
1. **No type safety**: Route arguments are `Map<String, dynamic>` or raw objects
2. **No deep linking**: Cannot open specific screens from external links
3. **No route guards**: No authentication checks on routes
4. **Wrapper widgets are mostly empty**: Some wrappers (`_GamePageWrapper`, `_RoleRevealPageWrapper`) don't actually provide BLoCs — BLoCs are created inside the pages themselves

## Recommended Improvements
- Consider `go_router` for type-safe route arguments and deep linking
- Add route argument validation classes
- Implement route guards for future authentication
