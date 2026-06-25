import 'package:flutter/material.dart';
import 'package:altin_takip/features/assets/presentation/asset_state.dart';
import 'package:altin_takip/features/dashboard/presentation/widgets/portfolio_detail_models.dart';

/// Pure functions to calculate portfolio value, profit/loss, and breakdown details.
class PortfolioDetailHelper {
  /// Calculates the total selling worth of all assets in the portfolio.
  static double computeTotalWorth(AssetLoaded state) {
    if (state.assets.isEmpty || state.currencies.isEmpty) return 0.0;
    double total = 0;
    final Map<int, double> holdings = {};

    for (var asset in state.assets) {
      final amount = asset.amount;
      if (asset.type == 'buy') {
        holdings[asset.currencyId] = (holdings[asset.currencyId] ?? 0) + amount;
      } else {
        holdings[asset.currencyId] = (holdings[asset.currencyId] ?? 0) - amount;
      }
    }

    holdings.forEach((currencyId, amount) {
      try {
        final currency = state.currencies.firstWhere(
          (c) => c.id == currencyId,
          orElse: () {
            final asset = state.assets.firstWhere(
              (a) => a.currencyId == currencyId,
            );
            if (asset.currency != null) return asset.currency!;
            throw Exception('Currency not found');
          },
        );
        total += amount * currency.selling;
      } catch (_) {}
    });
    return total;
  }

  /// Calculates the current profit or loss based on initial purchase cost.
  static double computeProfitLoss(AssetLoaded state) {
    double totalCost = 0;
    double currentVal = 0;
    for (var asset in state.assets) {
      if (asset.type == 'buy') {
        totalCost += asset.amount * asset.price;
        currentVal += asset.amount * (asset.currency?.selling ?? asset.price);
      } else {
        totalCost -= asset.amount * asset.price;
        currentVal -= asset.amount * (asset.currency?.buying ?? asset.price);
      }
    }
    return currentVal - totalCost;
  }

  /// Calculates the allocation between Gold and Foreign Exchange.
  static PortfolioAllocationData computeAllocation(AssetLoaded state) {
    double goldValue = 0;
    double forexValue = 0;
    final Map<int, double> holdings = {};

    for (var asset in state.assets) {
      if (asset.type == 'buy') {
        holdings[asset.currencyId] = (holdings[asset.currencyId] ?? 0) + asset.amount;
      } else {
        holdings[asset.currencyId] = (holdings[asset.currencyId] ?? 0) - asset.amount;
      }
    }

    holdings.forEach((currencyId, amount) {
      if (amount <= 0) return;
      final currency = state.currencies.firstWhere(
        (c) => c.id == currencyId,
        orElse: () => state.currencies.first,
      );
      final value = amount * currency.selling;
      if (currency.type == 'Altın') {
        goldValue += value;
      } else {
        forexValue += value;
      }
    });

    final total = goldValue + forexValue;
    return PortfolioAllocationData(
      goldValue: goldValue,
      forexValue: forexValue,
      total: total,
      goldPercent: total > 0 ? goldValue / total * 100 : 0,
      forexPercent: total > 0 ? forexValue / total * 100 : 0,
    );
  }

  /// Computes a sorted list of assets for the breakdown view.
  static List<PortfolioBreakdownItem> computeBreakdown(AssetLoaded state) {
    final Map<int, double> holdings = {};
    for (var asset in state.assets) {
      if (asset.type == 'buy') {
        holdings[asset.currencyId] = (holdings[asset.currencyId] ?? 0) + asset.amount;
      } else {
        holdings[asset.currencyId] = (holdings[asset.currencyId] ?? 0) - asset.amount;
      }
    }

    double totalValue = 0;
    final items = <PortfolioBreakdownItem>[];

    const goldColors = [
      Color(0xFFE5C07B),
      Color(0xFFF0D28C),
      Color(0xFFC49B55),
      Color(0xFFD4A855),
    ];
    const forexColors = [
      Color(0xFF60A5FA),
      Color(0xFF818CF8),
      Color(0xFF34D399),
      Color(0xFF22D3EE),
    ];

    int goldIdx = 0;
    int forexIdx = 0;

    holdings.forEach((currencyId, amount) {
      if (amount <= 0) return;
      final currency = state.currencies.firstWhere(
        (c) => c.id == currencyId,
        orElse: () => state.currencies.first,
      );
      final value = amount * currency.selling;
      totalValue += value;

      final isGold = currency.type == 'Altın';
      final color = isGold
          ? goldColors[goldIdx++ % goldColors.length]
          : forexColors[forexIdx++ % forexColors.length];

      items.add(PortfolioBreakdownItem(
        name: currency.name,
        value: value,
        percentage: 0,
        color: color,
        type: currency.type,
        amount: amount,
      ));
    });

    if (totalValue == 0) return [];

    final result = items.map((item) {
      return PortfolioBreakdownItem(
        name: item.name,
        value: item.value,
        percentage: (item.value / totalValue) * 100,
        color: item.color,
        type: item.type,
        amount: item.amount,
      );
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return result;
  }
}
