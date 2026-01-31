import 'package:equatable/equatable.dart';
import 'package:altin_takip/features/assets/domain/asset.dart';
import 'package:altin_takip/features/dashboard/domain/dashboard_models.dart';

/// Complete dashboard data including summary, chart, and transactions
class DashboardData extends Equatable {
  final PortfolioSummary summary;
  final List<ChartDataPoint> chartData;
  final List<Asset> recentTransactions;

  const DashboardData({
    required this.summary,
    required this.chartData,
    required this.recentTransactions,
  });

  @override
  List<Object?> get props => [summary, chartData, recentTransactions];
}
