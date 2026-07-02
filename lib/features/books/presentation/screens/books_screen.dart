import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../application/books_provider.dart';
import '../widgets/book_card.dart';
import '../widgets/book_skeleton.dart';
import '../../../auth/application/auth_provider.dart';
import '../../../auth/domain/models/user_role.dart';

class BooksScreen extends ConsumerStatefulWidget {
  const BooksScreen({super.key});

  @override
  ConsumerState<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends ConsumerState<BooksScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(booksNotifierProvider.notifier).fetchBooks();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(booksNotifierProvider.notifier).fetchBooks();
    }
  }

  void _showScannerSim() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Icon(Icons.qr_code_scanner_rounded, size: 64, color: Colors.blue),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Scan Book Barcode',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Scan any physical book barcode to instantly find it in the catalog.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      onPressed: () {
                        // Pick Gatsby, Mockingbird, or Clean Code ISBN
                        final isbns = ['9780743273565', '9780061120084', '9780132350884'];
                        final randomIsbn = isbns[DateTime.now().millisecondsSinceEpoch % isbns.length];
                        _searchController.text = randomIsbn;
                        ref.read(booksNotifierProvider.notifier).searchBooks(randomIsbn);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Scanned ISBN: $randomIsbn. Searching...')),
                        );
                      },
                      child: const Text('Simulate Scan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(booksNotifierProvider);
    final user = ref.watch(authProvider).user;
    final isStaff = user?.role == UserRole.admin || user?.role == UserRole.librarian;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            onPressed: _showScannerSim,
          ),
          if (isStaff)
            IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: () => context.goNamed('add_book'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => ref.read(booksNotifierProvider.notifier).searchBooks(value),
              decoration: InputDecoration(
                hintText: 'Search books, authors, ISBN...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(booksNotifierProvider.notifier).fetchBooks(refresh: true);
                        },
                      )
                    : null,
              ),
            ),
          ),
          const _CategoryFilterBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(booksNotifierProvider.notifier).fetchBooks(refresh: true),
              child: state.books.isEmpty && state.isLoading
                  ? _buildLoadingGrid()
                  : state.books.isEmpty
                      ? const EmptyState(
                          icon: Icons.book_outlined,
                          title: 'No Books Found',
                          message: 'Try adjusting your search or filters to find what you are looking for.',
                        )
                      : _buildBookGrid(state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.7,
      ),
      itemCount: 10,
      itemBuilder: (context, index) => const BookSkeleton(),
    );
  }

  Widget _buildBookGrid(BooksState state) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.7,
      ),
      itemCount: state.books.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < state.books.length) {
          return BookCard(
            book: state.books[index],
            onTap: () {
              context.goNamed(
                'book_details',
                pathParameters: {'id': state.books[index].id},
              );
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class _CategoryFilterBar extends ConsumerStatefulWidget {
  const _CategoryFilterBar();

  @override
  ConsumerState<_CategoryFilterBar> createState() => _CategoryFilterBarState();
}

class _CategoryFilterBarState extends ConsumerState<_CategoryFilterBar> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return SizedBox(
      height: 60,
      child: categoriesAsync.when(
        data: (categories) => ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
          itemCount: categories.length + 1,
          itemBuilder: (context, index) {
            final isAll = index == 0;
            final category = isAll ? null : categories[index - 1];
            final isSelected = isAll ? _selectedCategoryId == null : _selectedCategoryId == category!.id;
            
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: FilterChip(
                label: Text(isAll ? 'All' : category!.name),
                selected: isSelected,
                onSelected: (selected) {
                  final newId = isAll ? null : category!.id;
                  setState(() => _selectedCategoryId = newId);
                  ref.read(booksNotifierProvider.notifier).filterByCategory(newId);
                },
                backgroundColor: Theme.of(context).cardColor,
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: isSelected 
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).textTheme.labelLarge?.color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                side: BorderSide(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}
