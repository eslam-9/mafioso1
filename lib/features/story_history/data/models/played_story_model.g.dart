// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'played_story_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayedStoryModelAdapter extends TypeAdapter<PlayedStoryModel> {
  @override
  final typeId = 0;

  @override
  PlayedStoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayedStoryModel(
      id: fields[0] as String,
      storyJson: fields[1] as String,
      playedAt: fields[2] as DateTime,
      userRating: (fields[3] as num?)?.toInt(),
      isUploaded: fields[4] == null ? false : fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PlayedStoryModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.storyJson)
      ..writeByte(2)
      ..write(obj.playedAt)
      ..writeByte(3)
      ..write(obj.userRating)
      ..writeByte(4)
      ..write(obj.isUploaded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayedStoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
