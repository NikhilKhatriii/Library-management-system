import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/domain/models/user_role.dart';
import '../../domain/models/system_health.dart';
import '../../application/dashboard_provider.dart';
import '../../../../shared/widgets/app_background.dart';
import '../widgets/dashboard_body.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(systemHealthProvider);
    final insightsAsync = ref.watch(aiInsightsProvider);

    return Scaffold(
      body: AppBackgrounds.dashboard(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: DashboardBody(
                role: UserRole.admin, 
                showCharts: true,
                isSliver: true,
              ),
            ),
            
            // System Health Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('System Health', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.md),
                    healthAsync.when(
                      data: (health) => _HealthCard(health: health),
                      loading: () => const _SkeletonPlaceholder(height: 100),
                      error: (_, __) => const Text('Failed to load health status'),
                    ),
                  ],
                ),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.all(AppSpacing.md)),

            // AI Insights Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('AI Insights', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.royalBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('BETA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.royalBlue)),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    insightsAsync.when(
                      data: (insights) => Column(
                        children: insights.map((i) => _InsightTile(insight: i)).toList(),
                      ),
                      loading: () => const _SkeletonPlaceholder(height: 150),
                      error: (_, __) => const Text('Failed to load AI insights'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SliverPadding(padding: EdgeInsets.all(AppSpacing.xxl)),
          ],
        ),
      ),
    );
  }
}

class _HealthCard extends StatelessWidget {
  final SystemHealth health;
  const _HealthCard({required this.health});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _HealthMetric(label: 'CPU', value: '${health.cpuUsage}%', icon: Icons.speed_rounded, color: Colors.blue),
            _HealthMetric(label: 'RAM', value: '${health.memoryUsage}%', icon: Icons.memory_rounded, color: Colors.purple),
            _HealthMetric(label: 'Storage', value: '${health.storageUsage}%', icon: Icons.storage_rounded, color: Colors.orange),
            _HealthMetric(label: 'Status', value: health.serverStatus, icon: Icons.dns_rounded, color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}

class _HealthMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _HealthMetric({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _InsightTile extends StatelessWidget {
  final String insight;
  const _InsightTile({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.royalBlue.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: AppColors.royalBlue, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(insight, style: const TextStyle(fontSize: 13))),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}

class _SkeletonPlaceholder extends StatelessWidget {
  final double height;
  const _SkeletonPlaceholder({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    );
  }
}
