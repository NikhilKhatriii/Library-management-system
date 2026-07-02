import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/result.dart';
import '../../auth/domain/models/user_role.dart';
import '../../domain/models/dashboard_stat.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  @override
  Future<Result<List<DashboardStat>>> loadStats(UserRole role) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 600));

      final stats = switch (role) {
        UserRole.admin || UserRole.librarian => const [
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
        UserRole.student => const [
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
}
