import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  // Network — separate Dio instances so Gemini and Grok never share state
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
    instanceName: 'grokDio',
  );

  // Environment
  final geminiApiKey = dotenv.env['GEMINI_API_KEY'];
  final grokApiKey = dotenv.env['GROK_API_KEY'];
  if (geminiApiKey == null) {
    throw Exception('GEMINI_API_KEY not found in .env file');
  }
  if (grokApiKey == null) {
    throw Exception('GROK_API_KEY not found in .env file');
  }
  getIt.registerLazySingleton<String>(
    () => geminiApiKey,
    instanceName: 'geminiApiKey',
  );
  getIt.registerLazySingleton<String>(
    () => grokApiKey,
    instanceName: 'grokApiKey',
  );

  // Story Data Sources
  getIt.registerLazySingleton<StoryRemoteDataSource>(
    () => StoryRemoteDataSourceImpl(
      geminiDio: getIt<Dio>(instanceName: 'geminiDio'),
      grokDio: getIt<Dio>(instanceName: 'grokDio'),
      geminiApiKey: getIt<String>(instanceName: 'geminiApiKey'),
      grokApiKey: getIt<String>(instanceName: 'grokApiKey'),
    ),
  );

  getIt.registerLazySingleton<StoryLocalDataSource>(
    () => StoryLocalDataSourceImpl(),
  );

  // Story Repository
  getIt.registerLazySingleton<StoryRepository>(
    () => StoryRepositoryImpl(
      remoteDataSource: getIt<StoryRemoteDataSource>(),
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
