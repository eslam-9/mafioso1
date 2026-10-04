import '../../domain/entities/room_member.dart';

class RoomMemberModel extends RoomMember {
  const RoomMemberModel({
    required super.id,
    required super.roomId,
    required super.userId,
    required super.displayName,
    required super.isOnline,
    required super.micEnabled,
  });

  factory RoomMemberModel.fromJson(Map<String, dynamic> json) {
    return RoomMemberModel(
      id: json['id'],
      roomId: json['room_id'],
      userId: json['user_id'],
      displayName: json['display_name'],
      isOnline: json['is_online'] ?? false,
      micEnabled: json['mic_enabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'user_id': userId,
      'display_name': displayName,
      'is_online': isOnline,
      'mic_enabled': micEnabled,
    };
  }
}
