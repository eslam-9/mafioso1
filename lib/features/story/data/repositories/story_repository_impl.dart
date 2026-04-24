import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/ai_provider/ai_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/story.dart';
import '../../domain/repositories/story_repository.dart';
import '../../../../shared/services/connectivity_service.dart';
import '../datasources/story_remote_datasource.dart';
import '../datasources/story_local_datasource.dart';

class StoryRepositoryImpl implements StoryRepository {
  final StoryRemoteDataSource? remoteDataSource;
  final StoryLocalDataSource localDataSource;
  final ConnectivityService connectivityService;

  StoryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
  });

  @override
  Future<Story> getStory({
    required int suspectCount,
    required bool hasDetective,
    required String languageCode,
  }) async {
    AppLogger.logInfo('Starting story generation...');
    AppLogger.logInfo(
      'Suspect count: $suspectCount, Has detective: $hasDetective, Language: $languageCode',
    );

    if (kIsWeb) {
      AppLogger.logInfo(
        'Running on WEB platform - using offline stories due to CORS',
      );
      return localDataSource.getOfflineStory(suspectCount, languageCode);
    }

    AppLogger.logInfo('Checking internet connectivity...');
    final isConnected = await connectivityService.isConnected();
    AppLogger.logInfo('Internet connected: $isConnected');

    if (!isConnected) {
      AppLogger.logInfo(
        'No internet connection detected - using offline stories',
      );
      return localDataSource.getOfflineStory(suspectCount, languageCode);
    }

    if (remoteDataSource == null) {
      AppLogger.logInfo(
        'No AI keys available via --dart-define - using offline stories',
      );
      return localDataSource.getOfflineStory(suspectCount, languageCode);
    }

    // --- Gemini attempt ---
    try {
      AppLogger.logInfo('Attempting Gemini API...');
      final story = await remoteDataSource!.generateStory(
        suspectCount: suspectCount,
        hasDetective: hasDetective,
        languageCode: languageCode,
        aiProvider: AiProvider.gemini,
      );
      AppLogger.logInfo('SUCCESS! Got story from GEMINI: "${story.title}"');
      return story;
    } catch (e) {
      AppLogger.logError('StoryRepository [Gemini]', e);
      AppLogger.logInfo('Gemini failed! Falling back to Groq...');
    }

    // --- Groq fallback ---
    try {
      AppLogger.logInfo('Attempting Groq API...');
      final story = await remoteDataSource!.generateStory(
        suspectCount: suspectCount,
        hasDetective: hasDetective,
        languageCode: languageCode,
        aiProvider: AiProvider.groq,
      );
      AppLogger.logInfo('SUCCESS! Got story from GROQ: "${story.title}"');
      return story;
    } catch (e) {
      AppLogger.logError('StoryRepository [Groq]', e);
      AppLogger.logInfo('Groq also failed! Falling back to offline stories...');
    }

    // --- Offline fallback ---
    return localDataSource.getOfflineStory(suspectCount, languageCode);
  }
}
