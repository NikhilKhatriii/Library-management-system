import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/firebase_service.dart';
import '../../domain/models/author.dart';
import '../../domain/models/book.dart';
import '../../domain/models/category.dart';
import '../../domain/models/publisher.dart';

/// Firestore datasource for all book-related CRUD operations.
class FirestoreBookDataSource {
  final _books = FirebaseService.booksCollection;
  final _categories = FirebaseService.categoriesCollection;
  final _authors = FirebaseService.authorsCollection;
  final _publishers = FirebaseService.publishersCollection;

  // ── Books ──────────────────────────────────────────────────────────

  Future<List<Book>> getBooks({
    String? query,
    String? categoryId,
    String? authorId,
    int page = 1,
    int pageSize = 20,
  }) async {
    Query<Map<String, dynamic>> ref = _books.orderBy('title');

    if (categoryId != null) {
      ref = ref.where('categoryId', isEqualTo: categoryId);
    }
    if (authorId != null) {
      ref = ref.where('authorId', isEqualTo: authorId);
    }

    final snapshot = await ref.get();
    var docs = snapshot.docs;

    // Client-side text search (Firestore doesn't support full-text natively).
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      docs = docs.where((doc) {
        final data = doc.data();
        final title = (data['title'] as String? ?? '').toLowerCase();
        final author = (data['authorName'] as String? ?? '').toLowerCase();
        final isbn = (data['isbn'] as String? ?? '').toLowerCase();
        return title.contains(q) || author.contains(q) || isbn.contains(q);
      }).toList();
    }

    // Pagination
    final startIndex = (page - 1) * pageSize;
    if (startIndex >= docs.length) return [];
    final end = (startIndex + pageSize) > docs.length
        ? docs.length
        : (startIndex + pageSize);

    return docs.sublist(startIndex, end).map(_bookFromDoc).toList();
  }

  Future<Book> getBookById(String id) async {
    final doc = await _books.doc(id).get();
    if (!doc.exists) throw Exception('Book not found');
    return _bookFromDoc(doc);
  }

  Future<void> addBook(Book book) async {
    await _books.doc(book.id).set(_bookToMap(book));
  }

  Future<void> updateBook(Book book) async {
    await _books.doc(book.id).update(_bookToMap(book));
  }

  Future<void> deleteBook(String id) async {
    await _books.doc(id).delete();
  }

  /// Atomically update the available copies count.
  Future<void> updateAvailableCopies(String bookId, int delta) async {
    await _books.doc(bookId).update({
      'availableCopies': FieldValue.increment(delta),
    });
  }

  // ── Categories ─────────────────────────────────────────────────────

  Future<List<Category>> getCategories() async {
    final snapshot = await _categories.orderBy('name').get();
    return snapshot.docs.map((doc) {
      final d = doc.data();
      return Category(
        id: doc.id,
        name: d['name'] as String? ?? '',
        description: d['description'] as String?,
        iconCode: d['iconCode'] as int?,
        bookCount: d['bookCount'] as int? ?? 0,
      );
    }).toList();
  }

  // ── Authors ────────────────────────────────────────────────────────

  Future<List<Author>> getAuthors() async {
    final snapshot = await _authors.orderBy('name').get();
    return snapshot.docs.map((doc) {
      final d = doc.data();
      return Author(
        id: doc.id,
        name: d['name'] as String? ?? '',
        bio: d['bio'] as String?,
        photoUrl: d['photoUrl'] as String?,
        bookCount: d['bookCount'] as int? ?? 0,
      );
    }).toList();
  }

  // ── Publishers ─────────────────────────────────────────────────────

  Future<List<Publisher>> getPublishers() async {
    final snapshot = await _publishers.orderBy('name').get();
    return snapshot.docs.map((doc) {
      final d = doc.data();
      return Publisher(
        id: doc.id,
        name: d['name'] as String? ?? '',
        address: d['address'] as String?,
        website: d['website'] as String?,
      );
    }).toList();
  }

  // ── Helpers ────────────────────────────────────────────────────────

  Book _bookFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Book(
      id: doc.id,
      title: d['title'] as String? ?? '',
      authorId: d['authorId'] as String? ?? '',
      authorName: d['authorName'] as String? ?? '',
      isbn: d['isbn'] as String? ?? '',
      categoryId: d['categoryId'] as String? ?? '',
      categoryName: d['categoryName'] as String? ?? '',
      publisherId: d['publisherId'] as String? ?? '',
      publisherName: d['publisherName'] as String? ?? '',
      publishDate: (d['publishDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: d['description'] as String? ?? '',
      coverUrl: d['coverUrl'] as String? ?? '',
      totalCopies: d['totalCopies'] as int? ?? 0,
      availableCopies: d['availableCopies'] as int? ?? 0,
      isFavorite: d['isFavorite'] as bool? ?? false,
      rating: (d['rating'] as num?)?.toDouble() ?? 0.0,
      tags: List<String>.from(d['tags'] ?? []),
    );
  }

  Map<String, dynamic> _bookToMap(Book book) => {
        'title': book.title,
        'authorId': book.authorId,
        'authorName': book.authorName,
        'isbn': book.isbn,
        'categoryId': book.categoryId,
        'categoryName': book.categoryName,
        'publisherId': book.publisherId,
        'publisherName': book.publisherName,
        'publishDate': Timestamp.fromDate(book.publishDate),
        'description': book.description,
        'coverUrl': book.coverUrl,
        'totalCopies': book.totalCopies,
        'availableCopies': book.availableCopies,
        'isFavorite': book.isFavorite,
        'rating': book.rating,
        'tags': book.tags,
      };
}
