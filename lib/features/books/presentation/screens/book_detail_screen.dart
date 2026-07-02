import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../application/books_provider.dart';
import '../../domain/models/book.dart';

class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(bookRepositoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: FutureBuilder(
        future: repository.getBookById(bookId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data is! Success) {
            return const Center(child: Text('Error loading book'));
          }
          
          final book = (snapshot.data as Success<Book>).data;

          return CustomScrollView(
            slivers: [
              _buildAppBar(context, book),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(theme, book),
                      const SizedBox(height: AppSpacing.xl),
                      _buildInfoGrid(theme, book),
                      const SizedBox(height: AppSpacing.xl),
                      Text('Description', style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        book.description,
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildActions(context, book),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Book book) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'book-${book.id}',
          child: CachedNetworkImage(
            imageUrl: book.coverUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(book.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded),
          color: Colors.red,
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.share_rounded),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, Book book) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                book.title,
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                book.categoryName,
                style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'by ${book.authorName}',
          style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.star_rounded, color: Colors.amber[600], size: 20),
            const SizedBox(width: 4),
            Text(
              book.rating.toString(),
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.visibility_outlined, size: 20),
            const SizedBox(width: 4),
            const Text('245 Views'),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoGrid(ThemeData theme, Book book) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfoItem(theme, 'ISBN', book.isbn),
        _buildInfoItem(theme, 'Published', book.publishDate.year.toString()),
        _buildInfoItem(theme, 'Copies', '${book.availableCopies}/${book.totalCopies}'),
      ],
    );
  }

  Widget _buildInfoItem(ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildActions(BuildContext context, Book book) {
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            label: book.isAvailable ? 'Issue Book' : 'Reserve Now',
            onPressed: () {},
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: IconButton(
            icon: const Icon(Icons.bookmark_border_rounded),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
