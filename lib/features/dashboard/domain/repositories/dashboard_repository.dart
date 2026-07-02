import '../../../../core/utils/result.dart';
import '../../auth/domain/models/user_role.dart';
import '../domain/models/dashboard_stat.dart';

abstract interface class DashboardRepository {
  Future<Result<List<DashboardStat>>> loadStats(UserRole role);
  Future<Result<List<ChartPoint>>> loadIssueTrend();
  Future<Result<List<ChartPoint>>> loadCategoryBreakdown();
}
