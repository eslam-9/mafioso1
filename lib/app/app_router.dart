import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/home/home_view.dart';
import '../views/setup/game_mode_view.dart';
import '../views/setup/player_setup_view.dart';
import '../views/story/story_generation_view.dart';
import '../views/roles/role_reveal_view.dart';
import '../views/game/game_view.dart';
import '../views/game/summary_view.dart';

class AppRouter {
  static const String home = '/';
  static const String gameMode = '/game-mode';
  static const String playerSetup = '/player-setup';
  static const String storyGeneration = '/story-generation';
  static const String roleReveal = '/role-reveal';
  static const String game = '/game';
  static const String summary = '/summary';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          // This ensures the provider context is maintained
          // The child is already under MultiProvider from main.dart
          return child;
        },
        routes: [
          GoRoute(
            path: home,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const HomeView(),
            ),
          ),
          GoRoute(
            path: gameMode,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const GameModeView(),
            ),
          ),
          GoRoute(
            path: playerSetup,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const PlayerSetupView(),
            ),
          ),
          GoRoute(
            path: storyGeneration,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const StoryGenerationView(),
            ),
          ),
          GoRoute(
            path: roleReveal,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const RoleRevealView(),
            ),
          ),
          GoRoute(
            path: game,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const GameView(),
            ),
          ),
          GoRoute(
            path: summary,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SummaryView(),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}
