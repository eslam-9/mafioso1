import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mafioso/features/online_room/presentation/bloc/online_room_bloc.dart';
import 'package:mafioso/features/online_room/presentation/bloc/online_room_event.dart';
import 'package:mafioso/features/online_room/presentation/bloc/online_room_state.dart';
import 'package:mafioso/features/online_room/domain/entities/room_status.dart';
import 'package:mafioso/features/online_room/data/models/room_model.dart';
import 'package:mafioso/features/online_room/data/models/game_session_model.dart';
import 'package:mafioso/core/services/auth_service.dart';
import 'package:mafioso/core/services/analytics_service.dart';
import 'package:mafioso/core/errors/app_error_exception.dart';
import 'package:mafioso/core/errors/app_error.dart';
import 'package:mafioso/features/online_room/domain/usecases/create_room_usecase.dart';
import 'package:mafioso/features/online_room/domain/usecases/join_room_usecase.dart';
import 'package:mafioso/features/online_room/domain/usecases/leave_room_usecase.dart';
import 'package:mafioso/features/online_room/domain/usecases/kick_player_usecase.dart';
import 'package:mafioso/features/online_room/domain/usecases/select_game_usecase.dart';
import 'package:mafioso/features/online_room/domain/usecases/start_game_usecase.dart';
import 'package:mafioso/features/online_room/domain/usecases/submit_game_event_usecase.dart';
import 'package:mafioso/features/online_room/domain/usecases/get_livekit_token_usecase.dart';
import 'package:mafioso/features/online_room/domain/usecases/get_story_by_id_usecase.dart';
import 'package:mafioso/features/online_room/data/datasources/online_room_realtime_datasource.dart';
import 'package:mafioso/features/online_room/data/datasources/livekit_service.dart';

class MockCreateRoomUseCase extends Mock implements CreateRoomUseCase {}
class MockJoinRoomUseCase extends Mock implements JoinRoomUseCase {}
class MockLeaveRoomUseCase extends Mock implements LeaveRoomUseCase {}
class MockKickPlayerUseCase extends Mock implements KickPlayerUseCase {}
class MockSelectGameUseCase extends Mock implements SelectGameUseCase {}
class MockStartGameUseCase extends Mock implements StartGameUseCase {}
class MockSubmitGameEventUseCase extends Mock implements SubmitGameEventUseCase {}
class MockGetLiveKitTokenUseCase extends Mock implements GetLiveKitTokenUseCase {}
class MockGetStoryByIdUseCase extends Mock implements GetStoryByIdUseCase {}
class MockAuthService extends Mock implements AuthService {}
class MockAnalyticsService extends Mock implements AnalyticsService {}
class MockOnlineRoomRealtimeDataSource extends Mock implements OnlineRoomRealtimeDataSource {}
class MockLiveKitService extends Mock implements LiveKitService {}

void main() {
  late OnlineRoomBloc bloc;
  late CreateRoomUseCase mockCreateRoom;
  late JoinRoomUseCase mockJoinRoom;
  late LeaveRoomUseCase mockLeaveRoom;
  late KickPlayerUseCase mockKickPlayer;
  late SelectGameUseCase mockSelectGame;
  late StartGameUseCase mockStartGame;
  late SubmitGameEventUseCase mockSubmitGameEvent;
  late GetLiveKitTokenUseCase mockGetLiveKitToken;
  late GetStoryByIdUseCase mockGetStoryById;
  late AuthService mockAuthService;
  late AnalyticsService mockAnalyticsService;
  late OnlineRoomRealtimeDataSource mockRealtimeDataSource;
  late LiveKitService mockLiveKitService;

  setUp(() {
    mockCreateRoom = MockCreateRoomUseCase();
    mockJoinRoom = MockJoinRoomUseCase();
    mockLeaveRoom = MockLeaveRoomUseCase();
    mockKickPlayer = MockKickPlayerUseCase();
    mockSelectGame = MockSelectGameUseCase();
    mockStartGame = MockStartGameUseCase();
    mockSubmitGameEvent = MockSubmitGameEventUseCase();
    mockGetLiveKitToken = MockGetLiveKitTokenUseCase();
    mockGetStoryById = MockGetStoryByIdUseCase();
    mockAuthService = MockAuthService();
    mockAnalyticsService = MockAnalyticsService();
    mockRealtimeDataSource = MockOnlineRoomRealtimeDataSource();
    mockLiveKitService = MockLiveKitService();

    when(() => mockAuthService.currentUserId).thenReturn('user1');
    when(() => mockRealtimeDataSource.subscribeToRoom(any())).thenAnswer((_) async {});
    when(() => mockRealtimeDataSource.roomStream).thenAnswer((_) => const Stream.empty());
    when(() => mockRealtimeDataSource.membersStream).thenAnswer((_) => const Stream.empty());
    when(() => mockRealtimeDataSource.sessionStream).thenAnswer((_) => const Stream.empty());
    when(() => mockRealtimeDataSource.gamePlayersStream).thenAnswer((_) => const Stream.empty());
    when(() => mockGetLiveKitToken.call(any())).thenAnswer((_) async => {'token': 'dummy_token', 'url': 'dummy_url'});
    when(() => mockLiveKitService.connect(any(), any())).thenAnswer((_) async {});
    when(() => mockLiveKitService.enableMic(any())).thenAnswer((_) async {});
    when(() => mockLiveKitService.isConnected).thenReturn(false);
    when(() => mockAnalyticsService.logOnlineRoomCreated()).thenAnswer((_) async {});

    bloc = OnlineRoomBloc(
      createRoom: mockCreateRoom,
      joinRoom: mockJoinRoom,
      leaveRoom: mockLeaveRoom,
      kickPlayerUseCase: mockKickPlayer,
      selectGameUseCase: mockSelectGame,
      startGameUseCase: mockStartGame,
      submitGameEventUseCase: mockSubmitGameEvent,
      getLiveKitTokenUseCase: mockGetLiveKitToken,
      getStoryByIdUseCase: mockGetStoryById,
      authService: mockAuthService,
      analyticsService: mockAnalyticsService,
      realtimeDataSource: mockRealtimeDataSource,
      liveKitService: mockLiveKitService,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('CreateRoomRequested', () {
    blocTest<OnlineRoomBloc, OnlineRoomState>(
      'emits inLobby after createRoom success',
      build: () {
        when(() => mockCreateRoom.call(
              name: any(named: 'name'),
              password: any(named: 'password'),
              displayName: any(named: 'displayName'),
            )).thenAnswer((_) async => {'roomId': 'room1', 'code': 'ABCD'});
        return bloc;
      },
      act: (OnlineRoomBloc bloc) => bloc.add(const CreateRoomRequested(name: 'Room 1', displayName: 'Host')),
      expect: () => [
        const OnlineRoomState(status: OnlineRoomStatus.loading),
        isA<OnlineRoomState>()
            .having((s) => s.status, 'status', OnlineRoomStatus.inLobby)
            .having((s) => s.room?.id, 'roomId', 'room1')
            .having((s) => s.isHost, 'isHost', true),
      ],
      verify: (_) {
        verify(() => mockAnalyticsService.logOnlineRoomCreated()).called(1);
        verify(() => mockRealtimeDataSource.subscribeToRoom('room1')).called(1);
        // Verify LiveKit token fetched (fire and forget)
        verify(() => mockGetLiveKitToken.call('room1')).called(1);
      },
    );

    blocTest<OnlineRoomBloc, OnlineRoomState>(
      'emits error on createRoom failure (AppErrorException)',
      build: () {
        when(() => mockCreateRoom.call(
              name: any(named: 'name'),
              password: any(named: 'password'),
              displayName: any(named: 'displayName'),
            )).thenThrow(AppErrorException(AppError('test_error')));
        return bloc;
      },
      act: (OnlineRoomBloc bloc) => bloc.add(const CreateRoomRequested(name: 'Room 1', displayName: 'Host')),
      expect: () => [
        const OnlineRoomState(status: OnlineRoomStatus.loading),
        isA<OnlineRoomState>()
            .having((s) => s.status, 'status', OnlineRoomStatus.error)
            .having((s) => s.error?.key, 'errorKey', 'test_error'),
      ],
    );
  });

  group('RoomUpdated', () {
    test('emits inGame when room status = playing', () {
      final room = RoomModel(
        id: 'room1',
        code: 'ABCD',
        name: 'Room 1',
        hostId: 'user1',
        status: RoomStatus.playing,
        maxPlayers: 8,
      );

      bloc.add(RoomUpdated(room));
      expectLater(
        bloc.stream,
        emits(isA<OnlineRoomState>().having((s) => s.status, 'status', OnlineRoomStatus.inGame)),
      );
    });

    test('emits loading when room status = starting', () {
      final room = RoomModel(
        id: 'room1',
        code: 'ABCD',
        name: 'Room 1',
        hostId: 'user1',
        status: RoomStatus.starting,
        maxPlayers: 8,
      );

      bloc.add(RoomUpdated(room));
      expectLater(
        bloc.stream,
        emits(isA<OnlineRoomState>().having((s) => s.status, 'status', OnlineRoomStatus.loading)),
      );
    });
  });

  group('SessionUpdated (Double Fetch Guard)', () {
    blocTest<OnlineRoomBloc, OnlineRoomState>(
      'does NOT double fetch story when session updates multiple times quickly',
      build: () {
        when(() => mockGetStoryById.call(any())).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return {'title': 'Story 1', 'suspects': [], 'clues': []};
        });
        return bloc;
      },
      act: (OnlineRoomBloc bloc) {
        final session1 = GameSessionModel(
          id: 's1',
          roomId: 'r1',
          storyId: 'story1',
          status: 'playing',
          gameState: 'playing',
          phase: 'clues',
          currentRound: 1,
          revealedClueIndices: const [],
        );
        bloc.add(SessionUpdated(session1));
        bloc.add(SessionUpdated(session1.copyWith(currentRound: 2)));
      },
      verify: (_) {
        // Because of _isFetchingStory flag, it should only be called once
        verify(() => mockGetStoryById.call('story1')).called(1);
      },
    );
  });
}
