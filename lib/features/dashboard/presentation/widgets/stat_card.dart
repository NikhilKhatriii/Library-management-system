import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/dashboard_stat.dart';
import 'animated_counter.dart';

/// A single dashboard analytics tile: icon, animated value, label, and an
/// optional trend badge (e.g. "+3.2%"). Features a subtle gradient accent
/// matching the stat's brand color.
class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.stat, this.index = 0});

  final DashboardStat stat;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final trend = stat.trend;
    final isPositive = (trend ?? 0) >= 0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark
              ? stat.color.withValues(alpha: 0.15)
              : stat.color.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: stat.color.withValues(alpha: isDark ? 0.06 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle gradient accent in top-right corner
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    stat.color.withValues(alpha: isDark ? 0.12 : 0.08),
                    stat.color.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                          mainAxisSize: MainAxisSize.min,
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
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                AnimatedCounter(
                  value: stat.value,
                  isCurrency: stat.isCurrency,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stat.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: (60 * index).ms)
        .fadeIn(duration: AppDurations.medium)
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }
}
