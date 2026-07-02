import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/utils/result.dart';
import '../data/repositories/mock_book_repository.dart';
import '../domain/models/book.dart';
import '../domain/models/author.dart';
import '../domain/models/category.dart';
import '../domain/models/publisher.dart';
import '../domain/repositories/book_repository.dart';

part 'books_provider.g.dart';

@Riverpod(keepAlive: true)
BookRepository bookRepository(BookRepositoryRef ref) {
  return MockBookRepository();
}

class BooksState {
  final List<Book> books;
  final bool isLoading;
  final String? errorMessage;
  final bool hasMore;
  final int currentPage;

  const BooksState({
    this.books = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasMore = true,
    this.currentPage = 1,
  });

  BooksState copyWith({
    List<Book>? books,
    bool? isLoading,
    String? errorMessage,
    bool? hasMore,
    int? currentPage,
  }) {
    return BooksState(
      books: books ?? this.books,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
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
    final result = await ref.read(bookRepositoryProvider).getBooks(page: page);

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
    state = state.copyWith(isLoading: true, errorMessage: null, books: []);
    final result = await ref.read(bookRepositoryProvider).getBooks(query: query);

    if (result is Success<List<Book>>) {
      state = state.copyWith(
        books: result.data,
        isLoading: false,
        hasMore: false, // For search we don't handle pagination in this simple mock
      );
    } else if (result is Failure<List<Book>>) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.message,
      );
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
