import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _ReportCard(
            title: 'Borrowing Trends',
            subtitle: 'Monthly volume comparison',
            child: _BarChart(),
          ),
          const SizedBox(height: AppSpacing.lg),
          _ReportCard(
            title: 'Revenue Overview',
            subtitle: 'Fine collections and grants',
            child: _LineChart(),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _ActionCard(icon: Icons.picture_as_pdf_rounded, label: 'Export PDF'),
              _ActionCard(icon: Icons.table_view_rounded, label: 'Export Excel'),
              _ActionCard(icon: Icons.print_rounded, label: 'Print All'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ReportCard({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(height: 200, child: child),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.royalBlue),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: AppColors.royalBlue, width: 16)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: AppColors.royalBlue, width: 16)]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 14, color: AppColors.royalBlue, width: 16)]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 12, color: AppColors.royalBlue, width: 16)]),
          BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 18, color: AppColors.royalBlue, width: 16)]),
        ],
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [FlSpot(0, 3), FlSpot(1, 4), FlSpot(2, 2), FlSpot(3, 5), FlSpot(4, 3.5)],
            isCurved: true,
            color: AppColors.accent,
            barWidth: 4,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: AppColors.accent.withValues(alpha: 0.1)),
          ),
        ],
      ),
    );
  }
}
