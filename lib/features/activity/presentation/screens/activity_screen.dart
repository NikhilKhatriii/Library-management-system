import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../application/activity_provider.dart';
import '../../domain/models/transaction_model.dart';
import '../../domain/models/fine_model.dart';
import '../../../auth/application/auth_provider.dart';
import '../../../auth/domain/models/user_role.dart';
import '../../../books/application/books_provider.dart';
import '../../../books/domain/models/book.dart';
import '../../../../core/utils/result.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activityState = ref.watch(activityProvider);
    final user = ref.watch(authProvider).user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    final isAdminOrLibrarian =
        user.role == UserRole.admin || user.role == UserRole.librarian;

    // Filter transactions
    final activeIssues = activityState.transactions
        .where((t) => t.status == 'active')
        .toList();
    final reservations = activityState.transactions
        .where((t) => t.status == 'reserved')
        .toList();
    final history = activityState.transactions
        .where((t) => t.status == 'returned')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Simulate QR Check-in/out',
            onPressed: () => _showSimulatedQrScanner(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(activityProvider.notifier).loadActivity(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Checkouts', icon: Icon(Icons.outbound_rounded)),
            Tab(text: 'Reservations', icon: Icon(Icons.bookmark_rounded)),
            Tab(text: 'Fines & History', icon: Icon(Icons.payments_rounded)),
          ],
        ),
      ),
      body: AppBackgrounds.detail(
        showGrid: true,
        child: activityState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildActiveTab(context, activeIssues, isAdminOrLibrarian),
                  _buildReservationsTab(context, reservations, isAdminOrLibrarian),
                  _buildFinesAndHistoryTab(context, activityState.fines, history, isAdminOrLibrarian),
                ],
              ),
      ),
    );
  }

  Widget _buildActiveTab(
      BuildContext context, List<TransactionModel> active, bool isAdminOrLibrarian) {
    if (active.isEmpty) {
      return const _EmptyState(
        icon: Icons.outbound_rounded,
        title: 'No Active Checkouts',
        subtitle: 'Borrow some books from the catalog tab to see them here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: active.length,
      itemBuilder: (context, index) {
        final tx = active[index];
        final isOverdue = DateTime.now().isAfter(tx.dueDate);
        final statusColor = isOverdue ? AppColors.error : AppColors.success;

        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.bookTitle,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          if (isAdminOrLibrarian)
                            Text(
                              'Issued to: ${tx.userName}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        isOverdue ? 'Overdue' : 'Active',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Issue Date',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).hintColor,
                                )),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(tx.issueDate),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Due Date',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).hintColor,
                                )),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(tx.dueDate),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: 'Return Book',
                  onPressed: () async {
                    final notifier = ref.read(activityProvider.notifier);
                    final res = await notifier.returnBook(transactionId: tx.id);
                    if (context.mounted) {
                      if (res is Success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Book returned successfully!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text((res as Failure).message)),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReservationsTab(
      BuildContext context, List<TransactionModel> reserved, bool isAdminOrLibrarian) {
    if (reserved.isEmpty) {
      return const _EmptyState(
        icon: Icons.bookmark_rounded,
        title: 'No Reservations',
        subtitle: 'Reserve books that are currently checked out to wait in line.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: reserved.length,
      itemBuilder: (context, index) {
        final tx = reserved[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              tx.bookTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                if (isAdminOrLibrarian) Text('Reserved by: ${tx.userName}'),
                Text('Date: ${_formatDate(tx.issueDate)}'),
              ],
            ),
            trailing: isAdminOrLibrarian
                ? ElevatedButton(
                    onPressed: () async {
                      // Admin issues the reserved book
                      final notifier = ref.read(activityProvider.notifier);
                      // Return/cancel old status, issue fresh active checkout
                      await notifier.returnBook(transactionId: tx.id);
                      final res = await notifier.issueBook(
                        userId: tx.userId,
                        userName: tx.userName,
                        bookId: tx.bookId,
                        bookTitle: tx.bookTitle,
                      );
                      if (context.mounted) {
                        if (res is Success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Issued reserved book to member!')),
                          );
                        }
                      }
                    },
                    child: const Text('Issue Now'),
                  )
                : const Chip(label: Text('In Queue')),
          ),
        );
      },
    );
  }

  Widget _buildFinesAndHistoryTab(
      BuildContext context, List<FineModel> fines, List<TransactionModel> history, bool isAdminOrLibrarian) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (fines.isNotEmpty) ...[
          Text('Pending Fines', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          ...fines.map((fine) => Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  title: Text(
                    fine.bookTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isAdminOrLibrarian) Text('Member: ${fine.userName}'),
                      Text('Overdue fine accrued on ${_formatDate(fine.createdAt)}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '\$${fine.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: fine.status == 'unpaid' ? AppColors.error : AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (fine.status == 'unpaid')
                        ElevatedButton(
                          onPressed: () async {
                            final notifier = ref.read(activityProvider.notifier);
                            final res = await notifier.payFine(fineId: fine.id);
                            if (context.mounted && res is Success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Fine marked as paid!')),
                              );
                            }
                          },
                          child: const Text('Pay'),
                        )
                      else
                        const Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: AppSpacing.lg),
        ],
        Text('Returned History', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.sm),
        if (history.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: Text('No returned books yet.')),
            ),
          )
        else
          ...history.map((tx) => Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  title: Text(tx.bookTitle),
                  subtitle: Text(
                    'Returned on ${_formatDate(tx.returnDate ?? DateTime.now())}',
                  ),
                  trailing: const Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
                ),
              )),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showSimulatedQrScanner(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary),
                SizedBox(width: 8),
                Text('QR Scan Simulator'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: Center(
                            child: Icon(Icons.camera_alt_rounded, color: Colors.white24, size: 64),
                          ),
                        ),
                        // Scanner line animation simulation
                        Positioned(
                          child: Divider(color: AppColors.primary, thickness: 3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Simulate scanning a book in the library to issue or return it instantly:',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Render a list of options from books catalog to checkout
                  FutureBuilder(
                    future: ref.read(bookRepositoryProvider).getBooks(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data is! Success) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final books = (snapshot.data as Success<List<Book>>).data;
                      return Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: books.length,
                          itemBuilder: (context, index) {
                            final book = books[index];
                            return ListTile(
                              leading: Image.network(book.coverUrl, width: 36, height: 48, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.book)),
                              title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text('by ${book.authorName}'),
                              trailing: const Icon(Icons.qr_code_2_rounded),
                              onTap: () async {
                                final user = ref.read(authProvider).user!;
                                final notifier = ref.read(activityProvider.notifier);

                                // Check if user already has it
                                final hasIssued = ref.read(activityProvider).transactions.any(
                                  (tx) => tx.bookId == book.id && tx.userId == user.id && tx.status == 'active',
                                );

                                Navigator.pop(context);

                                if (hasIssued) {
                                  // Return
                                  final tx = ref.read(activityProvider).transactions.firstWhere(
                                    (t) => t.bookId == book.id && t.userId == user.id && t.status == 'active',
                                  );
                                  await notifier.returnBook(transactionId: tx.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('QR Return: "${book.title}" returned!')),
                                    );
                                  }
                                } else {
                                  // Issue
                                  final res = await notifier.issueBook(
                                    userId: user.id,
                                    userName: user.name,
                                    bookId: book.id,
                                    bookTitle: book.title,
                                  );
                                  if (context.mounted) {
                                    if (res is Success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('QR Issue: "${book.title}" checked out!')),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text((res as Failure).message)),
                                      );
                                    }
                                  }
                                }
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.4)),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }
}
