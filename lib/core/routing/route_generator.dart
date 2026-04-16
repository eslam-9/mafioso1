import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/route_names.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/game_setup/presentation/pages/game_mode_page.dart';
import '../../features/game_setup/presentation/pages/player_setup_page.dart';
import '../../features/game_setup/presentation/bloc/game_setup_bloc.dart';
import '../../features/story/presentation/pages/story_generation_page.dart';
import '../../features/story/presentation/bloc/story_bloc.dart';
import '../../features/role_reveal/presentation/pages/role_reveal_page.dart';
import '../../features/game_result/presentation/pages/game_page.dart';
import '../../features/game_result/presentation/pages/summary_page.dart';
import '../../core/di/injection_container.dart';

class RouteGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        return _buildRoute(const HomePage(), settings: settings);

      case RouteNames.gameMode:
        return _buildRoute(const _GameModePageWrapper(), settings: settings);

      case RouteNames.playerSetup:
        return _buildRoute(const _PlayerSetupPageWrapper(), settings: settings);

      case RouteNames.storyGeneration:
        return _buildRoute(
          const _StoryGenerationPageWrapper(),
          settings: settings,
        );

      case RouteNames.roleReveal:
        return _buildRoute(const _RoleRevealPageWrapper(), settings: settings);

      case RouteNames.game:
        return _buildRoute(const _GamePageWrapper(), settings: settings);

      case RouteNames.summary:
        return _buildRoute(const _SummaryPageWrapper(), settings: settings);

      default:
        return _buildRoute(
          _ErrorPage(message: 'Page not found: ${settings.name}'),
          settings: settings,
        );
    }
  }

  static Route<dynamic> _buildRoute(
    Widget page, {
    required RouteSettings settings,
  }) {
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}

// Wrapper widgets to provide BLoC context
class _GameModePageWrapper extends StatelessWidget {
  const _GameModePageWrapper();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameSetupBloc(),
      child: const GameModePage(),
    );
  }
}

class _PlayerSetupPageWrapper extends StatelessWidget {
  const _PlayerSetupPageWrapper();

  @override
  Widget build(BuildContext context) {
    // PlayerSetupPage will create its own BLoC and restore state from route arguments
    return const PlayerSetupPage();
  }
}

class _StoryGenerationPageWrapper extends StatelessWidget {
  const _StoryGenerationPageWrapper();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<StoryBloc>(),
      child: const StoryGenerationPage(),
    );
  }
}

class _RoleRevealPageWrapper extends StatelessWidget {
  const _RoleRevealPageWrapper();

  @override
  Widget build(BuildContext context) {
    return const RoleRevealPage();
  }
}

class _GamePageWrapper extends StatelessWidget {
  const _GamePageWrapper();

  @override
  Widget build(BuildContext context) {
    return const GamePage();
  }
}

class _SummaryPageWrapper extends StatelessWidget {
  const _SummaryPageWrapper();

  @override
  Widget build(BuildContext context) {
    return const SummaryPage();
  }
}

class _ErrorPage extends StatelessWidget {
  final String message;

  const _ErrorPage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(message)));
  }
}
