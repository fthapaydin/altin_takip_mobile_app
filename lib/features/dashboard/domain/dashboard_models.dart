import 'package:equatable/equatable.dart';

/// Portfolio summary with total value, cost, and profit/loss
class PortfolioSummary extends Equatable {
  final double totalValue;
  final double totalCost;
  final double profitLoss;
  final double profitLossPercentage;

  const PortfolioSummary({
    required this.totalValue,
    required this.totalCost,
    required this.profitLoss,
    required this.profitLossPercentage,
  });

  @override
  List<Object?> get props => [
    totalValue,
    totalCost,
    profitLoss,
    profitLossPercentage,
  ];
}

/// Chart data point for portfolio value over time
class ChartDataPoint extends Equatable {
  final DateTime date; /* Used for sorting / logic if needed */
  final double value;
  final String? label;

  const ChartDataPoint({required this.date, required this.value, this.label});

  @override
  List<Object?> get props => [date, value, label];
}
