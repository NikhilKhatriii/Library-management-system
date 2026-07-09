import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/result.dart';
import '../../auth/domain/models/user_role.dart';
import '../domain/models/system_health.dart';
import '../domain/models/dashboard_stat.dart';
import '../domain/repositories/dashboard_repository.dart';
import '../data/repositories/dashboard_repository_impl.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
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

final systemHealthProvider = StreamProvider<SystemHealth>((ref) async* {
  // Start with default values
  var cpu = 12.5;
  var ram = 45.8;
  const storage = 62.1;
  var uptime = 14400;
  
  final random = math.Random();
  
  while (true) {
    yield SystemHealth(
      cpuUsage: double.parse(cpu.toStringAsFixed(1)),
      memoryUsage: double.parse(ram.toStringAsFixed(1)),
      storageUsage: storage,
      serverStatus: 'Operational',
      uptimeMinutes: uptime,
    );
    
    await Future<void>.delayed(const Duration(seconds: 3));
    
    // Smoothly drift stats to emulate realistic activity fluctuations
    cpu = (cpu + (random.nextDouble() * 6 - 3)).clamp(5.0, 95.0);
    ram = (ram + (random.nextDouble() * 2 - 1)).clamp(30.0, 90.0);
    uptime += 1;
  }
});

final aiInsightsProvider = FutureProvider<List<String>>((ref) async {
  final result = await ref.watch(dashboardRepositoryProvider).getAiInsights();
  if (result is Success<List<String>>) {
    return result.data;
  } else {
    throw (result as Failure).message;
  }
});
