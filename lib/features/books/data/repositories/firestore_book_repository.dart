import '../../../../core/utils/result.dart';
import '../../domain/models/author.dart';
import '../../domain/models/book.dart';
import '../../domain/models/category.dart';
import '../../domain/models/publisher.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/firestore_book_datasource.dart';

/// Production [BookRepository] backed by Cloud Firestore.
class FirestoreBookRepository implements BookRepository {
  final FirestoreBookDataSource _dataSource;

  FirestoreBookRepository(this._dataSource);

  @override
  Future<Result<List<Book>>> getBooks({
    String? query,
    String? categoryId,
    String? authorId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final books = await _dataSource.getBooks(
        query: query,
        categoryId: categoryId,
        authorId: authorId,
        page: page,
        pageSize: pageSize,
      );
      return Success(books);
    } on Exception catch (e) {
      return Failure('Failed to load books: ${e.toString()}', e);
    }
  }

  @override
  Future<Result<Book>> getBookById(String id) async {
    try {
      final book = await _dataSource.getBookById(id);
      return Success(book);
    } on Exception catch (e) {
      return Failure('Book not found', e);
    }
  }

  @override
  Future<Result<void>> addBook(Book book) async {
    try {
      await _dataSource.addBook(book);
      return const Success(null);
    } on Exception catch (e) {
      return Failure('Failed to add book', e);
    }
  }

  @override
  Future<Result<void>> updateBook(Book book) async {
    try {
      await _dataSource.updateBook(book);
      return const Success(null);
    } on Exception catch (e) {
      return Failure('Failed to update book', e);
    }
  }

  @override
  Future<Result<void>> deleteBook(String id) async {
    try {
      await _dataSource.deleteBook(id);
      return const Success(null);
    } on Exception catch (e) {
      return Failure('Failed to delete book', e);
    }
  }

  @override
  Future<Result<List<Category>>> getCategories() async {
    try {
      final categories = await _dataSource.getCategories();
      return Success(categories);
    } on Exception catch (e) {
      return Failure('Failed to load categories', e);
    }
  }

  @override
  Future<Result<List<Author>>> getAuthors() async {
    try {
      final authors = await _dataSource.getAuthors();
      return Success(authors);
    } on Exception catch (e) {
      return Failure('Failed to load authors', e);
    }
  }

  @override
  Future<Result<List<Publisher>>> getPublishers() async {
    try {
      final publishers = await _dataSource.getPublishers();
      return Success(publishers);
    } on Exception catch (e) {
      return Failure('Failed to load publishers', e);
    }
  }
}
