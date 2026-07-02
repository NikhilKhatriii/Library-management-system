import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/application/auth_provider.dart';
import '../../../auth/domain/models/user_role.dart';
import '../../application/dashboard_provider.dart';
import 'mini_line_chart.dart';
import 'mini_pie_chart.dart';
import 'stat_card.dart';

/// Shared body for every role dashboard: greeting header, animated stat
/// grid, and (for staff roles) trend/category charts. Individual role
/// screens just wrap this in their own [Scaffold]/[AppBar].
class DashboardBody extends ConsumerWidget {
  const DashboardBody({
    super.key,
    required this.role,
    this.showCharts = false,
  });

  final UserRole role;
  final bool showCharts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final statsAsync = ref.watch(dashboardStatsProvider(role));
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(dashboardStatsProvider(role));
        ref.invalidate(issueTrendProvider);
        ref.invalidate(categoryBreakdownProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      user?.name.split(' ').first ?? role.label,
                      style: theme.textTheme.headlineMedium,
                    ),
                  ],
                ).animate().fadeIn().slideY(begin: 0.08, end: 0),
              ),
              CircleAvatar(
                radius: 22,
                backgroundColor: role.color.withValues(alpha: 0.15),
                child: Text(
                  user?.initials ?? role.label.substring(0, 1),
                  style: TextStyle(color: role.color, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          statsAsync.when(
            data: (stats) => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stats.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.35,
              ),
              itemBuilder: (context, index) =>
                  StatCard(stat: stats[index], index: index),
            ),
            loading: () => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.35,
              ),
              itemBuilder: (context, index) => const _StatSkeleton(),
            ),
            error: (err, st) => Text('Could not load stats: $err'),
          ),
          if (showCharts) ...[
            const SizedBox(height: AppSpacing.xl),
            Text('Weekly Issue Trend', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: SizedBox(
                  height: 180,
                  child: ref.watch(issueTrendProvider).when(
                        data: (points) => MiniLineChart(points: points),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, s) => const Center(child: Text('Unable to load trend')),
                      ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Category Breakdown', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: ref.watch(categoryBreakdownProvider).when(
                      data: (points) => MiniPieChart(points: points),
                      loading: () => const SizedBox(
                        height: 110,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, s) => const Text('Unable to load breakdown'),
                    ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _StatSkeleton extends StatelessWidget {
  const _StatSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}
