import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 4)
class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    this.description,
    this.iconCode,
    this.bookCount = 0,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final int? iconCode;
  @HiveField(4)
  final int bookCount;

  @override
  List<Object?> get props => [id, name, description, iconCode, bookCount];
}
