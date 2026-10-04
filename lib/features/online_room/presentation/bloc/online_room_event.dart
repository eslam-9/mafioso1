import 'package:equatable/equatable.dart';
import '../../data/models/room_model.dart';
import '../../domain/entities/room_member.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/entities/game_player.dart';
import '../../../story/domain/entities/story.dart';

abstract class OnlineRoomEvent extends Equatable {
  const OnlineRoomEvent();

  @override
  List<Object?> get props => [];
}

class CreateRoomRequested extends OnlineRoomEvent {
  final String name;
  final String? password;
  final String displayName;

  const CreateRoomRequested({
    required this.name,
    this.password,
    required this.displayName,
  });

  @override
  List<Object?> get props => [name, password, displayName];
}

class JoinRoomRequested extends OnlineRoomEvent {
  final String code;
  final String? password;
  final String displayName;

  const JoinRoomRequested({
    required this.code,
    this.password,
    required this.displayName,
  });

  @override
  List<Object?> get props => [code, password, displayName];
}

class LeaveRoomRequested extends OnlineRoomEvent {}

class SelectGameRequested extends OnlineRoomEvent {
  final String storyId;
  final String gameMode;

  const SelectGameRequested({required this.storyId, required this.gameMode});

  @override
  List<Object?> get props => [storyId, gameMode];
}

class KickPlayerRequested extends OnlineRoomEvent {
  final String userId;

  const KickPlayerRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class StartGameRequested extends OnlineRoomEvent {}

class SubmitGameEventRequested extends OnlineRoomEvent {
  final String eventType;
  final Map<String, dynamic> payload;

  const SubmitGameEventRequested({
    required this.eventType,
    required this.payload,
  });

  @override
  List<Object?> get props => [eventType, payload];
}

// Internal Realtime events (dispatched by the Bloc itself from stream listeners)
class RoomUpdated extends OnlineRoomEvent {
  final RoomModel room;
  const RoomUpdated(this.room);
  @override
  List<Object?> get props => [room];
}

class MembersUpdated extends OnlineRoomEvent {
  final List<RoomMember> members;
  const MembersUpdated(this.members);
  @override
  List<Object?> get props => [members];
}

class SessionUpdated extends OnlineRoomEvent {
  final GameSession session;
  const SessionUpdated(this.session);
  @override
  List<Object?> get props => [session];
}

class GamePlayersUpdated extends OnlineRoomEvent {
  final List<GamePlayer> gamePlayers;
  const GamePlayersUpdated(this.gamePlayers);
  @override
  List<Object?> get props => [gamePlayers];
}

class FetchStoryRequested extends OnlineRoomEvent {
  final String storyId;
  const FetchStoryRequested(this.storyId);
  @override
  List<Object?> get props => [storyId];
}

class StoryFetched extends OnlineRoomEvent {
  final Story story;
  const StoryFetched(this.story);
  @override
  List<Object?> get props => [story];
}

class ToggleMicRequested extends OnlineRoomEvent {
  final bool enable;
  const ToggleMicRequested(this.enable);
  @override
  List<Object?> get props => [enable];
}
