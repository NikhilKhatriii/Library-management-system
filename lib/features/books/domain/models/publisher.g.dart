// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publisher.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PublisherAdapter extends TypeAdapter<Publisher> {
  @override
  final int typeId = 5;

  @override
  Publisher read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Publisher(
      id: fields[0] as String,
      name: fields[1] as String,
      address: fields[2] as String?,
      website: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Publisher obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.website);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PublisherAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
