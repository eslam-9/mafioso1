import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // ── Game Flow Events ─────────────────────────────────────

  Future<void> logGameStarted({
    required String mode,
    required int playerCount,
  }) => _analytics.logEvent(
    name: 'game_started',
    parameters: {'mode': mode, 'player_count': playerCount},
  );

  Future<void> logStoryGenerated({
    required String language,
  }) => _analytics.logEvent(
    name: 'story_generated',
    parameters: {'language': language},
  );

  Future<void> logGameCompleted({
    required String winner,
    required int rounds,
    required int playerCount,
    required int eliminatedCount,
  }) => _analytics.logEvent(
    name: 'game_completed',
    parameters: {
      'winner': winner,
      'rounds': rounds,
      'player_count': playerCount,
      'eliminated_count': eliminatedCount,
    },
  );

  // ── Online & Content Events ──────────────────────────────

  Future<void> logOnlineRoomCreated() =>
      _analytics.logEvent(name: 'online_room_created');
      
  Future<void> logOnlineRoomJoined() =>
      _analytics.logEvent(name: 'online_room_joined');
      
  Future<void> logStoryRated({required int rating}) =>
      _analytics.logEvent(
        name: 'story_rated',
        parameters: {'rating': rating},
      );
}
