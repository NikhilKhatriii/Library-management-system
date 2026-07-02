import '../../../../core/utils/result.dart';
import '../models/book.dart';
import '../models/author.dart';
import '../models/category.dart';
import '../models/publisher.dart';

abstract interface class BookRepository {
  Future<Result<List<Book>>> getBooks({
    String? query,
    String? categoryId,
    String? authorId,
    int page = 1,
    int pageSize = 20,
  });

  Future<Result<Book>> getBookById(String id);
  Future<Result<void>> addBook(Book book);
  Future<Result<void>> updateBook(Book book);
  Future<Result<void>> deleteBook(String id);

  Future<Result<List<Category>>> getCategories();
  Future<Result<List<Author>>> getAuthors();
  Future<Result<List<Publisher>>> getPublishers();
}
