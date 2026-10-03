import 'package:equatable/equatable.dart';
import 'room_status.dart';

class OnlineRoom extends Equatable {
  final String id;
  final String code;
  final String name;
  final String hostId;
  final RoomStatus status;
  final String? selectedStoryId;
  final String? gameMode;
  final int maxPlayers;

  const OnlineRoom({
    required this.id,
    required this.code,
    required this.name,
    required this.hostId,
    required this.status,
    this.selectedStoryId,
    this.gameMode,
    required this.maxPlayers,
  });

  bool isHost(String userId) => hostId == userId;
  bool isFull(int currentMembers) => currentMembers >= maxPlayers;
  bool get isWaiting => status == RoomStatus.waiting;

  OnlineRoom copyWith({
    String? id,
    String? code,
    String? name,
    String? hostId,
    RoomStatus? status,
    String? selectedStoryId,
    String? gameMode,
    int? maxPlayers,
  }) {
    return OnlineRoom(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      hostId: hostId ?? this.hostId,
      status: status ?? this.status,
      selectedStoryId: selectedStoryId ?? this.selectedStoryId,
      gameMode: gameMode ?? this.gameMode,
      maxPlayers: maxPlayers ?? this.maxPlayers,
    );
  }

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        hostId,
        status,
        selectedStoryId,
        gameMode,
        maxPlayers,
      ];
}
