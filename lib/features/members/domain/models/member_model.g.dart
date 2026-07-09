// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MemberModelAdapter extends TypeAdapter<MemberModel> {
  @override
  final int typeId = 10;

  @override
  MemberModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MemberModel(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      membershipNumber: fields[3] as String,
      type: fields[4] as MemberType,
      status: fields[5] as MemberStatus,
      photoUrl: fields[6] as String?,
      phoneNumber: fields[7] as String?,
      department: fields[8] as String?,
      address: fields[9] as String?,
      joinedDate: fields[10] as DateTime,
      expiryDate: fields[11] as DateTime?,
      totalBorrowed: fields[12] as int,
      currentBorrowed: fields[13] as int,
      outstandingFines: fields[14] as double,
    );
  }

  @override
  void write(BinaryWriter writer, MemberModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.membershipNumber)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.photoUrl)
      ..writeByte(7)
      ..write(obj.phoneNumber)
      ..writeByte(8)
      ..write(obj.department)
      ..writeByte(9)
      ..write(obj.address)
      ..writeByte(10)
      ..write(obj.joinedDate)
      ..writeByte(11)
      ..write(obj.expiryDate)
      ..writeByte(12)
      ..write(obj.totalBorrowed)
      ..writeByte(13)
      ..write(obj.currentBorrowed)
      ..writeByte(14)
      ..write(obj.outstandingFines);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemberModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MemberStatusAdapter extends TypeAdapter<MemberStatus> {
  @override
  final int typeId = 8;

  @override
  MemberStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MemberStatus.active;
      case 1:
        return MemberStatus.suspended;
      case 2:
        return MemberStatus.expired;
      case 3:
        return MemberStatus.pendingApproval;
      default:
        return MemberStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, MemberStatus obj) {
    switch (obj) {
      case MemberStatus.active:
        writer.writeByte(0);
        break;
      case MemberStatus.suspended:
        writer.writeByte(1);
        break;
      case MemberStatus.expired:
        writer.writeByte(2);
        break;
      case MemberStatus.pendingApproval:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemberStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MemberTypeAdapter extends TypeAdapter<MemberType> {
  @override
  final int typeId = 9;

  @override
  MemberType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MemberType.student;
      case 1:
        return MemberType.teacher;
      case 2:
        return MemberType.staff;
      case 3:
        return MemberType.alumni;
      case 4:
        return MemberType.guest;
      default:
        return MemberType.student;
    }
  }

  @override
  void write(BinaryWriter writer, MemberType obj) {
    switch (obj) {
      case MemberType.student:
        writer.writeByte(0);
        break;
      case MemberType.teacher:
        writer.writeByte(1);
        break;
      case MemberType.staff:
        writer.writeByte(2);
        break;
      case MemberType.alumni:
        writer.writeByte(3);
        break;
      case MemberType.guest:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemberTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
