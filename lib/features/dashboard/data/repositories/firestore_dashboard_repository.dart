import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/utils/result.dart';
import '../../../auth/domain/models/user_role.dart';
import '../../domain/models/dashboard_stat.dart';
import '../../domain/repositories/dashboard_repository.dart';

/// Computes dashboard statistics from real Firestore data instead of
/// returning hardcoded mock values.
class FirestoreDashboardRepository implements DashboardRepository {
  @override
  Future<Result<List<DashboardStat>>> loadStats(UserRole role) async {
    try {
      switch (role) {
        case UserRole.admin:
        case UserRole.librarian:
          return Success(await _loadAdminStats());
        case UserRole.teacher:
          return Success(await _loadTeacherStats());
        case UserRole.student:
          return Success(await _loadStudentStats());
      }
    } on Exception catch (e) {
      return Failure('Failed to load dashboard stats', e);
    }
  }

  Future<List<DashboardStat>> _loadAdminStats() async {
    final booksSnap = await FirebaseService.booksCollection.count().get();
    final totalBooks = booksSnap.count ?? 0;

    final activeIssuesSnap = await FirebaseService.transactionsCollection
        .where('status', isEqualTo: 'active')
        .count()
        .get();
    final activeIssues = activeIssuesSnap.count ?? 0;

    // Available copies: sum from books collection
    final allBooks = await FirebaseService.booksCollection.get();
    int availableCopies = 0;
    for (final doc in allBooks.docs) {
      availableCopies += (doc.data()['availableCopies'] as int?) ?? 0;
    }

    // Overdue: active transactions past due date
    final now = Timestamp.fromDate(DateTime.now());
    final overdueSnap = await FirebaseService.transactionsCollection
        .where('status', isEqualTo: 'active')
        .where('dueDate', isLessThan: now)
        .count()
        .get();
    final overdue = overdueSnap.count ?? 0;

    // Pending fines total
    final pendingFines = await FirebaseService.finesCollection
        .where('status', isEqualTo: 'paid')
        .get();
    double finesCollected = 0;
    for (final doc in pendingFines.docs) {
      finesCollected += (doc.data()['amount'] as num?)?.toDouble() ?? 0;
    }

    // Active members
    final membersSnap = await FirebaseService.usersCollection
        .where('isApproved', isEqualTo: true)
        .count()
        .get();
    final activeMembers = membersSnap.count ?? 0;

    return [
      DashboardStat(
        label: 'Total Books',
        value: totalBooks,
        icon: Icons.auto_stories_rounded,
        color: AppColors.primary,
      ),
      DashboardStat(
        label: 'Books Issued',
        value: activeIssues,
        icon: Icons.outbound_rounded,
        color: AppColors.secondary,
      ),
      DashboardStat(
        label: 'Available Copies',
        value: availableCopies,
        icon: Icons.inventory_2_rounded,
        color: AppColors.accent,
      ),
      DashboardStat(
        label: 'Overdue Books',
        value: overdue,
        icon: Icons.schedule_rounded,
        color: AppColors.error,
      ),
      DashboardStat(
        label: 'Fine Collected',
        value: finesCollected.round(),
        icon: Icons.payments_rounded,
        color: AppColors.warning,
        isCurrency: true,
      ),
      DashboardStat(
        label: 'Active Members',
        value: activeMembers,
        icon: Icons.groups_rounded,
        color: AppColors.info,
      ),
    ];
  }

  Future<List<DashboardStat>> _loadTeacherStats() async {
    final activeSnap = await FirebaseService.transactionsCollection
        .where('status', isEqualTo: 'active')
        .count()
        .get();
    final reservedSnap = await FirebaseService.reservationsCollection
        .where('status', isEqualTo: 'pending')
        .count()
        .get();

    return [
      DashboardStat(
        label: 'Books Borrowed',
        value: activeSnap.count ?? 0,
        icon: Icons.outbound_rounded,
        color: AppColors.primary,
      ),
      DashboardStat(
        label: 'Reserved Titles',
        value: reservedSnap.count ?? 0,
        icon: Icons.inventory_2_rounded,
        color: AppColors.secondary,
      ),
      const DashboardStat(
        label: 'Class Sets',
        value: 0,
        icon: Icons.groups_rounded,
        color: AppColors.accent,
      ),
      const DashboardStat(
        label: 'Due This Week',
        value: 0,
        icon: Icons.schedule_rounded,
        color: AppColors.warning,
      ),
    ];
  }

  Future<List<DashboardStat>> _loadStudentStats() async {
    final activeSnap = await FirebaseService.transactionsCollection
        .where('status', isEqualTo: 'active')
        .count()
        .get();

    final finesSnap = await FirebaseService.finesCollection
        .where('status', isEqualTo: 'pending')
        .get();
    double outstandingFine = 0;
    for (final doc in finesSnap.docs) {
      outstandingFine += (doc.data()['amount'] as num?)?.toDouble() ?? 0;
    }

    return [
      DashboardStat(
        label: 'Books Borrowed',
        value: activeSnap.count ?? 0,
        icon: Icons.outbound_rounded,
        color: AppColors.primary,
      ),
      const DashboardStat(
        label: 'Due Soon',
        value: 0,
        icon: Icons.schedule_rounded,
        color: AppColors.warning,
      ),
      DashboardStat(
        label: 'Outstanding Fine',
        value: outstandingFine.round(),
        icon: Icons.payments_rounded,
        color: AppColors.error,
        isCurrency: true,
      ),
      const DashboardStat(
        label: 'Wishlist',
        value: 0,
        icon: Icons.inventory_2_rounded,
        color: AppColors.accent,
      ),
    ];
  }

  @override
  Future<Result<List<ChartPoint>>> loadIssueTrend() async {
    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

      final snapshot = await FirebaseService.transactionsCollection
          .where('issueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(weekAgo))
          .where('type', isEqualTo: 'issue')
          .get();

      final counts = <int, int>{};
      for (final doc in snapshot.docs) {
        final ts = (doc.data()['issueDate'] as Timestamp).toDate();
        final weekday = ts.weekday;
        counts[weekday] = (counts[weekday] ?? 0) + 1;
      }

      return Success([
        for (int i = 1; i <= 7; i++)
          ChartPoint(days[i - 1], (counts[i] ?? 0).toDouble()),
      ]);
    } on Exception catch (e) {
      return Failure('Failed to load issue trend', e);
    }
  }

  @override
  Future<Result<List<ChartPoint>>> loadCategoryBreakdown() async {
    try {
      final snapshot = await FirebaseService.booksCollection.get();
      final catCounts = <String, int>{};
      for (final doc in snapshot.docs) {
        final cat = doc.data()['categoryName'] as String? ?? 'Other';
        catCounts[cat] = (catCounts[cat] ?? 0) + 1;
      }

      final sorted = catCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return Success(
        sorted.take(5).map((e) => ChartPoint(e.key, e.value.toDouble())).toList(),
      );
    } on Exception catch (e) {
      return Failure('Failed to load category breakdown', e);
    }
  }
}
