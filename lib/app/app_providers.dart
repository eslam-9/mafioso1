import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gemini_service.dart';
import '../services/sound_service.dart';
import '../services/connectivity_service.dart';
import '../repositories/story_repository.dart';
import '../viewmodels/game_setup_viewmodel.dart';
import '../viewmodels/story_viewmodel.dart';
import '../viewmodels/role_reveal_viewmodel.dart';
import '../viewmodels/game_viewmodel.dart';

// API Key - TODO: Move to environment variables
const String geminiApiKey = 'AIzaSyCFx0OktsGdOLV-6emYx1nibbMkmQJ5uQM';

// Services Providers
final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService(apiKey: geminiApiKey);
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final soundServiceProvider = Provider<SoundService>((ref) {
  final service = SoundService()..init();
  ref.onDispose(() => service.dispose());
  return service;
});

// Repository Provider
final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  return StoryRepository(
    geminiService: ref.watch(geminiServiceProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
  );
});

// ViewModel Providers
final gameSetupViewModelProvider =
    ChangeNotifierProvider<GameSetupViewModel>((ref) {
  return GameSetupViewModel();
});

final storyViewModelProvider =
    ChangeNotifierProvider<StoryViewModel>((ref) {
  return StoryViewModel(
    storyRepository: ref.watch(storyRepositoryProvider),
  );
});

final roleRevealViewModelProvider =
    ChangeNotifierProvider<RoleRevealViewModel>((ref) {
  return RoleRevealViewModel();
});

final gameViewModelProvider =
    ChangeNotifierProvider<GameViewModel>((ref) {
  return GameViewModel();
});
