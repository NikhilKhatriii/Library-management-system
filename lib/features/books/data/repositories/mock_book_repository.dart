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
      Book(
        id: '101',
        title: '1984',
        authorId: 'a5',
        authorName: 'George Orwell',
        isbn: '9780451524935',
        categoryId: 'c1',
        categoryName: 'Fiction',
        publisherId: 'p4',
        publisherName: 'Penguin Books',
        publishDate: DateTime(1949, 6, 8),
        description: 'A dystopian masterpiece illustrating a totalitarian regime that enforces extreme surveillance and control over free thought.',
        coverUrl: 'https://images-na.ssl-images-amazon.com/images/I/71kxa1-gGBL.jpg',
        totalCopies: 6,
        availableCopies: 4,
        rating: 4.8,
        tags: const ['Dystopian', 'Classic', 'Political'],
        status: BookStatus.available,
        condition: BookCondition.newCondition,
        edition: 'Signet Classic',
        shelfLocation: 'F-105',
      ),
      Book(
        id: '102',
        title: 'The Hobbit',
        authorId: 'a4',
        authorName: 'J.R.R. Tolkien',
        isbn: '9780547928227',
        categoryId: 'c1',
        categoryName: 'Fiction',
        publisherId: 'p1',
        publisherName: 'Houghton Mifflin',
        publishDate: DateTime(1937, 9, 21),
        description: 'The prelude to Lord of the Rings, following Bilbo Baggins on an epic quest to reclaim the lonely mountain from a fearsome dragon.',
        coverUrl: 'https://images-na.ssl-images-amazon.com/images/I/91b0C2YNSrL.jpg',
        totalCopies: 12,
        availableCopies: 9,
        rating: 4.9,
        tags: const ['Fantasy', 'Adventure', 'Classic'],
        status: BookStatus.available,
        condition: BookCondition.good,
        edition: 'Pocket Edition',
        shelfLocation: 'F-106',
      ),
      Book(
        id: '103',
        title: 'A Brief History of Time',
        authorId: 'a6',
        authorName: 'Stephen Hawking',
        isbn: '9780553380163',
        categoryId: 'c4',
        categoryName: 'Science',
        publisherId: 'p2',
        publisherName: 'Bantam Books',
        publishDate: DateTime(1988, 3, 1),
        description: 'A landmark exploration of cosmology, black holes, time travel, and the origins of the universe for general readers.',
        coverUrl: 'https://images-na.ssl-images-amazon.com/images/I/81+m10E54xL.jpg',
        totalCopies: 5,
        availableCopies: 4,
        rating: 4.7,
        tags: const ['Cosmology', 'Space', 'Popular Science'],
        status: BookStatus.available,
        condition: BookCondition.newCondition,
        edition: 'Updated Edition',
        shelfLocation: 'S-201',
      ),
      Book(
        id: '104',
        title: 'Sapiens',
        authorId: 'a7',
        authorName: 'Yuval Noah Harari',
        isbn: '9780062316097',
        categoryId: 'c3',
        categoryName: 'History',
        publisherId: 'p4',
        publisherName: 'Harper',
        publishDate: DateTime(2011, 1, 1),
        description: 'An expansive account of the history of human species, exploring how cognitive, agricultural, and scientific revolutions shaped society.',
        coverUrl: 'https://images-na.ssl-images-amazon.com/images/I/713jIoMO3UL.jpg',
        totalCopies: 8,
        availableCopies: 5,
        rating: 4.6,
        tags: const ['Anthropology', 'Evolution', 'Society'],
        status: BookStatus.available,
        condition: BookCondition.good,
        edition: 'Multi-lingual Print',
        shelfLocation: 'H-302',
      ),
      Book(
        id: '105',
        title: 'The Pragmatic Programmer',
        authorId: 'a8',
        authorName: 'Andy Hunt & Dave Thomas',
        isbn: '9780135957059',
        categoryId: 'c2',
        categoryName: 'Technology',
        publisherId: 'p3',
        publisherName: 'Addison-Wesley',
        publishDate: DateTime(1999, 10, 30),
        description: 'A timeless software engineering guide emphasizing personal responsibility, career development, and code architecture principles.',
        coverUrl: 'https://images-na.ssl-images-amazon.com/images/I/41uPjE4-eeL._SX218_BO1,204,203,200_QL40_FMwebp_.jpg',
        totalCopies: 9,
        availableCopies: 6,
        rating: 4.8,
        tags: const ['Programming', 'Engineering Practices'],
        status: BookStatus.available,
        condition: BookCondition.newCondition,
        edition: '20th Anniv. Edition',
        shelfLocation: 'T-102',
      ),
      Book(
        id: '106',
        title: 'Design Patterns',
        authorId: 'a3',
        authorName: 'Erich Gamma et al.',
        isbn: '9780201633610',
        categoryId: 'c2',
        categoryName: 'Technology',
        publisherId: 'p3',
        publisherName: 'Addison-Wesley',
        publishDate: DateTime(1994, 10, 31),
        description: 'The seminal textbook cataloging 23 object-oriented design patterns to solve common software development problems.',
        coverUrl: 'https://images-na.ssl-images-amazon.com/images/I/81gtKoapHFL.jpg',
        totalCopies: 4,
        availableCopies: 2,
        rating: 4.9,
        tags: const ['Architecture', 'OOP', 'Classic Tech'],
        status: BookStatus.available,
        condition: BookCondition.good,
        edition: '1st Print',
        shelfLocation: 'T-103',
      ),
      Book(
        id: '107',
        title: 'Frankenstein',
        authorId: 'a9',
        authorName: 'Mary Shelley',
        isbn: '9780141439471',
        categoryId: 'c1',
        categoryName: 'Fiction',
        publisherId: 'p4',
        publisherName: 'Penguin Classics',
        publishDate: DateTime(1818, 1, 1),
        description: 'The gothic masterpiece of Victor Frankenstein creating life out of death, and the tragic consequences of his hubris.',
        coverUrl: 'https://images-na.ssl-images-amazon.com/images/I/815L+-Qe85L.jpg',
        totalCopies: 7,
        availableCopies: 6,
        rating: 4.4,
        tags: const ['Gothic', 'Sci-Fi', 'Classic'],
        status: BookStatus.available,
        condition: BookCondition.fair,
        edition: 'Deluxe Classic',
        shelfLocation: 'F-107',
      ),
      Book(
        id: '108',
        title: 'Dune',
        authorId: 'a10',
        authorName: 'Frank Herbert',
        isbn: '9780441172719',
        categoryId: 'c1',
        categoryName: 'Fiction',
        publisherId: 'p1',
        publisherName: 'Ace Books',
        publishDate: DateTime(1965, 8, 1),
        description: 'Set on the desert planet Arrakis, a rich space opera detailing political intrigue, religious prophecy, and control of the spice melange.',
        coverUrl: 'https://images-na.ssl-images-amazon.com/images/I/81ym3QUd3KL.jpg',
        totalCopies: 15,
        availableCopies: 11,
        rating: 4.8,
        tags: const ['Sci-Fi', 'Space Opera', 'Adventure'],
        status: BookStatus.available,
        condition: BookCondition.newCondition,
        edition: 'Trade Paperback',
        shelfLocation: 'F-108',
      ),
      Book(
        id: '109',
        title: 'Atomic Habits',
        authorId: 'a11',
        authorName: 'James Clear',
        isbn: '9780735211292',
        categoryId: 'c1',
        categoryName: 'Fiction',
        publisherId: 'p4',
        publisherName: 'Avery',
        publishDate: DateTime(2018, 10, 16),
        description: 'A practical framework to build good habits, break bad ones, and master the tiny behaviors that lead to remarkable results.',
        coverUrl: 'https://images-na.ssl-images-amazon.com/images/I/81wgcld4bfL.jpg',
        totalCopies: 20,
        availableCopies: 14,
        rating: 4.9,
        tags: const ['Self-Improvement', 'Psychology', 'Productivity'],
        status: BookStatus.available,
        condition: BookCondition.newCondition,
        edition: 'Hardcover',
        shelfLocation: 'S-105',
      ),
      Book(
        id: '110',
        title: 'The Silent Patient',
        authorId: 'a12',
        authorName: 'Alex Michaelides',
        isbn: '9781250301697',
        categoryId: 'c1',
        categoryName: 'Fiction',
        publisherId: 'p2',
        publisherName: 'Celadon Books',
        publishDate: DateTime(2019, 2, 5),
        description: 'A psychological thriller about a famous painter who shoots her husband and never speaks another word, and the therapist obsessed with her mystery.',
        coverUrl: 'https://images-na.ssl-images-amazon.com/images/I/81jjf9S2kFL.jpg',
        totalCopies: 10,
        availableCopies: 6,
        rating: 4.5,
        tags: const ['Thriller', 'Psychological', 'Mystery'],
        status: BookStatus.available,
        condition: BookCondition.good,
        edition: 'First Edition US',
        shelfLocation: 'F-109',
      ),
      Book(
        id: '111',
        title: 'Thinking, Fast and Slow',
        authorId: 'a13',
        authorName: 'Daniel Kahneman',
        isbn: '9780374533556',
        categoryId: 'c4',
        categoryName: 'Science',
        publisherId: 'p2',
        publisherName: 'Farrar, Straus and Giroux',
        publishDate: DateTime(2011, 10, 25),
        description: 'The Nobel laureate explains the two cognitive systems that drive decision-making: fast, intuitive thinking, and slow, logical thinking.',
        coverUrl: 'https://images-na.ssl-images-amazon.com/images/I/61f1YfCXH1L.jpg',
        totalCopies: 8,
        availableCopies: 6,
        rating: 4.6,
        tags: const ['Cognitive Science', 'Psychology', 'Economics'],
        status: BookStatus.available,
        condition: BookCondition.good,
        edition: 'Paperback Edition',
        shelfLocation: 'S-202',
      ),
      Book(
        id: '112',
        title: 'The Catcher in the Rye',
        authorId: 'a14',
        authorName: 'J.D. Salinger',
        isbn: '9780316769174',
        categoryId: 'c1',
        categoryName: 'Fiction',
        publisherId: 'p1',
        publisherName: 'Little, Brown and Company',
        publishDate: DateTime(1951, 7, 16),
        description: 'The classic novel of teenage angst, alienation, and rebellion, narrated by Holden Caulfield in post-WWII New York.',
        coverUrl: 'https://images-na.ssl-images-amazon.com/images/I/8125NDY3NPL.jpg',
        totalCopies: 6,
        availableCopies: 3,
        rating: 4.3,
        tags: const ['Rebellion', 'Classic', 'Drama'],
        status: BookStatus.available,
        condition: BookCondition.fair,
        edition: 'Mass Market Press',
        shelfLocation: 'F-110',
      ),
      Book(
        id: '113',
        title: 'Educated',
        authorId: 'a15',
        authorName: 'Tara Westover',
        isbn: '9780399590504',
        categoryId: 'c3',
        categoryName: 'History',
        publisherId: 'p4',
        publisherName: 'Random House',
        publishDate: DateTime(2018, 2, 20),
        description: 'A powerful memoir about a young girl who leaves her survivalist family in rural Idaho to seek higher education, eventually earning a PhD.',
        coverUrl: 'https://images-na.ssl-images-amazon.com/images/I/81W5up5yMOL.jpg',
        totalCopies: 8,
        availableCopies: 5,
        rating: 4.7,
        tags: const ['Memoir', 'Inspiration', 'Autobiography'],
        status: BookStatus.available,
        condition: BookCondition.good,
        edition: 'First US print',
        shelfLocation: 'H-303',
      ),
      Book(
        id: '114',
        title: 'The Code Breaker',
        authorId: 'a16',
        authorName: 'Walter Isaacson',
        isbn: '9781982115852',
        categoryId: 'c4',
        categoryName: 'Science',
        publisherId: 'p1',
        publisherName: 'Simon & Schuster',
        publishDate: DateTime(2021, 3, 9),
        description: 'The story of Nobel prize winner Jennifer Doudna and the development of CRISPR gene editing, a tool with the power to cure diseases.',
        coverUrl: 'https://images-na.ssl-images-amazon.com/images/I/81L70vUe3SL.jpg',
        totalCopies: 5,
        availableCopies: 3,
        rating: 4.7,
        tags: const ['Biotechnology', 'Gene Editing', 'Biography'],
        status: BookStatus.available,
        condition: BookCondition.newCondition,
        edition: 'Hardcover print',
        shelfLocation: 'S-203',
      ),
      Book(
        id: '115',
        title: 'Neuromancer',
        authorId: 'a17',
        authorName: 'William Gibson',
        isbn: '9780441569595',
        categoryId: 'c2',
        categoryName: 'Technology',
        publisherId: 'p2',
        publisherName: 'Ace Books',
        publishDate: DateTime(1984, 7, 1),
        description: 'The quintessential cyberpunk thriller about a washed-up computer hacker hired for one last desperate run in virtual cyberspace.',
        coverUrl: 'https://images-na.ssl-images-amazon.com/images/I/81Pj6pG7L8L.jpg',
        totalCopies: 7,
        availableCopies: 5,
        rating: 4.5,
        tags: const ['Cyberpunk', 'Hacking', 'Sci-Fi'],
        status: BookStatus.available,
        condition: BookCondition.good,
        edition: '35th Anniversary Press',
        shelfLocation: 'T-104',
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
