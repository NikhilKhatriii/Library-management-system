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
    );
  }

  @override
  void write(BinaryWriter writer, Book obj) {
    writer
      ..writeByte(17)
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
      ..write(obj.tags);
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
