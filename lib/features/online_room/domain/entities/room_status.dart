enum RoomStatus {
  waiting,
  starting,
  playing,
  finished,
}

extension RoomStatusX on RoomStatus {
  static RoomStatus fromString(String value) {
    switch (value) {
      case 'starting':
        return RoomStatus.starting;
      case 'playing':
        return RoomStatus.playing;
      case 'finished':
        return RoomStatus.finished;
      case 'waiting':
      default:
        return RoomStatus.waiting;
    }
  }

  String toMapValue() {
    return name;
  }
}
