import 'package:altin_takip/features/dashboard/domain/dashboard_models.dart';
import 'package:altin_takip/features/assets/data/asset_dto.dart';
import 'package:altin_takip/features/dashboard/domain/dashboard_data.dart';

/// DTO for portfolio summary
class PortfolioSummaryDto extends PortfolioSummary {
  const PortfolioSummaryDto({
    required super.totalValue,
    required super.totalCost,
    required super.profitLoss,
    required super.profitLossPercentage,
  });

  factory PortfolioSummaryDto.fromJson(Map<String, dynamic> json) {
    return PortfolioSummaryDto(
      totalValue: (json['total_value'] as num).toDouble(),
      totalCost: (json['total_cost'] as num).toDouble(),
      profitLoss: (json['profit_loss'] as num).toDouble(),
      profitLossPercentage: (json['profit_loss_percentage'] as num).toDouble(),
    );
  }
}

/// DTO for chart data point
class ChartDataPointDto extends ChartDataPoint {
  const ChartDataPointDto({required super.date, required super.value});

  factory ChartDataPointDto.fromJson(Map<String, dynamic> json) {
    return ChartDataPointDto(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
    );
  }
}

/// DTO for complete dashboard data
class DashboardDataDto extends DashboardData {
  const DashboardDataDto({
    required super.summary,
    required super.chartData,
    required super.recentTransactions,
  });

  factory DashboardDataDto.fromJson(Map<String, dynamic> json) {
    return DashboardDataDto(
      summary: PortfolioSummaryDto.fromJson(
        json['portfolio_summary'] as Map<String, dynamic>,
      ),
      chartData: (json['chart_data'] as List)
          .map((e) => ChartDataPointDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentTransactions: (json['recent_transactions'] as List)
          .map((e) => AssetDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
