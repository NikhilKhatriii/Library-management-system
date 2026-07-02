import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/utils/result.dart';
import '../data/datasources/firestore_book_datasource.dart';
import '../data/repositories/firestore_book_repository.dart';
import '../domain/models/book.dart';
import '../domain/models/author.dart';
import '../domain/models/category.dart';
import '../domain/models/publisher.dart';
import '../domain/repositories/book_repository.dart';
import '../../../main.dart' show firebaseInitialized;
import '../data/repositories/mock_book_repository.dart';

part 'books_provider.g.dart';

@Riverpod(keepAlive: true)
BookRepository bookRepository(BookRepositoryRef ref) {
  if (firebaseInitialized) {
    return FirestoreBookRepository(FirestoreBookDataSource());
  }
  return MockBookRepository();
}

class BooksState {
  final List<Book> books;
  final bool isLoading;
  final String? errorMessage;
  final bool hasMore;
  final int currentPage;
  final String? searchQuery;
  final String? categoryFilter;

  const BooksState({
    this.books = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasMore = true,
    this.currentPage = 1,
    this.searchQuery,
    this.categoryFilter,
  });

  BooksState copyWith({
    List<Book>? books,
    bool? isLoading,
    String? errorMessage,
    bool? hasMore,
    int? currentPage,
    String? searchQuery,
    String? categoryFilter,
  }) {
    return BooksState(
      books: books ?? this.books,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter,
    );
  }
}

@riverpod
class BooksNotifier extends _$BooksNotifier {
  @override
  BooksState build() {
    return const BooksState();
  }

  Future<void> fetchBooks({bool refresh = false}) async {
    if (state.isLoading || (!refresh && !state.hasMore)) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    final page = refresh ? 1 : state.currentPage + (state.books.isEmpty ? 0 : 1);
    final result = await ref.read(bookRepositoryProvider).getBooks(
      page: page,
      query: state.searchQuery,
      categoryId: state.categoryFilter,
    );

    if (result is Success<List<Book>>) {
      final newBooks = result.data;
      state = state.copyWith(
        books: refresh ? newBooks : [...state.books, ...newBooks],
        isLoading: false,
        hasMore: newBooks.length >= 20,
        currentPage: page,
      );
    } else if (result is Failure<List<Book>>) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.message,
      );
    }
  }

  Future<void> searchBooks(String query) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      books: [],
      searchQuery: query.isEmpty ? null : query,
    );
    final result = await ref.read(bookRepositoryProvider).getBooks(
      query: query.isEmpty ? null : query,
      categoryId: state.categoryFilter,
    );

    if (result is Success<List<Book>>) {
      state = state.copyWith(
        books: result.data,
        isLoading: false,
        hasMore: false,
      );
    } else if (result is Failure<List<Book>>) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.message,
      );
    }
  }

  /// Filter books by category. Pass null to clear the filter.
  Future<void> filterByCategory(String? categoryId) async {
    state = state.copyWith(
      categoryFilter: categoryId,
      books: [],
      isLoading: true,
      errorMessage: null,
      currentPage: 1,
      hasMore: true,
    );

    final result = await ref.read(bookRepositoryProvider).getBooks(
      query: state.searchQuery,
      categoryId: categoryId,
    );

    if (result is Success<List<Book>>) {
      state = state.copyWith(
        books: result.data,
        isLoading: false,
        hasMore: result.data.length >= 20,
      );
    } else if (result is Failure<List<Book>>) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.message,
      );
    }
  }

  Future<Result<void>> addBook(Book book) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await ref.read(bookRepositoryProvider).addBook(book);
    if (result is Success<void>) {
      state = state.copyWith(
        books: [book, ...state.books],
        isLoading: false,
      );
      return const Success(null);
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: (result as Failure).message,
      );
      return result;
    }
  }

  Future<Result<void>> updateBook(Book book) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await ref.read(bookRepositoryProvider).updateBook(book);
    if (result is Success<void>) {
      state = state.copyWith(
        books: state.books.map((b) => b.id == book.id ? book : b).toList(),
        isLoading: false,
      );
      return const Success(null);
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: (result as Failure).message,
      );
      return result;
    }
  }

  Future<Result<void>> deleteBook(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await ref.read(bookRepositoryProvider).deleteBook(id);
    if (result is Success<void>) {
      state = state.copyWith(
        books: state.books.where((b) => b.id != id).toList(),
        isLoading: false,
      );
      return const Success(null);
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: (result as Failure).message,
      );
      return result;
    }
  }
}

@riverpod
Future<List<Category>> categories(CategoriesRef ref) async {
  final result = await ref.watch(bookRepositoryProvider).getCategories();
  if (result is Success<List<Category>>) {
    return result.data;
  }
  throw Exception((result as Failure).message);
}

@riverpod
Future<List<Author>> authors(AuthorsRef ref) async {
  final result = await ref.watch(bookRepositoryProvider).getAuthors();
  if (result is Success<List<Author>>) {
    return result.data;
  }
  throw Exception((result as Failure).message);
}

@riverpod
Future<List<Publisher>> publishers(PublishersRef ref) async {
  final result = await ref.watch(bookRepositoryProvider).getPublishers();
  if (result is Success<List<Publisher>>) {
    return result.data;
  }
  throw Exception((result as Failure).message);
}

@riverpod
Future<Book> bookDetails(BookDetailsRef ref, String id) async {
  final result = await ref.watch(bookRepositoryProvider).getBookById(id);
  if (result is Success<Book>) {
    return result.data;
  }
  throw Exception((result as Failure).message);
}
