import 'package:get_it/get_it.dart';
import 'data/datasources/story_history_local_datasource.dart';
import 'data/repositories/story_history_repository_impl.dart';
import 'domain/repositories/story_history_repository.dart';
import 'domain/usecases/get_pending_uploads_usecase.dart';
import 'domain/usecases/get_saved_stories_usecase.dart';
import 'domain/usecases/mark_as_uploaded_usecase.dart';
import 'domain/usecases/rate_story_usecase.dart';
import 'domain/usecases/save_played_story_usecase.dart';
import 'presentation/bloc/story_history_bloc.dart';

final sl = GetIt.instance;

void initStoryHistory() {
  // Bloc
  sl.registerFactory(
    () => StoryHistoryBloc(
      getSavedStories: sl(),
      savePlayedStory: sl(),
      rateStory: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetSavedStoriesUseCase(sl()));
  sl.registerLazySingleton(() => SavePlayedStoryUseCase(sl()));
  sl.registerLazySingleton(() => RateStoryUseCase(sl()));
  sl.registerLazySingleton(() => GetPendingUploadsUseCase(sl()));
  sl.registerLazySingleton(() => MarkAsUploadedUseCase(sl()));

  // Repository
  sl.registerLazySingleton<StoryHistoryRepository>(
    () => StoryHistoryRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<StoryHistoryLocalDataSource>(
    () => StoryHistoryLocalDataSourceImpl(),
  );
}
