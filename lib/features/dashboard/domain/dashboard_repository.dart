import 'package:fpdart/fpdart.dart';
import 'package:altin_takip/core/error/failures.dart';
import 'package:altin_takip/features/dashboard/domain/dashboard_data.dart';

/// Repository interface for dashboard operations
abstract class DashboardRepository {
  /// Fetch complete dashboard data including summary, chart, and recent transactions
  Future<Either<Failure, DashboardData>> getDashboardData();
}
