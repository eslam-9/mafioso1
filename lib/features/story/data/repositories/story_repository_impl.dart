import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/utils/logger.dart';
import '../../domain/entities/story.dart';
import '../../domain/repositories/story_repository.dart';
import '../../../../shared/services/connectivity_service.dart';
import '../datasources/story_remote_datasource.dart';
import '../datasources/story_local_datasource.dart';

class StoryRepositoryImpl implements StoryRepository {
  final StoryRemoteDataSource remoteDataSource;
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

    // Web browsers have CORS restrictions
    if (kIsWeb) {
      AppLogger.logInfo(
        'Running on WEB platform - using offline stories due to CORS',
      );
      return await localDataSource.getOfflineStory(suspectCount, languageCode);
    }

    // Check connectivity for mobile/desktop platforms
    AppLogger.logInfo('Checking internet connectivity...');
    final isConnected = await connectivityService.isConnected();
    AppLogger.logInfo('Internet connected: $isConnected');

    if (isConnected) {
      try {
        AppLogger.logInfo('Attempting to call Gemini API...');
        final story = await remoteDataSource.generateStory(
          suspectCount: suspectCount,
          hasDetective: hasDetective,
          languageCode: languageCode,
        );
        AppLogger.logInfo(
          'SUCCESS! Got story from Gemini API: "${story.title}"',
        );
        return story;
      } catch (e) {
        AppLogger.logError('StoryRepository', e);
        AppLogger.logInfo('GEMINI API FAILED! Falling back to offline stories');
        return await localDataSource.getOfflineStory(
          suspectCount,
          languageCode,
        );
      }
    } else {
      AppLogger.logInfo(
        'No internet connection detected - using offline stories',
      );
      return await localDataSource.getOfflineStory(suspectCount, languageCode);
    }
  }
}
