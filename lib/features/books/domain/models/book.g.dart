// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookAdapter extends TypeAdapter<Book> {
  @override
  final int typeId = 2;

  @override
  Book read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Book(
      id: fields[0] as String,
      title: fields[1] as String,
      authorId: fields[2] as String,
      authorName: fields[3] as String,
      isbn: fields[4] as String,
      categoryId: fields[5] as String,
      categoryName: fields[6] as String,
      publisherId: fields[7] as String,
      publisherName: fields[8] as String,
      publishDate: fields[9] as DateTime,
      description: fields[10] as String,
      coverUrl: fields[11] as String,
      totalCopies: fields[12] as int,
      availableCopies: fields[13] as int,
      isFavorite: fields[14] as bool,
      rating: fields[15] as double,
      tags: (fields[16] as List).cast<String>(),
      status: fields[17] as BookStatus,
      condition: fields[18] as BookCondition,
      edition: fields[19] as String?,
      shelfLocation: fields[20] as String?,
      isDigital: fields[21] as bool,
      digitalUrl: fields[22] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Book obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.authorId)
      ..writeByte(3)
      ..write(obj.authorName)
      ..writeByte(4)
      ..write(obj.isbn)
      ..writeByte(5)
      ..write(obj.categoryId)
      ..writeByte(6)
      ..write(obj.categoryName)
      ..writeByte(7)
      ..write(obj.publisherId)
      ..writeByte(8)
      ..write(obj.publisherName)
      ..writeByte(9)
      ..write(obj.publishDate)
      ..writeByte(10)
      ..write(obj.description)
      ..writeByte(11)
      ..write(obj.coverUrl)
      ..writeByte(12)
      ..write(obj.totalCopies)
      ..writeByte(13)
      ..write(obj.availableCopies)
      ..writeByte(14)
      ..write(obj.isFavorite)
      ..writeByte(15)
      ..write(obj.rating)
      ..writeByte(16)
      ..write(obj.tags)
      ..writeByte(17)
      ..write(obj.status)
      ..writeByte(18)
      ..write(obj.condition)
      ..writeByte(19)
      ..write(obj.edition)
      ..writeByte(20)
      ..write(obj.shelfLocation)
      ..writeByte(21)
      ..write(obj.isDigital)
      ..writeByte(22)
      ..write(obj.digitalUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BookStatusAdapter extends TypeAdapter<BookStatus> {
  @override
  final int typeId = 6;

  @override
  BookStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BookStatus.available;
      case 1:
        return BookStatus.issued;
      case 2:
        return BookStatus.reserved;
      case 3:
        return BookStatus.lost;
      case 4:
        return BookStatus.archived;
      default:
        return BookStatus.available;
    }
  }

  @override
  void write(BinaryWriter writer, BookStatus obj) {
    switch (obj) {
      case BookStatus.available:
        writer.writeByte(0);
        break;
      case BookStatus.issued:
        writer.writeByte(1);
        break;
      case BookStatus.reserved:
        writer.writeByte(2);
        break;
      case BookStatus.lost:
        writer.writeByte(3);
        break;
      case BookStatus.archived:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BookConditionAdapter extends TypeAdapter<BookCondition> {
  @override
  final int typeId = 7;

  @override
  BookCondition read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BookCondition.newCondition;
      case 1:
        return BookCondition.good;
      case 2:
        return BookCondition.fair;
      case 3:
        return BookCondition.damaged;
      default:
        return BookCondition.newCondition;
    }
  }

  @override
  void write(BinaryWriter writer, BookCondition obj) {
    switch (obj) {
      case BookCondition.newCondition:
        writer.writeByte(0);
        break;
      case BookCondition.good:
        writer.writeByte(1);
        break;
      case BookCondition.fair:
        writer.writeByte(2);
        break;
      case BookCondition.damaged:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookConditionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
