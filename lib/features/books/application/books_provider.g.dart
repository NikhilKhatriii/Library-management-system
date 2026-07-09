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
String _$bookDetailsHash() => r'c93a4c990ac0274ebcefad2535cf7b06d638dcf7';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [bookDetails].
@ProviderFor(bookDetails)
const bookDetailsProvider = BookDetailsFamily();

/// See also [bookDetails].
class BookDetailsFamily extends Family<AsyncValue<Book>> {
  /// See also [bookDetails].
  const BookDetailsFamily();

  /// See also [bookDetails].
  BookDetailsProvider call(
    String id,
  ) {
    return BookDetailsProvider(
      id,
    );
  }

  @override
  BookDetailsProvider getProviderOverride(
    covariant BookDetailsProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'bookDetailsProvider';
}

/// See also [bookDetails].
class BookDetailsProvider extends AutoDisposeFutureProvider<Book> {
  /// See also [bookDetails].
  BookDetailsProvider(
    String id,
  ) : this._internal(
          (ref) => bookDetails(
            ref as BookDetailsRef,
            id,
          ),
          from: bookDetailsProvider,
          name: r'bookDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$bookDetailsHash,
          dependencies: BookDetailsFamily._dependencies,
          allTransitiveDependencies:
              BookDetailsFamily._allTransitiveDependencies,
          id: id,
        );

  BookDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<Book> Function(BookDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BookDetailsProvider._internal(
        (ref) => create(ref as BookDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Book> createElement() {
    return _BookDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BookDetailsProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin BookDetailsRef on AutoDisposeFutureProviderRef<Book> {
  /// The parameter `id` of this provider.
  String get id;
}

class _BookDetailsProviderElement extends AutoDisposeFutureProviderElement<Book>
    with BookDetailsRef {
  _BookDetailsProviderElement(super.provider);

  @override
  String get id => (origin as BookDetailsProvider).id;
}

String _$booksNotifierHash() => r'11789a823bb9e1fbc1e122759b18d27dc0e907a8';

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
