import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../shared/services/connectivity_service.dart';
import '../../shared/services/sound_service.dart';
import '../../features/story/data/datasources/story_remote_datasource.dart';
import '../../features/story/data/datasources/story_local_datasource.dart';
import '../../features/story/domain/repositories/story_repository.dart';
import '../../features/story/data/repositories/story_repository_impl.dart';
import '../../features/story/domain/usecases/generate_story_usecase.dart';
import '../../features/story/presentation/bloc/story_bloc.dart';
import '../../features/role_reveal/domain/usecases/assign_roles_usecase.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // Services
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());

  getIt.registerLazySingleton<SoundService>(() => SoundService()..init());

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

  // Story Data Sources
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

  // Story Repository
  getIt.registerLazySingleton<StoryRepository>(
    () => StoryRepositoryImpl(
      remoteDataSource: hasRemoteAiKeys
          ? getIt<StoryRemoteDataSource>()
          : null,
      localDataSource: getIt<StoryLocalDataSource>(),
      connectivityService: getIt<ConnectivityService>(),
    ),
  );

  // Story Use Cases
  getIt.registerFactory<GenerateStoryUseCase>(
    () => GenerateStoryUseCase(getIt<StoryRepository>()),
  );

  // Story BLoC
  getIt.registerFactory<StoryBloc>(
    () => StoryBloc(generateStoryUseCase: getIt<GenerateStoryUseCase>()),
  );

  // Role Reveal Use Cases
  getIt.registerFactory<AssignRolesUseCase>(() => AssignRolesUseCase());
}
