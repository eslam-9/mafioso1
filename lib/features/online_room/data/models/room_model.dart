import '../../domain/entities/online_room.dart';
import '../../domain/entities/room_status.dart';

class RoomModel extends OnlineRoom {
  const RoomModel({
    required super.id,
    required super.code,
    required super.name,
    required super.hostId,
    required super.status,
    super.selectedStoryId,
    super.gameMode,
    required super.maxPlayers,
    super.requiredPlayers,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      hostId: json['host_id']?.toString() ?? '',
      status: RoomStatusX.fromString(json['status']?.toString() ?? 'waiting'),
      selectedStoryId: json['selected_story_id']?.toString(),
      gameMode: json['game_mode']?.toString(),
      maxPlayers: (json['max_players'] as num?)?.toInt() ?? 8,
      requiredPlayers: (json['required_players'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'host_id': hostId,
      'status': status.toMapValue(),
      'selected_story_id': selectedStoryId,
      'game_mode': gameMode,
      'max_players': maxPlayers,
    };
  }

  RoomModel copyWith({
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
    return RoomModel(
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
}
