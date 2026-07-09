import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/utils/result.dart';
import '../../domain/models/author.dart';
import '../../domain/models/book.dart';
import '../../domain/models/category.dart';
import '../../domain/models/publisher.dart';
import '../../domain/repositories/book_repository.dart';

class MockBookRepository implements BookRepository {
  static const String _booksBoxName = 'lib_books';
  
  Future<Box<Book>> _getBooksBox() async {
    if (!Hive.isBoxOpen(_booksBoxName)) {
      return await Hive.openBox<Book>(_booksBoxName);
    }
    return Hive.box<Book>(_booksBoxName);
  }

  Future<void> _seedDatabaseIfNeeded() async {
    final box = await _getBooksBox();
    if (box.isEmpty) {
      final initial = _generateMockBooks();
      for (final book in initial) {
        await box.put(book.id, book);
      }
    }
  }

  @override
  Future<Result<List<Book>>> getBooks({
    String? query,
    String? categoryId,
    String? authorId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      await _seedDatabaseIfNeeded();
      final box = await _getBooksBox();
      var filteredBooks = box.values.toList();
      
      if (query != null && query.isNotEmpty) {
        filteredBooks = filteredBooks
            .where((b) => b.title.toLowerCase().contains(query.toLowerCase()) || 
                         b.authorName.toLowerCase().contains(query.toLowerCase()) ||
                         b.isbn.contains(query))
            .toList();
      }
      if (categoryId != null) {
        filteredBooks = filteredBooks.where((b) => b.categoryId == categoryId).toList();
      }
      if (authorId != null) {
        filteredBooks = filteredBooks.where((b) => b.authorId == authorId).toList();
      }

      final startIndex = (page - 1) * pageSize;
      if (startIndex >= filteredBooks.length) return const Success([]);
      
      final end = (startIndex + pageSize) > filteredBooks.length 
          ? filteredBooks.length 
          : (startIndex + pageSize);
          
      return Success(filteredBooks.sublist(startIndex, end));
    } catch (e) {
      return Failure('Failed to retrieve books', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<Book>> getBookById(String id) async {
    try {
      await _seedDatabaseIfNeeded();
      final box = await _getBooksBox();
      final book = box.get(id);
      if (book != null) {
        return Success(book);
      }
      return const Failure('Book not found');
    } catch (e) {
      return Failure('Failed to retrieve book', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> addBook(Book book) async {
    try {
      final box = await _getBooksBox();
      await box.put(book.id, book);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to add book', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateBook(Book book) async {
    try {
      final box = await _getBooksBox();
      if (box.containsKey(book.id)) {
        await box.put(book.id, book);
        return const Success(null);
      }
      return const Failure('Book not found');
    } catch (e) {
      return Failure('Failed to update book', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteBook(String id) async {
    try {
      final box = await _getBooksBox();
      await box.delete(id);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete book', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<List<Category>>> getCategories() async {
    return Success(_generateMockCategories());
  }

  @override
  Future<Result<List<Author>>> getAuthors() async {
    return Success(_generateMockAuthors());
  }

  @override
  Future<Result<List<Publisher>>> getPublishers() async {
    return Success(_generateMockPublishers());
  }

  static List<Book> _generateMockBooks() {
    return [
      Book(
        id: '1',
        title: 'The Great Gatsby',
        authorId: 'a1',
        authorName: 'F. Scott Fitzgerald',
        isbn: '9780743273565',
        categoryId: 'c1',
        categoryName: 'Fiction',
        publisherId: 'p1',
        publisherName: 'Scribner',
        publishDate: DateTime(1925, 4, 10),
        description: 'The story of the fabulously wealthy Jay Gatsby and his love for the beautiful Daisy Buchanan.',
        coverUrl: 'https://images-na.ssl-images-amazon.com/images/I/81af+MCATTL.jpg',
        totalCopies: 5,
        availableCopies: 3,
        rating: 4.5,
        status: BookStatus.available,
        condition: BookCondition.newCondition,
        edition: 'First Edition',
        shelfLocation: 'A-102',
      ),
      Book(
        id: '2',
        title: 'To Kill a Mockingbird',
        authorId: 'a2',
        authorName: 'Harper Lee',
        isbn: '9780061120084',
        categoryId: 'c1',
        categoryName: 'Fiction',
        publisherId: 'p2',
        publisherName: 'J.B. Lippincott & Co.',
        publishDate: DateTime(1960, 7, 11),
        description: 'The unforgettable novel of a childhood in a sleepy Southern town and the crisis of conscience that rocked it.',
        coverUrl: 'https://images-na.ssl-images-amazon.com/images/I/81gepf1eMqL.jpg',
        totalCopies: 8,
        availableCopies: 5,
        rating: 4.8,
        status: BookStatus.available,
        condition: BookCondition.good,
        edition: 'Diamond Anniversary',
        shelfLocation: 'B-205',
      ),
      Book(
        id: '3',
        title: 'Clean Code',
        authorId: 'a3',
        authorName: 'Robert C. Martin',
        isbn: '9780132350884',
        categoryId: 'c2',
        categoryName: 'Technology',
        publisherId: 'p3',
        publisherName: 'Prentice Hall',
        publishDate: DateTime(2008, 8, 1),
        description: 'Even bad code can function. But if code isn’t clean, it can bring a development organization to its knees.',
        coverUrl: 'https://images-na.ssl-images-amazon.com/images/I/41xShlnTZTL._SX376_BO1,204,203,200_.jpg',
        totalCopies: 10,
        availableCopies: 7,
        rating: 4.7,
        tags: const ['Programming', 'Software Engineering'],
        status: BookStatus.available,
        condition: BookCondition.newCondition,
        edition: '1st Edition',
        shelfLocation: 'T-101',
      ),
      // Add more mock books here for pagination testing
      for (int i = 4; i <= 50; i++)
        Book(
          id: i.toString(),
          title: 'Mock Book Title $i',
          authorId: 'a${(i % 5) + 1}',
          authorName: 'Mock Author ${(i % 5) + 1}',
          isbn: '1234567890$i',
          categoryId: 'c${(i % 3) + 1}',
          categoryName: (i % 3 == 0) ? 'Fiction' : (i % 3 == 1 ? 'Technology' : 'History'),
          publisherId: 'p${(i % 4) + 1}',
          publisherName: 'Mock Publisher ${(i % 4) + 1}',
          publishDate: DateTime(2020, 1, i % 28 + 1),
          description: 'This is a mock description for book $i.',
          coverUrl: _getMockCoverUrl(i),
          totalCopies: 5,
          availableCopies: 2,
          rating: 4.0,
          status: i % 10 == 0 ? BookStatus.reserved : BookStatus.available,
          condition: BookCondition.values[i % 4],
          shelfLocation: 'R-${100 + i}',
        ),
    ];
  }

  static String _getMockCoverUrl(int index) {
    final covers = [
      'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?q=80&w=300',
      'https://images.unsplash.com/photo-1544947950-fa07a98d237f?q=80&w=300',
      'https://images.unsplash.com/photo-1512820790803-83ca734da794?q=80&w=300',
      'https://images.unsplash.com/photo-1476275466078-4007374efbbe?q=80&w=300',
      'https://images.unsplash.com/photo-1532012197267-da84d127e765?q=80&w=300',
      'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?q=80&w=300',
    ];
    return covers[index % covers.length];
  }

  static List<Category> _generateMockCategories() {
    return [
      const Category(id: 'c1', name: 'Fiction', iconCode: 58832), // Icons.book
      const Category(id: 'c2', name: 'Technology', iconCode: 58162), // Icons.computer
      const Category(id: 'c3', name: 'History', iconCode: 58406), // Icons.history
      const Category(id: 'c4', name: 'Science', iconCode: 58945), // Icons.science
    ];
  }

  static List<Author> _generateMockAuthors() {
    return [
      const Author(id: 'a1', name: 'F. Scott Fitzgerald'),
      const Author(id: 'a2', name: 'Harper Lee'),
      const Author(id: 'a3', name: 'Robert C. Martin'),
      const Author(id: 'a4', name: 'J.K. Rowling'),
      const Author(id: 'a5', name: 'George Orwell'),
    ];
  }

  static List<Publisher> _generateMockPublishers() {
    return [
      const Publisher(id: 'p1', name: 'Scribner'),
      const Publisher(id: 'p2', name: 'J.B. Lippincott & Co.'),
      const Publisher(id: 'p3', name: 'Prentice Hall'),
      const Publisher(id: 'p4', name: 'Penguin Books'),
    ];
  }
}
