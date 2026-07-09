import '../../../../core/utils/result.dart';
import '../../../auth/domain/models/user_role.dart';
import '../models/dashboard_stat.dart';
import '../models/system_health.dart';

abstract interface class DashboardRepository {
  Future<Result<List<DashboardStat>>> loadStats(UserRole role);
  Future<Result<List<ChartPoint>>> loadIssueTrend();
  Future<Result<List<ChartPoint>>> loadCategoryBreakdown();
  Future<Result<SystemHealth>> getSystemHealth();
  Future<Result<List<String>>> getAiInsights();
}
