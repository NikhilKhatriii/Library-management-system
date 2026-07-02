import '../../../../core/utils/result.dart';
import '../../domain/models/author.dart';
import '../../domain/models/book.dart';
import '../../domain/models/category.dart';
import '../../domain/models/publisher.dart';
import '../../domain/repositories/book_repository.dart';

class MockBookRepository implements BookRepository {
  final List<Book> _books = _generateMockBooks();
  final List<Category> _categories = _generateMockCategories();
  final List<Author> _authors = _generateMockAuthors();
  final List<Publisher> _publishers = _generateMockPublishers();

  @override
  Future<Result<List<Book>>> getBooks({
    String? query,
    String? categoryId,
    String? authorId,
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    var filteredBooks = _books;
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
  }

  @override
  Future<Result<Book>> getBookById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final book = _books.firstWhere((b) => b.id == id);
      return Success(book);
    } catch (e) {
      return const Failure('Book not found');
    }
  }

  @override
  Future<Result<void>> addBook(Book book) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _books.insert(0, book);
    return const Success(null);
  }

  @override
  Future<Result<void>> updateBook(Book book) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final index = _books.indexWhere((b) => b.id == book.id);
    if (index != -1) {
      _books[index] = book;
      return const Success(null);
    }
    return const Failure('Book not found');
  }

  @override
  Future<Result<void>> deleteBook(String id) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _books.removeWhere((b) => b.id == id);
    return const Success(null);
  }

  @override
  Future<Result<List<Category>>> getCategories() async {
    return Success(_categories);
  }

  @override
  Future<Result<List<Author>>> getAuthors() async {
    return Success(_authors);
  }

  @override
  Future<Result<List<Publisher>>> getPublishers() async {
    return Success(_publishers);
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
          coverUrl: 'https://via.placeholder.com/150',
          totalCopies: 5,
          availableCopies: 2,
          rating: 4.0,
        ),
    ];
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
