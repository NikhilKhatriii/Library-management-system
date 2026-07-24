import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../application/books_provider.dart';
import '../../domain/models/book.dart';

import '../../../auth/application/auth_provider.dart';
import '../../../activity/application/activity_provider.dart';

class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsync = ref.watch(bookDetailsProvider(bookId));
    final theme = Theme.of(context);

    return Scaffold(
      body: bookAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading book: $err')),
        data: (book) {
          if (context.isDesktop) {
            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'book-${book.id}',
                        child: CachedNetworkImage(
                          imageUrl: book.coverUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: SafeArea(
                          child: CircleAvatar(
                            backgroundColor: Colors.black45,
                            child: BackButton(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        pinned: true,
                        automaticallyImplyLeading: false,
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
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.lg),
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
                              _buildActions(context, ref, book),
                              const SizedBox(height: AppSpacing.xl),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

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
                      _buildActions(context, ref, book),
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

  Widget _buildActions(BuildContext context, WidgetRef ref, Book book) {
    final user = ref.watch(authProvider).user;
    final activityState = ref.watch(activityProvider);

    if (user == null) return const SizedBox.shrink();

    // Check if user has already issued this book
    final hasIssued = activityState.transactions.any(
      (tx) => tx.bookId == book.id && tx.userId == user.id && tx.status == 'active',
    );

    final String buttonLabel;
    if (hasIssued) {
      buttonLabel = 'Return Book';
    } else if (book.availableCopies > 0) {
      buttonLabel = 'Issue Book';
    } else {
      buttonLabel = 'Reserve Now';
    }

    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            label: buttonLabel,
            isLoading: activityState.isLoading,
            onPressed: () async {
              if (hasIssued) {
                // Return book
                final tx = activityState.transactions.firstWhere(
                  (t) => t.bookId == book.id && t.userId == user.id && t.status == 'active',
                );
                final res = await ref.read(activityProvider.notifier).returnBook(transactionId: tx.id);
                if (context.mounted) {
                  if (res is Success) {
                    ref.invalidate(bookDetailsProvider(book.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Book returned successfully!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text((res as Failure).message)),
                    );
                  }
                }
              } else if (book.availableCopies > 0) {
                // Issue book
                final res = await ref.read(activityProvider.notifier).issueBook(
                      userId: user.id,
                      userName: user.name,
                      bookId: book.id,
                      bookTitle: book.title,
                    );
                if (context.mounted) {
                  if (res is Success) {
                    ref.invalidate(bookDetailsProvider(book.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Book issued successfully!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text((res as Failure).message)),
                    );
                  }
                }
              } else {
                // Reserve book
                final res = await ref.read(activityProvider.notifier).reserveBook(
                      userId: user.id,
                      userName: user.name,
                      bookId: book.id,
                      bookTitle: book.title,
                    );
                if (context.mounted) {
                  if (res is Success) {
                    ref.invalidate(bookDetailsProvider(book.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Book reserved successfully!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text((res as Failure).message)),
                    );
                  }
                }
              }
            },
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
