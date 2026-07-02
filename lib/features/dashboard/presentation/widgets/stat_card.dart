import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/dashboard_stat.dart';
import 'animated_counter.dart';

/// A single dashboard analytics tile: icon, animated value, label, and an
/// optional trend badge (e.g. "+3.2%").
class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.stat, this.index = 0});

  final DashboardStat stat;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trend = stat.trend;
    final isPositive = (trend ?? 0) >= 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: stat.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(stat.icon, color: stat.color, size: 20),
                ),
                if (trend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isPositive ? theme.colorScheme.tertiary : theme.colorScheme.error)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                          size: 12,
                          color: isPositive ? theme.colorScheme.tertiary : theme.colorScheme.error,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${trend.abs().toStringAsFixed(1)}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isPositive ? theme.colorScheme.tertiary : theme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AnimatedCounter(
              value: stat.value,
              isCurrency: stat.isCurrency,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 2),
            Text(
              stat.label,
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    )
        .animate(delay: (60 * index).ms)
        .fadeIn(duration: AppDurations.medium)
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }
}
