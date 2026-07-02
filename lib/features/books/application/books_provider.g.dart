// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'books_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookRepositoryHash() => r'1624d339baa37f9f9b005a300dc56058405410b2';

/// See also [bookRepository].
@ProviderFor(bookRepository)
final bookRepositoryProvider = Provider<BookRepository>.internal(
  bookRepository,
  name: r'bookRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bookRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef BookRepositoryRef = ProviderRef<BookRepository>;
String _$categoriesHash() => r'0688aede3e9bf5b02a824bcc1c44ef0bfb4b52ac';

/// See also [categories].
@ProviderFor(categories)
final categoriesProvider = AutoDisposeFutureProvider<List<Category>>.internal(
  categories,
  name: r'categoriesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$categoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CategoriesRef = AutoDisposeFutureProviderRef<List<Category>>;
String _$authorsHash() => r'cab2634412057fd85b79647a3e71dd297760607a';

/// See also [authors].
@ProviderFor(authors)
final authorsProvider = AutoDisposeFutureProvider<List<Author>>.internal(
  authors,
  name: r'authorsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authorsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthorsRef = AutoDisposeFutureProviderRef<List<Author>>;
String _$publishersHash() => r'3d3139bbee6e55dcc98f5df49535c9f1f437b740';

/// See also [publishers].
@ProviderFor(publishers)
final publishersProvider = AutoDisposeFutureProvider<List<Publisher>>.internal(
  publishers,
  name: r'publishersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$publishersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PublishersRef = AutoDisposeFutureProviderRef<List<Publisher>>;
String _$booksNotifierHash() => r'97f9aca0e30bb8994eca9fa3aba22ef5dc223cef';

/// See also [BooksNotifier].
@ProviderFor(BooksNotifier)
final booksNotifierProvider =
    AutoDisposeNotifierProvider<BooksNotifier, BooksState>.internal(
  BooksNotifier.new,
  name: r'booksNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$booksNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BooksNotifier = AutoDisposeNotifier<BooksState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
