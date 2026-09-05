import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/ai_provider/ai_provider.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/errors/app_error_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/story.dart';
import '../../domain/repositories/story_repository.dart';
import '../../domain/usecases/get_community_fallback_story_usecase.dart';
import '../../../../shared/services/connectivity_service.dart';
import '../datasources/story_remote_datasource.dart';

class StoryRepositoryImpl implements StoryRepository {
  final StoryRemoteDataSource? remoteDataSource;
  final GetCommunityFallbackStoryUseCase communityFallbackStory;
  final ConnectivityService connectivityService;

  StoryRepositoryImpl({
    required this.remoteDataSource,
    required this.communityFallbackStory,
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
        'Running on WEB platform - skipping AI due to CORS',
      );
      return _fallbackToCommunityStory(suspectCount, languageCode);
    }

    AppLogger.logInfo('Checking internet connectivity...');
    final isConnected = await connectivityService.isConnected();
    AppLogger.logInfo('Internet connected: $isConnected');

    if (!isConnected) {
      AppLogger.logInfo(
        'No internet connection detected - trying community fallback',
      );
      return _fallbackToCommunityStory(suspectCount, languageCode);
    }

    if (remoteDataSource != null) {
      final providersToTry = <AiProvider>[];
      if (remoteDataSource!.canUse(AiProvider.gemini)) {
        providersToTry.add(AiProvider.gemini);
      }
      if (remoteDataSource!.canUse(AiProvider.groq)) {
        providersToTry.add(AiProvider.groq);
      }

      for (final provider in providersToTry) {
        try {
          AppLogger.logInfo('Attempting ${provider.name} API...');
          final story = await remoteDataSource!.generateStory(
            suspectCount: suspectCount,
            hasDetective: hasDetective,
            languageCode: languageCode,
            aiProvider: provider,
          );
          AppLogger.logInfo(
            'SUCCESS! Got story from ${provider.name.toUpperCase()}: "${story.title}"',
          );
          return story;
        } catch (e) {
          AppLogger.logError('StoryRepository [${provider.name}]', e);
        }
      }
    }

    AppLogger.logInfo('No AI story available - using community fallback');
    return _fallbackToCommunityStory(suspectCount, languageCode);
  }

  Future<Story> _fallbackToCommunityStory(
    int suspectCount,
    String languageCode,
  ) async {
    final story = await communityFallbackStory(
      suspectCount: suspectCount,
      languageCode: languageCode,
    );
    if (story != null) {
      AppLogger.logInfo('SUCCESS! Got community story: "${story.title}"');
      return story;
    }

    AppLogger.logError(
      'StoryRepository',
      const AppError('error_no_story_available'),
    );
    throw const AppErrorException(AppError('error_no_story_available'));
  }
}
