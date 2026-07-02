import 'package:flutter/material.dart';

/// A single analytics tile shown on a role dashboard.
class DashboardStat {
  const DashboardStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.isCurrency = false,
  });

  final String label;
  final num value;
  final IconData icon;
  final Color color;

  /// Percentage change vs. the previous period, e.g. `4.2` or `-1.8`.
  final double? trend;
  final bool isCurrency;
}

/// A single point used by the mini line/bar charts on the dashboard.
class ChartPoint {
  const ChartPoint(this.label, this.value);
  final String label;
  final double value;
}
