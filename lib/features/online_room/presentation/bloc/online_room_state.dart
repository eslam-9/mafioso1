import 'package:equatable/equatable.dart';
import '../../../../core/errors/app_error.dart';
import '../../domain/entities/online_room.dart';
import '../../domain/entities/room_member.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/entities/game_player.dart';
import '../../../story/domain/entities/story.dart';
import '../../../story/domain/entities/clue.dart';

enum OnlineRoomStatus { idle, loading, inLobby, inGame, error }

// Sentinel to distinguish "not provided" from "explicitly null"
class _Unset {
  const _Unset();
}

const _unset = _Unset();

class OnlineRoomState extends Equatable {
  final OnlineRoomStatus status;
  final OnlineRoom? room;
  final List<RoomMember> members;
  final GameSession? session;
  final Story? story;
  final List<GamePlayer> gamePlayers;
  final bool isHost;
  final bool isMicEnabled;
  final AppError? error;

  const OnlineRoomState({
    this.status = OnlineRoomStatus.idle,
    this.room,
    this.members = const [],
    this.session,
    this.story,
    this.gamePlayers = const [],
    this.isHost = false,
    this.isMicEnabled = false,
    this.error,
  });

  List<GamePlayer> get alivePlayers =>
      gamePlayers.where((p) => p.isAlive).toList();

  List<Clue> get availableClues => story?.clues ?? [];

  List<Clue> get revealedClues {
    if (story == null || session == null) return [];
    return session!.revealedClueIndices
        .map((i) => story!.clues[i])
        .toList();
  }

  bool get canRevealMoreClues => revealedClues.length < availableClues.length;

  bool get isGameOver =>
      session?.gameState == 'innocents_win' ||
      session?.gameState == 'killer_wins';

  OnlineRoomState copyWith({
    OnlineRoomStatus? status,
    Object? room = _unset,
    List<RoomMember>? members,
    Object? session = _unset,
    Object? story = _unset,
    List<GamePlayer>? gamePlayers,
    bool? isHost,
    bool? isMicEnabled,
    AppError? error,
  }) {
    return OnlineRoomState(
      status: status ?? this.status,
      room: room == _unset ? this.room : room as OnlineRoom?,
      members: members ?? this.members,
      session: session == _unset ? this.session : session as GameSession?,
      story: story == _unset ? this.story : story as Story?,
      gamePlayers: gamePlayers ?? this.gamePlayers,
      isHost: isHost ?? this.isHost,
      isMicEnabled: isMicEnabled ?? this.isMicEnabled,
      error: error, // Can be null to clear error
    );
  }

  @override
  List<Object?> get props => [
        status,
        room,
        members,
        session,
        story,
        gamePlayers,
        isHost,
        isMicEnabled,
        error,
      ];
}
