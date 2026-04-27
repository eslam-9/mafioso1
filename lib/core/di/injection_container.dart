import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/services/connectivity_service.dart';
import '../../shared/services/sound_service.dart';
import '../../shared/services/upload_queue_service.dart';
import '../../core/services/device_id_service.dart';
import '../../features/story/data/datasources/story_remote_datasource.dart';
import '../../features/story/data/datasources/story_local_datasource.dart';
import '../../features/story/domain/repositories/story_repository.dart';
import '../../features/story/data/repositories/story_repository_impl.dart';
import '../../features/story/domain/usecases/generate_story_usecase.dart';
import '../../features/story/presentation/bloc/story_bloc.dart';
import '../../features/role_reveal/domain/usecases/assign_roles_usecase.dart';
import '../../features/story_history/story_history_injection.dart';
import '../../features/story_library/data/datasources/story_library_remote_datasource.dart';
import '../../features/story_library/data/repositories/story_library_repository_impl.dart';
import '../../features/story_library/domain/repositories/story_library_repository.dart';
import '../../features/story_library/domain/usecases/get_community_stories_usecase.dart';
import '../../features/story_library/domain/usecases/upload_story_usecase.dart';
import '../../features/story_library/domain/usecases/rate_community_story_usecase.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // Features — Story History (Hive, no async needed)
  initStoryHistory();

  // External — SharedPreferences (needed for DeviceIdService)
  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => prefs);

  // Core services
  getIt.registerLazySingleton<DeviceIdService>(
    () => DeviceIdService(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  getIt.registerLazySingleton<SoundService>(() => SoundService()..init());
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());

  // Network — separate Dio instances so Gemini and Groq never share state
  getIt.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json'},
      ),
    ),
    instanceName: 'geminiDio',
  );
  getIt.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: 'https://api.groq.com/openai/v1',
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json'},
      ),
    ),
    instanceName: 'groqDio',
  );

  // Environment
  const geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  const groqApiKey = String.fromEnvironment('GROQ_API_KEY');
  final hasRemoteAiKeys =
      geminiApiKey.trim().isNotEmpty && groqApiKey.trim().isNotEmpty;

  // Story AI Data Sources
  if (hasRemoteAiKeys) {
    getIt.registerLazySingleton<StoryRemoteDataSource>(
      () => StoryRemoteDataSourceImpl(
        geminiDio: getIt<Dio>(instanceName: 'geminiDio'),
        groqDio: getIt<Dio>(instanceName: 'groqDio'),
        geminiApiKey: geminiApiKey,
        groqApiKey: groqApiKey,
      ),
    );
  }
  getIt.registerLazySingleton<StoryLocalDataSource>(
    () => StoryLocalDataSourceImpl(),
  );

  // Story Repository + Use Cases + BLoC
  getIt.registerLazySingleton<StoryRepository>(
    () => StoryRepositoryImpl(
      remoteDataSource: hasRemoteAiKeys ? getIt<StoryRemoteDataSource>() : null,
      localDataSource: getIt<StoryLocalDataSource>(),
      connectivityService: getIt<ConnectivityService>(),
    ),
  );
  getIt.registerFactory<GenerateStoryUseCase>(
    () => GenerateStoryUseCase(getIt<StoryRepository>()),
  );
  getIt.registerFactory<StoryBloc>(
    () => StoryBloc(generateStoryUseCase: getIt<GenerateStoryUseCase>()),
  );

  // Role Reveal
  getIt.registerFactory<AssignRolesUseCase>(() => AssignRolesUseCase());

  // Community Library — Supabase
  getIt.registerLazySingleton<StoryLibraryRemoteDataSource>(
    () => StoryLibraryRemoteDataSourceImpl(client: Supabase.instance.client),
  );
  getIt.registerLazySingleton<StoryLibraryRepository>(
    () => StoryLibraryRepositoryImpl(
      remoteDataSource: getIt<StoryLibraryRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton<GetCommunityStoriesUseCase>(
    () => GetCommunityStoriesUseCase(getIt<StoryLibraryRepository>()),
  );
  getIt.registerLazySingleton<UploadStoryUseCase>(
    () => UploadStoryUseCase(getIt<StoryLibraryRepository>()),
  );
  getIt.registerLazySingleton<RateCommunityStoryUseCase>(
    () => RateCommunityStoryUseCase(getIt<StoryLibraryRepository>()),
  );

  // Upload Queue — offline retry service
  getIt.registerLazySingleton<UploadQueueService>(
    () => UploadQueueService(
      getPendingUploads: getIt(),
      markAsUploaded: getIt(),
      uploadStory: getIt(),
      rateCommunityStory: getIt(),
      deviceIdService: getIt(),
      connectivity: getIt(),
    ),
  );

  // Start listening for connectivity and flush any pending queue
  getIt<UploadQueueService>()
    ..startListening()
    ..flushQueue();
}
