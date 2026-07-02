import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/domain/models/user_role.dart';
import '../domain/models/dashboard_stat.dart';

/// Supplies dashboard analytics for the given role.
///
/// This is intentionally backed by static, deterministic mock data so the
/// UI can be fully built and demoed before the real `/dashboard` REST
/// endpoint exists. Replace the body of [DashboardRepository.loadStats]
/// with a real API call — the provider signature does not need to change.
class DashboardRepository {
  const DashboardRepository();

  Future<List<DashboardStat>> loadStats(UserRole role) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    switch (role) {
      case UserRole.admin:
      case UserRole.librarian:
        return const [
          DashboardStat(
            label: 'Total Books',
            value: 12480,
            icon: Icons.auto_stories_rounded,
            color: AppColors.primary,
            trend: 3.2,
          ),
          DashboardStat(
            label: 'Books Issued',
            value: 842,
            icon: Icons.outbound_rounded,
            color: AppColors.secondary,
            trend: 1.8,
          ),
          DashboardStat(
            label: 'Available Copies',
            value: 9310,
            icon: Icons.inventory_2_rounded,
            color: AppColors.accent,
            trend: -0.6,
          ),
          DashboardStat(
            label: 'Overdue Books',
            value: 57,
            icon: Icons.schedule_rounded,
            color: AppColors.error,
            trend: -4.1,
          ),
          DashboardStat(
            label: 'Fine Collected',
            value: 18420,
            icon: Icons.payments_rounded,
            color: AppColors.warning,
            trend: 6.4,
            isCurrency: true,
          ),
          DashboardStat(
            label: 'Active Members',
            value: 3210,
            icon: Icons.groups_rounded,
            color: AppColors.info,
            trend: 2.1,
          ),
        ];
      case UserRole.teacher:
        return const [
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
        ];
      case UserRole.student:
        return const [
          DashboardStat(
            label: 'Books Borrowed',
            value: 3,
            icon: Icons.outbound_rounded,
            color: AppColors.primary,
          ),
          DashboardStat(
            label: 'Due Soon',
            value: 1,
            icon: Icons.schedule_rounded,
            color: AppColors.warning,
          ),
          DashboardStat(
            label: 'Outstanding Fine',
            value: 40,
            icon: Icons.payments_rounded,
            color: AppColors.error,
            isCurrency: true,
          ),
          DashboardStat(
            label: 'Wishlist',
            value: 8,
            icon: Icons.inventory_2_rounded,
            color: AppColors.accent,
          ),
        ];
    }
  }

  Future<List<ChartPoint>> loadIssueTrend() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return const [
      ChartPoint('Mon', 32),
      ChartPoint('Tue', 48),
      ChartPoint('Wed', 40),
      ChartPoint('Thu', 61),
      ChartPoint('Fri', 55),
      ChartPoint('Sat', 24),
      ChartPoint('Sun', 18),
    ];
  }

  Future<List<ChartPoint>> loadCategoryBreakdown() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return const [
      ChartPoint('Fiction', 34),
      ChartPoint('Science', 22),
      ChartPoint('History', 16),
      ChartPoint('Tech', 18),
      ChartPoint('Other', 10),
    ];
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return const DashboardRepository();
});

final dashboardStatsProvider =
    FutureProvider.family<List<DashboardStat>, UserRole>((ref, role) {
  return ref.read(dashboardRepositoryProvider).loadStats(role);
});

final issueTrendProvider = FutureProvider<List<ChartPoint>>((ref) {
  return ref.read(dashboardRepositoryProvider).loadIssueTrend();
});

final categoryBreakdownProvider = FutureProvider<List<ChartPoint>>((ref) {
  return ref.read(dashboardRepositoryProvider).loadCategoryBreakdown();
});
