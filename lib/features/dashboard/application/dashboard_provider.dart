import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/result.dart';
import '../../auth/domain/models/user_role.dart';
import '../data/repositories/dashboard_repository_impl.dart';
import '../domain/models/dashboard_stat.dart';
import '../domain/repositories/dashboard_repository.dart';

import '../data/repositories/firestore_dashboard_repository.dart';
import '../../../main.dart' show firebaseInitialized;

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  if (firebaseInitialized) {
    return FirestoreDashboardRepository();
  }
  return DashboardRepositoryImpl();
});

final dashboardStatsProvider =
    FutureProvider.family<List<DashboardStat>, UserRole>((ref, role) async {
  final result = await ref.watch(dashboardRepositoryProvider).loadStats(role);
  if (result is Success<List<DashboardStat>>) {
    return result.data;
  } else {
    throw (result as Failure).message;
  }
});

final issueTrendProvider = FutureProvider<List<ChartPoint>>((ref) async {
  final result = await ref.watch(dashboardRepositoryProvider).loadIssueTrend();
  if (result is Success<List<ChartPoint>>) {
    return result.data;
  } else {
    throw (result as Failure).message;
  }
});

final categoryBreakdownProvider = FutureProvider<List<ChartPoint>>((ref) async {
  final result = await ref.watch(dashboardRepositoryProvider).loadCategoryBreakdown();
  if (result is Success<List<ChartPoint>>) {
    return result.data;
  } else {
    throw (result as Failure).message;
  }
});
