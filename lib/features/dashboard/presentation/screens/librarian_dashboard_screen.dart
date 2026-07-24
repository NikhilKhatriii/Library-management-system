import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/domain/models/user_role.dart';
import '../widgets/dashboard_body.dart';
import '../../application/dashboard_provider.dart';

class LibrarianDashboardScreen extends ConsumerWidget {
  const LibrarianDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.royalBlue,
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider(UserRole.librarian));
          ref.invalidate(systemHealthProvider);
          ref.invalidate(aiInsightsProvider);
        },
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: DashboardBody(
            role: UserRole.librarian,
            showCharts: true,
          ),
        ),
      ),
    );
  }
}
