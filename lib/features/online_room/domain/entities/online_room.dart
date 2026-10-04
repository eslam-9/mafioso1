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

  /// The exact number of players required by the selected story (= suspect count).
  /// Null when no story has been selected yet.
  final int? requiredPlayers;

  const OnlineRoom({
    required this.id,
    required this.code,
    required this.name,
    required this.hostId,
    required this.status,
    this.selectedStoryId,
    this.gameMode,
    required this.maxPlayers,
    this.requiredPlayers,
  });

  bool isHost(String userId) => hostId == userId;
  bool isFull(int currentMembers) => currentMembers >= maxPlayers;
  bool get isWaiting => status == RoomStatus.waiting;

  /// Returns true only when a story is selected AND the current member count
  /// matches the story's required suspect count exactly.
  bool canStart(int currentMembers) =>
      selectedStoryId != null &&
      requiredPlayers != null &&
      currentMembers == requiredPlayers!;

  OnlineRoom copyWith({
    String? id,
    String? code,
    String? name,
    String? hostId,
    RoomStatus? status,
    String? selectedStoryId,
    String? gameMode,
    int? maxPlayers,
    int? requiredPlayers,
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
      requiredPlayers: requiredPlayers ?? this.requiredPlayers,
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
        requiredPlayers,
      ];
}
