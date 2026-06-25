import 'package:flutter/material.dart';

/// Data class to hold gold vs forex allocation summaries for the portfolio detail tabs.
class PortfolioAllocationData {
  final double goldValue;
  final double forexValue;
  final double total;
  final double goldPercent;
  final double forexPercent;

  const PortfolioAllocationData({
    required this.goldValue,
    required this.forexValue,
    required this.total,
    required this.goldPercent,
    required this.forexPercent,
  });
}

/// Data class to hold computed breakdown details for each asset.
class PortfolioBreakdownItem {
  final String name;
  final double value;
  final double percentage;
  final Color color;
  final String type;
  final double amount;

  const PortfolioBreakdownItem({
    required this.name,
    required this.value,
    required this.percentage,
    required this.color,
    required this.type,
    required this.amount,
  });
}
