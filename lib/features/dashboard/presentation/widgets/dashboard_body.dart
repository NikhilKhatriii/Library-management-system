import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/application/auth_provider.dart';
import '../../../auth/domain/models/user_role.dart';
import '../../application/dashboard_provider.dart';
import '../../domain/models/system_health.dart';
import '../../../books/application/books_provider.dart';
import '../../../books/presentation/widgets/book_card.dart';
import 'stat_card.dart';
import '../../../../core/utils/responsive_utils.dart';

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
    final booksAsync = ref.watch(booksNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isStaff = role == UserRole.librarian;

    // Responsive columns based on breakpoints
    final statsCrossAxisCount = const ResponsiveValue<int>(
      mobile: 2,
      tablet: 3,
      desktop: 4,
    ).resolve(context);
    
    final statsAspectRatio = const ResponsiveValue<double>(
      mobile: 1.55,
      tablet: 1.45,
      desktop: 1.35,
    ).resolve(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Personalized Header
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isStaff 
                  ? 'Command Center'
                  : '${user?.name.split(' ').first ?? 'User'}, your\njourney continues',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  color: isDark ? Colors.white : AppColors.primary,
                ),
              ).animate().fadeIn().slideY(begin: 0.1, end: 0),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 1.5,
                    color: AppColors.royalBlue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isStaff 
                      ? 'ENTERPRISE SYSTEM ACCESS • v2.4.0'
                      : 'ARCHIVAL ACCESS LEVEL 04 • YEAR OF INQUIRY',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.5,
                      color: theme.hintColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms),
            ],
          ),
        ),
        
        const SizedBox(height: AppSpacing.xl),

        // 2. Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 56,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: theme.hintColor),
              const SizedBox(width: 12),
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search the system...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              Icon(Icons.tune_rounded, color: theme.hintColor, size: 20),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

        const SizedBox(height: AppSpacing.xxl),

        // 3. Stats Overview
        statsAsync.when(
          data: (stats) => Column(
            children: [
              if (!isStaff) ...[
                _ReadingGoalCard(theme: theme, isDark: isDark),
                const SizedBox(height: AppSpacing.md),
              ],
              GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stats.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: statsCrossAxisCount,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: statsAspectRatio,
                ),
                itemBuilder: (context, index) =>
                    StatCard(stat: stats[index], index: index),
              ),
            ],
          ),
          loading: () => const _LoadingStats(),
          error: (err, st) => Text('Error: $err'),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // 4. Role-Specific Content
        if (!isStaff) ...[
          _buildStudentContent(context, theme, booksAsync),
        ] else ...[
          _buildStaffContent(context, theme, ref),
        ],

        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildStudentContent(BuildContext context, ThemeData theme, BooksState booksState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Curated for You',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('EXPAND VIEW', style: TextStyle(fontSize: 12, letterSpacing: 1)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: const ResponsiveValue<double>(mobile: 280, desktop: 320).resolve(context),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: booksState.books.length.clamp(0, 5),
            itemBuilder: (context, index) {
              final book = booksState.books[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: AppSpacing.md),
                child: BookCard(book: book),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        _buildInsightsSection(theme),
        const SizedBox(height: AppSpacing.xxl),
        _buildLibrarianNote(theme),
      ],
    );
  }

  Widget _buildStaffContent(BuildContext context, ThemeData theme, WidgetRef ref) {
    final healthAsync = ref.watch(systemHealthProvider);
    final insightsAsync = ref.watch(aiInsightsProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Management', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _QuickActionTile(
              icon: Icons.add_rounded, 
              label: 'Add Book', 
              color: AppColors.royalBlue,
              onTap: () => context.goNamed('add_book'),
            ),
            _QuickActionTile(
              icon: Icons.person_add_rounded, 
              label: 'Add Member', 
              color: AppColors.accent,
              onTap: () => context.goNamed(RouteNames.members),
            ),
            _QuickActionTile(
              icon: Icons.swap_horiz_rounded, 
              label: 'Activity', 
              color: Colors.orange,
              onTap: () => context.goNamed(RouteNames.activity),
            ),
            _QuickActionTile(
              icon: Icons.analytics_rounded, 
              label: 'Reports', 
              color: Colors.purple,
              onTap: () => context.goNamed(RouteNames.reports),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text('System Health', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.md),
        healthAsync.when(
          data: (health) => _HealthCard(health: health),
          loading: () => Container(height: 100, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(24))),
          error: (_, __) => const Text('Error loading health'),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text('AI System Insights', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.md),
        insightsAsync.when(
          data: (insights) => Column(
            children: [
              for (int i = 0; i < insights.length; i++)
                _InsightTile(insight: insights[i], isDark: isDark),
            ],
          ),
          loading: () => Container(height: 150, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(24))),
          error: (_, __) => const Text('Error loading insights'),
        ),
      ],
    );
  }

  Widget _buildInsightsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.insights_rounded, size: 18, color: AppColors.royalBlue),
            const SizedBox(width: 8),
            Text(
              'Global insights',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const _InsightItem(
          title: 'Algorithmic Ethics',
          subtitle: 'BROWSE ANTHOLOGY • 4TH INQUIRY',
          icon: Icons.auto_awesome_mosaic_rounded,
        ),
        const _InsightItem(
          title: 'Sustainable Urbanism',
          subtitle: 'TOP IN ARCHITECTURE • NEW ACQUISITION',
          icon: Icons.architecture_rounded,
        ),
        const _InsightItem(
          title: 'Quantum Narratives',
          subtitle: 'TRENDING IN LITERATURE • 2024 COLLECTION',
          icon: Icons.blur_on_rounded,
        ),
      ],
    );
  }

  Widget _buildLibrarianNote(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.royalBlue.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "LIBRARIAN'S NOTE",
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
              color: AppColors.royalBlue,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '"The true archivist does not just collect, but connects. Your recent interest in spatial dynamics suggests the \'Silent Structures\' entry might build your next breakthrough."',
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadingGoalCard extends StatelessWidget {
  const _ReadingGoalCard({required this.theme, required this.isDark});
  final ThemeData theme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'READING GOALS',
                  style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '82%',
                  style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, color: AppColors.royalBlue),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    _StatMini(label: 'BOOKS FINISHED', value: '14'),
                    SizedBox(width: 16),
                    _StatMini(label: 'EXP COLLECTIONS', value: '09'),
                  ],
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: 0.82,
                  strokeWidth: 8,
                  backgroundColor: AppColors.royalBlue.withValues(alpha: 0.1),
                  color: AppColors.royalBlue,
                  strokeCap: StrokeCap.round,
                ),
              ),
              const Icon(Icons.auto_stories_rounded, color: AppColors.royalBlue),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _QuickActionTile({required this.icon, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
  final bool isDark;
  const _InsightTile({required this.insight, required this.isDark});

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

class _StatMini extends StatelessWidget {
  const _StatMini({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _InsightItem extends StatelessWidget {
  const _InsightItem({required this.title, required this.subtitle, required this.icon});
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.royalBlue, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey, letterSpacing: 0.5)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}

class _LoadingStats extends StatelessWidget {
  const _LoadingStats();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 140, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(24))),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Container(height: 80, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)))),
            const SizedBox(width: 16),
            Expanded(child: Container(height: 80, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)))),
          ],
        ),
      ],
    );
  }
}
