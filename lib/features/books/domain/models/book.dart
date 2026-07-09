import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'book.g.dart';

@HiveType(typeId: 6)
enum BookStatus {
  @HiveField(0)
  available,
  @HiveField(1)
  issued,
  @HiveField(2)
  reserved,
  @HiveField(3)
  lost,
  @HiveField(4)
  archived,
}

@HiveType(typeId: 7)
enum BookCondition {
  @HiveField(0)
  newCondition,
  @HiveField(1)
  good,
  @HiveField(2)
  fair,
  @HiveField(3)
  damaged,
}

@HiveType(typeId: 2)
class Book extends Equatable {
  const Book({
    required this.id,
    required this.title,
    required this.authorId,
    required this.authorName,
    required this.isbn,
    required this.categoryId,
    required this.categoryName,
    required this.publisherId,
    required this.publisherName,
    required this.publishDate,
    required this.description,
    required this.coverUrl,
    required this.totalCopies,
    required this.availableCopies,
    this.isFavorite = false,
    this.rating = 0.0,
    this.tags = const [],
    this.status = BookStatus.available,
    this.condition = BookCondition.newCondition,
    this.edition,
    this.shelfLocation,
    this.isDigital = false,
    this.digitalUrl,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String authorId;
  @HiveField(3)
  final String authorName;
  @HiveField(4)
  final String isbn;
  @HiveField(5)
  final String categoryId;
  @HiveField(6)
  final String categoryName;
  @HiveField(7)
  final String publisherId;
  @HiveField(8)
  final String publisherName;
  @HiveField(9)
  final DateTime publishDate;
  @HiveField(10)
  final String description;
  @HiveField(11)
  final String coverUrl;
  @HiveField(12)
  final int totalCopies;
  @HiveField(13)
  final int availableCopies;
  @HiveField(14)
  final bool isFavorite;
  @HiveField(15)
  final double rating;
  @HiveField(16)
  final List<String> tags;
  @HiveField(17)
  final BookStatus status;
  @HiveField(18)
  final BookCondition condition;
  @HiveField(19)
  final String? edition;
  @HiveField(20)
  final String? shelfLocation;
  @HiveField(21)
  final bool isDigital;
  @HiveField(22)
  final String? digitalUrl;

  bool get isAvailable => availableCopies > 0;

  Book copyWith({
    String? id,
    String? title,
    String? authorId,
    String? authorName,
    String? isbn,
    String? categoryId,
    String? categoryName,
    String? publisherId,
    String? publisherName,
    DateTime? publishDate,
    String? description,
    String? coverUrl,
    int? totalCopies,
    int? availableCopies,
    bool? isFavorite,
    double? rating,
    List<String>? tags,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      isbn: isbn ?? this.isbn,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      publisherId: publisherId ?? this.publisherId,
      publisherName: publisherName ?? this.publisherName,
      publishDate: publishDate ?? this.publishDate,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      totalCopies: totalCopies ?? this.totalCopies,
      availableCopies: availableCopies ?? this.availableCopies,
      isFavorite: isFavorite ?? this.isFavorite,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        authorId,
        isbn,
        categoryId,
        publisherId,
        isFavorite,
        availableCopies,
      ];
}
