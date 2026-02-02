import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/assets/presentation/asset_state.dart';
import 'package:altin_takip/features/dashboard/presentation/widgets/portfolio_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altin_takip/features/assets/presentation/asset_notifier.dart';
import 'package:altin_takip/features/settings/presentation/preference_notifier.dart';
import 'package:iconsax/iconsax.dart';

class PortfolioSummaryCard extends ConsumerWidget {
  final AssetState state;

  const PortfolioSummaryCard({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivacyMode = ref.watch(preferenceProvider).isPrivacyModeEnabled;

    if (state is AssetLoading) {
      return _buildPortfolioShimmer();
    }

    // Use dashboard data if available, otherwise calculate from assets
    final dashboardSummary = (state is AssetLoaded)
        ? (state as AssetLoaded).dashboardData?.summary
        : null;
    final chartData = (state is AssetLoaded)
        ? (state as AssetLoaded).dashboardData?.chartData
        : null;

    final totalWorth =
        dashboardSummary?.totalValue ??
        (state is AssetLoaded
            ? _calculateTotalWorth(state as AssetLoaded)
            : 0.0);
    final profitLoss =
        dashboardSummary?.profitLoss ??
        (state is AssetLoaded
            ? _calculateProfitLoss(state as AssetLoaded)
            : 0.0);
    final profitPercentage =
        dashboardSummary?.profitLossPercentage ??
        ((totalWorth - profitLoss) > 0
            ? (profitLoss / (totalWorth - profitLoss)) * 100
            : 0.0);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Deep matte charcoal
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(0, 20),
            blurRadius: 40,
            spreadRadius: -10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Ambient Gradient Mesh
            Positioned(
              top: -50,
              right: -50,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.gold.withOpacity(0.15),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -30,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blueAccent.withOpacity(0.1),
                  ),
                ),
              ),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildPrivacyBlur(
                enabled: isPrivacyMode,
                child: AbsorbPointer(
                  absorbing: isPrivacyMode,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Title & Profit Pill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOPLAM VARLIK',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const Gap(8),
                              Text(
                                '₺${NumberFormat('#,##0.00', 'tr_TR').format(totalWorth)}',
                                style: const TextStyle(
                                  fontFeatures: [FontFeature.tabularFigures()],
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -1,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (profitLoss >= 0 ? Colors.green : Colors.red)
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    (profitLoss >= 0
                                            ? Colors.green
                                            : Colors.red)
                                        .withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  profitLoss >= 0
                                      ? Iconsax.arrow_up
                                      : Iconsax.arrow_down,
                                  color: profitLoss >= 0
                                      ? Colors.green
                                      : Colors.red,
                                  size: 14,
                                ),
                                const Gap(4),
                                Text(
                                  '%${NumberFormat('#,##0.1', 'tr_TR').format(profitPercentage.abs())}',
                                  style: TextStyle(
                                    color: profitLoss >= 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Gap(24),

                      // Chart Area
                      SizedBox(
                        height: 120,
                        width: double.infinity,
                        child: chartData != null && chartData.isNotEmpty
                            ? PortfolioChart(
                                chartData: chartData,
                                totalCost: totalWorth - profitLoss,
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Grafik verisi alınamadı',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.3),
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (state is AssetLoaded &&
                                        !(state as AssetLoaded)
                                            .isRefreshing) ...[
                                      const Gap(8),
                                      TextButton.icon(
                                        onPressed: () {
                                          ref
                                              .read(assetProvider.notifier)
                                              .loadDashboard(refresh: true);
                                        },
                                        icon: const Icon(
                                          Iconsax.refresh,
                                          size: 16,
                                        ),
                                        label: const Text('Tekrar Dene'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppTheme.gold,
                                          textStyle: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                      ),

                      const Gap(32),

                      // Detailed Asset Allocation
                      _buildAssetAllocation(
                        state,
                        isPrivacyMode: isPrivacyMode,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildAssetAllocation(AssetState state, {bool isPrivacyMode = false}) {
    if (state is! AssetLoaded) return const SizedBox();

    double goldValue = 0;
    double forexValue = 0;

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
    if (total == 0) return const SizedBox();

    final goldPercent = (goldValue / total * 100);
    final forexPercent = (forexValue / total * 100);

    return Column(
      children: [
        // Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                if (goldValue > 0)
                  Expanded(
                    flex: goldPercent.round(),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.gold,
                            AppTheme.gold.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                if (forexValue > 0)
                  Expanded(
                    flex: forexPercent.round(),
                    child: Container(
                      color: const Color(0xFF4C82F7).withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const Gap(20),
        // Details Row
        Row(
          children: [
            Expanded(
              child: _buildAllocationItem(
                label: 'ALTIN',
                amount: goldValue,
                percentage: goldPercent,
                color: AppTheme.gold,
                isPrivacyMode: isPrivacyMode,
              ),
            ),
            Container(
              width: 1,
              height: 32,
              color: Colors.white.withValues(alpha: 0.1),
            ),
            Expanded(
              child: _buildAllocationItem(
                label: 'DÖVİZ',
                amount: forexValue,
                percentage: forexPercent,
                color: const Color(0xFF4C82F7),
                isRight: true,
                isPrivacyMode: isPrivacyMode,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAllocationItem({
    required String label,
    required double amount,
    required double percentage,
    required Color color,
    bool isRight = false,
    bool isPrivacyMode = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: isRight ? 24 : 0, right: isRight ? 0 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const Gap(8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const Gap(4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₺${NumberFormat('#,##0.00', 'tr_TR').format(amount)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              Text(
                '%${percentage.toStringAsFixed(0)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioShimmer() {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface,
      highlightColor: Colors.white10,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const Gap(12),
                    Container(
                      width: 180,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 80,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
            const Gap(32),
            // Chart Placeholder
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const Gap(32),
            // Allocation Bar
            Container(
              height: 12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const Gap(20),
            // Allocation Details
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Gap(4),
                      Container(
                        width: 100,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 32, color: Colors.white10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 60,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Gap(4),
                      Container(
                        width: 100,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotalWorth(AssetLoaded state) {
    if (state.assets.isEmpty || state.currencies.isEmpty) return 0.0;

    double currentTotalValue = 0;
    final Map<int, double> holdings = {};

    // Calculate net holdings per currency
    for (var asset in state.assets) {
      final amount = asset.amount;
      if (asset.type == 'buy') {
        holdings[asset.currencyId] = (holdings[asset.currencyId] ?? 0) + amount;
      } else {
        holdings[asset.currencyId] = (holdings[asset.currencyId] ?? 0) - amount;
      }
    }

    // Multiply net holdings by current selling price
    holdings.forEach((currencyId, amount) {
      try {
        // Find currency in loaded list or use the one from assets if not there
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
        currentTotalValue += amount * currency.selling;
      } catch (_) {
        // Fallback for missing currency info
      }
    });

    return currentTotalValue;
  }

  double _calculateProfitLoss(AssetLoaded state) {
    double totalCost = 0;
    double currentVal = 0;

    for (var asset in state.assets) {
      if (asset.type == 'buy') {
        totalCost += asset.amount * asset.price;
        final currentPrice = asset.currency?.selling ?? asset.price;
        currentVal += asset.amount * currentPrice;
      } else {
        totalCost -= asset.amount * asset.price;
        final currentPrice = asset.currency?.buying ?? asset.price;
        currentVal -= asset.amount * currentPrice;
      }
    }

    return currentVal - totalCost;
  }

  Widget _buildPrivacyBlur({
    required Widget child,
    required bool enabled,
    double sigma = 6.6,
  }) {
    if (!enabled) return child;
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: child,
    );
  }
}
