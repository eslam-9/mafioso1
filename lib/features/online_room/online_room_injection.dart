import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/datasources/online_room_remote_datasource.dart';
import 'data/repositories/online_room_repository_impl.dart';
import 'domain/repositories/online_room_repository.dart';
import 'domain/usecases/create_room_usecase.dart';
import 'domain/usecases/join_room_usecase.dart';
import 'domain/usecases/leave_room_usecase.dart';
import 'domain/usecases/kick_player_usecase.dart';
import 'domain/usecases/select_game_usecase.dart';
import 'domain/usecases/start_game_usecase.dart';
import 'domain/usecases/submit_game_event_usecase.dart';
import 'domain/usecases/get_livekit_token_usecase.dart';
import 'domain/usecases/get_story_by_id_usecase.dart';
import 'presentation/bloc/online_room_bloc.dart';
import 'data/datasources/online_room_realtime_datasource.dart';
import 'data/datasources/livekit_service.dart';

final sl = GetIt.instance;

void initOnlineRoom() {
  // Use cases
  sl.registerLazySingleton(() => CreateRoomUseCase(sl()));
  sl.registerLazySingleton(() => JoinRoomUseCase(sl()));
  sl.registerLazySingleton(() => LeaveRoomUseCase(sl()));
  sl.registerLazySingleton(() => KickPlayerUseCase(sl()));
  sl.registerLazySingleton(() => SelectGameUseCase(sl()));
  sl.registerLazySingleton(() => StartGameUseCase(sl()));
  sl.registerLazySingleton(() => SubmitGameEventUseCase(sl()));
  sl.registerLazySingleton(() => GetLiveKitTokenUseCase(sl()));
  sl.registerLazySingleton(() => GetStoryByIdUseCase(sl()));

  // Repository
  sl.registerLazySingleton<OnlineRoomRepository>(
    () => OnlineRoomRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<OnlineRoomRemoteDataSource>(
    () => OnlineRoomRemoteDataSource(Supabase.instance.client),
  );
  sl.registerLazySingleton<OnlineRoomRealtimeDataSource>(
    () => OnlineRoomRealtimeDataSource(Supabase.instance.client),
  );
  sl.registerLazySingleton<LiveKitService>(() => LiveKitService());

  // Bloc — registered as LazySingleton so the same instance is shared across
  // all online-room routes (create → lobby → game). State is reset on leave.
  sl.registerLazySingleton(() => OnlineRoomBloc(
    createRoom: sl(),
    joinRoom: sl(),
    leaveRoom: sl(),
    authService: sl(),
    realtimeDataSource: sl(),
    kickPlayerUseCase: sl(),
    selectGameUseCase: sl(),
    startGameUseCase: sl(),
    getLiveKitTokenUseCase: sl(),
    getStoryByIdUseCase: sl(),
    submitGameEventUseCase: sl(),
    liveKitService: sl(),
  ));
}
