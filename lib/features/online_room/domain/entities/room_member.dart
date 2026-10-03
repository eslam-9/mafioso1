import 'package:equatable/equatable.dart';

class RoomMember extends Equatable {
  final String id;
  final String roomId;
  final String userId;
  final String displayName;
  final bool isOnline;
  final bool micEnabled;

  const RoomMember({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.displayName,
    required this.isOnline,
    required this.micEnabled,
  });

  RoomMember copyWith({
    String? id,
    String? roomId,
    String? userId,
    String? displayName,
    bool? isOnline,
    bool? micEnabled,
  }) {
    return RoomMember(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      isOnline: isOnline ?? this.isOnline,
      micEnabled: micEnabled ?? this.micEnabled,
    );
  }

  @override
  List<Object?> get props => [
        id,
        roomId,
        userId,
        displayName,
        isOnline,
        micEnabled,
      ];
}
