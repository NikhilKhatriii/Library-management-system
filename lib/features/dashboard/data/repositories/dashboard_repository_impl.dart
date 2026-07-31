import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/result.dart';
import '../../../auth/domain/models/user_role.dart';
import '../../../books/domain/models/book.dart';
import '../../domain/models/dashboard_stat.dart';
import '../../domain/models/system_health.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  @override
  Future<Result<List<DashboardStat>>> loadStats(UserRole role) async {
    try {
      // Load real dynamic data from Hive box if available
      final booksBox = await Hive.openBox<Book>('lib_books');
      final txBox = await Hive.openBox<Map>('activity_transactions');
      final fineBox = await Hive.openBox<Map>('activity_fines');

      final totalBooks = booksBox.length;
      final activeTx = txBox.values.where((tx) => tx['status'] == 'active').length;
      
      int availableCopies = 0;
      for (final book in booksBox.values) {
        availableCopies += book.availableCopies;
      }
      
      final overdueCount = txBox.values.where((tx) {
        if (tx['status'] != 'active') return false;
        final dueDateStr = tx['dueDate'] as String?;
        if (dueDateStr == null) return false;
        final dueDate = DateTime.tryParse(dueDateStr);
        return dueDate != null && DateTime.now().isAfter(dueDate);
      }).length;

      double totalFines = 0.0;
      for (final fineMap in fineBox.values) {
        totalFines += (fineMap['amount'] as num?)?.toDouble() ?? 0.0;
      }

      final stats = switch (role) {
        UserRole.librarian => [
            DashboardStat(
              label: 'Total Books',
              value: totalBooks > 0 ? totalBooks : 12480,
              icon: Icons.auto_stories_rounded,
              color: AppColors.primary,
              trend: 3.2,
            ),
            DashboardStat(
              label: 'Books Issued',
              value: totalBooks > 0 ? activeTx : 842,
              icon: Icons.outbound_rounded,
              color: AppColors.secondary,
              trend: 1.8,
            ),
            DashboardStat(
              label: 'Available Copies',
              value: totalBooks > 0 ? availableCopies : 9310,
              icon: Icons.inventory_2_rounded,
              color: AppColors.accent,
              trend: -0.6,
            ),
            DashboardStat(
              label: 'Overdue Books',
              value: totalBooks > 0 ? overdueCount : 57,
              icon: Icons.schedule_rounded,
              color: AppColors.error,
              trend: -4.1,
            ),
            DashboardStat(
              label: 'Fine Collected',
              value: totalFines > 0.0 ? totalFines.toInt() : 18420,
              icon: Icons.payments_rounded,
              color: AppColors.warning,
              trend: 6.4,
              isCurrency: true,
            ),
            const DashboardStat(
              label: 'Active Members',
              value: 3210,
              icon: Icons.groups_rounded,
              color: AppColors.info,
              trend: 2.1,
            ),
          ],
        UserRole.teacher => const [
            DashboardStat(
              label: 'Books Borrowed',
              value: 6,
              icon: Icons.outbound_rounded,
              color: AppColors.primary,
            ),
            DashboardStat(
              label: 'Reserved Titles',
              value: 2,
              icon: Icons.inventory_2_rounded,
              color: AppColors.secondary,
            ),
            DashboardStat(
              label: 'Class Sets Requested',
              value: 3,
              icon: Icons.groups_rounded,
              color: AppColors.accent,
            ),
            DashboardStat(
              label: 'Due This Week',
              value: 1,
              icon: Icons.schedule_rounded,
              color: AppColors.warning,
            ),
          ],
        UserRole.student => [
            DashboardStat(
              label: 'Books Borrowed',
              value: totalBooks > 0 ? activeTx : 3,
              icon: Icons.outbound_rounded,
              color: AppColors.primary,
            ),
            DashboardStat(
              label: 'Due Soon',
              value: totalBooks > 0 ? overdueCount : 1,
              icon: Icons.schedule_rounded,
              color: AppColors.warning,
            ),
            DashboardStat(
              label: 'Outstanding Fine',
              value: totalFines > 0.0 ? totalFines.toInt() : 40,
              icon: Icons.payments_rounded,
              color: AppColors.error,
              isCurrency: true,
            ),
            const DashboardStat(
              label: 'Wishlist',
              value: 8,
              icon: Icons.inventory_2_rounded,
              color: AppColors.accent,
            ),
          ],
      };
      return Success(stats);
    } catch (e) {
      return Failure('Failed to load dashboard stats', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<List<ChartPoint>>> loadIssueTrend() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return const Success([
        ChartPoint('Mon', 32),
        ChartPoint('Tue', 48),
        ChartPoint('Wed', 40),
        ChartPoint('Thu', 61),
        ChartPoint('Fri', 55),
        ChartPoint('Sat', 24),
        ChartPoint('Sun', 18),
      ]);
    } catch (e) {
      return Failure('Failed to load issue trend', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<List<ChartPoint>>> loadCategoryBreakdown() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return const Success([
        ChartPoint('Fiction', 34),
        ChartPoint('Science', 22),
        ChartPoint('History', 16),
        ChartPoint('Tech', 18),
        ChartPoint('Other', 10),
      ]);
    } catch (e) {
      return Failure('Failed to load category breakdown', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<SystemHealth>> getSystemHealth() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const Success(SystemHealth(
      cpuUsage: 12.5,
      memoryUsage: 45.8,
      storageUsage: 62.1,
      serverStatus: 'Operational',
      uptimeMinutes: 14400,
    ));
  }

  @override
  Future<Result<List<String>>> getAiInsights() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return const Success([
      'Demand for "Technology" books has increased by 15% this week.',
      'Recommended: Increase copies of "Clean Code" due to high reservation rate.',
      'Alert: 5 books are likely to be overdue in the next 48 hours.',
      'Insight: Student activity peaks between 2:00 PM and 4:00 PM on Wednesdays.',
    ]);
  }
}
