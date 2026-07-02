import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'author.g.dart';

@HiveType(typeId: 3)
class Author extends Equatable {
  const Author({
    required this.id,
    required this.name,
    this.bio,
    this.photoUrl,
    this.bookCount = 0,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? bio;
  @HiveField(3)
  final String? photoUrl;
  @HiveField(4)
  final int bookCount;

  @override
  List<Object?> get props => [id, name, bio, photoUrl, bookCount];
}
