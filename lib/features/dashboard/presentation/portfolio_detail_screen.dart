import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/widgets/app_bar_widget.dart';
import 'package:altin_takip/features/assets/presentation/asset_state.dart';
import 'package:altin_takip/features/dashboard/domain/dashboard_models.dart';
import 'package:altin_takip/features/settings/presentation/preference_notifier.dart';

/// Full-page portfolio breakdown screen.
/// Shows allocation bar, asset breakdown list, daily chart and summary stats.
class PortfolioDetailScreen extends ConsumerWidget {
  final AssetLoaded state;

  const PortfolioDetailScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivacy = ref.watch(preferenceProvider).isPrivacyModeEnabled;
    final breakdown = _computeBreakdown(state);
    final allocation = _computeAllocation(state);
    final dashboardSummary = state.dashboardData?.summary;

    final totalWorth = dashboardSummary?.totalValue ?? _totalWorth(state);
    final profitLoss = dashboardSummary?.profitLoss ?? _profitLoss(state);
    final totalCost = dashboardSummary?.totalCost ?? (totalWorth - profitLoss);
    final profitPercentage =
        dashboardSummary?.profitLossPercentage ??
        (totalCost > 0 ? (profitLoss / totalCost) * 100 : 0.0);

    final rawChartData = state.dashboardData?.chartData ?? [];
    final sortedChartData = List<ChartDataPoint>.from(rawChartData)
      ..sort((a, b) => a.date.compareTo(b.date));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: const AppBarWidget(
          title: 'Portföy Detayları',
          showBack: true,
          centerTitle: true,
        ),
        body: SafeArea(
          top: false,
          child: _PrivacyBlur(
            enabled: isPrivacy,
            child: Column(
              children: [
                // ── Fixed Hero Card ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _HeroBalanceCard(
                    totalWorth: totalWorth,
                    totalCost: totalCost,
                    profitLoss: profitLoss,
                    profitPercentage: profitPercentage,
                  ),
                ),
                const Gap(16),

                // ── Sticky Tab Bar ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.glassColor,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: AppTheme.glassBorder),
                    ),
                    child: TabBar(
                      isScrollable: false,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.white,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      indicator: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      overlayColor: WidgetStateProperty.all(
                        Colors.transparent,
                      ),
                      tabs: const [
                        Tab(text: 'Değişim'),
                        Tab(text: 'Dağılım'),
                        Tab(text: 'Varlıklar'),
                      ],
                    ),
                  ),
                ),
                const Gap(12),

                // ── Tab Content ──
                Expanded(
                  child: TabBarView(
                    children: [
                      _ChangeTab(chartData: sortedChartData),
                      _AllocationTab(allocation: allocation),
                      _AssetsTab(breakdown: breakdown),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Calculations ──

  double _totalWorth(AssetLoaded state) {
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

  double _profitLoss(AssetLoaded state) {
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

  _AllocationData _computeAllocation(AssetLoaded state) {
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
    return _AllocationData(
      goldValue: goldValue,
      forexValue: forexValue,
      total: total,
      goldPercent: total > 0 ? goldValue / total * 100 : 0,
      forexPercent: total > 0 ? forexValue / total * 100 : 0,
    );
  }

  List<_BreakdownItem> _computeBreakdown(AssetLoaded state) {
    final Map<int, double> holdings = {};
    for (var asset in state.assets) {
      if (asset.type == 'buy') {
        holdings[asset.currencyId] = (holdings[asset.currencyId] ?? 0) + asset.amount;
      } else {
        holdings[asset.currencyId] = (holdings[asset.currencyId] ?? 0) - asset.amount;
      }
    }

    double totalValue = 0;
    final items = <_BreakdownItem>[];

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

      items.add(_BreakdownItem(
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
      return _BreakdownItem(
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

// ─────────────────────────────────────────────
// Tab 1: Değişim (Chart + Daily List)
// ─────────────────────────────────────────────

class _ChangeTab extends StatelessWidget {
  final List<ChartDataPoint> chartData;

  const _ChangeTab({required this.chartData});

  @override
  Widget build(BuildContext context) {
    if (chartData.length < 2) {
      return const Center(
        child: Text(
          'Henüz yeterli veri yok',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      children: [
        _DailyChartWidget(chartData: chartData),
        const Gap(12),
        _DailyChangeList(chartData: chartData),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Tab 2: Dağılım (Allocation)
// ─────────────────────────────────────────────

class _AllocationTab extends StatelessWidget {
  final _AllocationData allocation;

  const _AllocationTab({required this.allocation});

  @override
  Widget build(BuildContext context) {
    if (allocation.total == 0) {
      return const Center(
        child: Text(
          'Henüz varlık yok',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      children: [
        _AllocationStrip(allocation: allocation),
        const Gap(16),
        _AllocationDetailCard(allocation: allocation),
      ],
    );
  }
}

class _AllocationDetailCard extends StatelessWidget {
  final _AllocationData allocation;

  const _AllocationDetailCard({required this.allocation});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00', 'tr_TR');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detay',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
            ),
          ),
          const Gap(16),
          _AllocationDetailRow(
            label: 'Altın',
            value: '₺${formatter.format(allocation.goldValue)}',
            percent: '%${allocation.goldPercent.toStringAsFixed(1)}',
            color: AppTheme.gold,
          ),
          const Gap(12),
          _AllocationDetailRow(
            label: 'Döviz',
            value: '₺${formatter.format(allocation.forexValue)}',
            percent: '%${allocation.forexPercent.toStringAsFixed(1)}',
            color: const Color(0xFF60A5FA),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white12, height: 1),
          ),
          _AllocationDetailRow(
            label: 'Toplam',
            value: '₺${formatter.format(allocation.total)}',
            percent: '%100',
            color: Colors.white,
            isBold: true,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }
}

class _AllocationDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final String percent;
  final Color color;
  final bool isBold;

  const _AllocationDetailRow({
    required this.label,
    required this.value,
    required this.percent,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const Gap(10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isBold ? Colors.white : Colors.white.withValues(alpha: 0.7),
              fontSize: isBold ? 14 : 13,
              fontWeight: isBold ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          percent,
          style: TextStyle(
            color: color.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        const Gap(16),
        Text(
          value,
          style: TextStyle(
            fontFeatures: const [FontFeature.tabularFigures()],
            color: isBold ? Colors.white : Colors.white.withValues(alpha: 0.9),
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.w500 : FontWeight.w400,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Tab 3: Varlıklar (Asset Breakdown)
// ─────────────────────────────────────────────

class _AssetsTab extends StatelessWidget {
  final List<_BreakdownItem> breakdown;

  const _AssetsTab({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    if (breakdown.isEmpty) {
      return Center(child: _EmptyState());
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      itemCount: breakdown.length,
      separatorBuilder: (_, __) => const Gap(8),
      itemBuilder: (context, index) => _AssetRow(
        item: breakdown[index],
        index: index,
        maxValue: breakdown.first.value,
      ),
    );
  }
}

class _AllocationData {
  final double goldValue;
  final double forexValue;
  final double total;
  final double goldPercent;
  final double forexPercent;

  const _AllocationData({
    required this.goldValue,
    required this.forexValue,
    required this.total,
    required this.goldPercent,
    required this.forexPercent,
  });
}

class _BreakdownItem {
  final String name;
  final double value;
  final double percentage;
  final Color color;
  final String type;
  final double amount;

  const _BreakdownItem({
    required this.name,
    required this.value,
    required this.percentage,
    required this.color,
    required this.type,
    required this.amount,
  });
}

// ─────────────────────────────────────────────
// Hero Balance Card
// ─────────────────────────────────────────────

class _HeroBalanceCard extends StatelessWidget {
  final double totalWorth;
  final double totalCost;
  final double profitLoss;
  final double profitPercentage;

  const _HeroBalanceCard({
    required this.totalWorth,
    required this.totalCost,
    required this.profitLoss,
    required this.profitPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = profitLoss >= 0;
    final profitColor = isPositive
        ? const Color(0xFF34D399)
        : const Color(0xFFEF4444);
    final formatter = NumberFormat('#,##0.00', 'tr_TR');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.surface,
            AppTheme.surface.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          // Balance
          Text(
            '₺${formatter.format(totalWorth)}',
            style: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w400,
              letterSpacing: -1.5,
            ),
          ),
          const Gap(12),

          // Stats row
          Row(
            children: [
              _HeroStat(
                label: 'Yatırım',
                value: '₺${formatter.format(totalCost)}',
                color: AppTheme.gold,
              ),
              _VerticalDivider(),
              _HeroStat(
                label: 'Kâr / Zarar',
                value:
                    '${isPositive ? '+' : '-'}₺${formatter.format(profitLoss.abs())}',
                color: profitColor,
              ),
              _VerticalDivider(),
              _HeroStat(
                label: 'Getiri',
                value:
                    '${isPositive ? '+' : ''}%${NumberFormat('#,##0.1', 'tr_TR').format(profitPercentage)}',
                color: profitColor,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _HeroStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
          const Gap(4),
          Text(
            value,
            style: TextStyle(
              fontFeatures: const [FontFeature.tabularFigures()],
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white.withValues(alpha: 0.08),
    );
  }
}


// ─────────────────────────────────────────────
// Daily Change Chart
// ─────────────────────────────────────────────

class _DailyChartWidget extends StatefulWidget {
  final List<ChartDataPoint> chartData;

  const _DailyChartWidget({required this.chartData});

  @override
  State<_DailyChartWidget> createState() => _DailyChartWidgetState();
}

class _DailyChartWidgetState extends State<_DailyChartWidget> {

  @override
  Widget build(BuildContext context) {
    final spots = widget.chartData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    final minY = widget.chartData
        .map((p) => p.value)
        .reduce((a, b) => a < b ? a : b);
    final maxY = widget.chartData
        .map((p) => p.value)
        .reduce((a, b) => a > b ? a : b);
    final yPadding = (maxY - minY) * 0.15;
    final effectiveMin = (minY - yPadding).clamp(0, double.infinity).toDouble();
    final effectiveMax = maxY + yPadding;

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(12, 20, 16, 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: LineChart(
        LineChartData(
          minY: effectiveMin,
          maxY: effectiveMax,
          clipData: const FlClipData.all(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (effectiveMax - effectiveMin) / 3,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.white.withValues(alpha: 0.04),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: _calcLabelInterval(widget.chartData.length),
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= widget.chartData.length) {
                    return const SizedBox.shrink();
                  }
                  final point = widget.chartData[idx];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('d MMM', 'tr_TR').format(point.date),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            getTouchedSpotIndicator: (barData, spotIndexes) {
              return spotIndexes.map((i) {
                return TouchedSpotIndicatorData(
                  FlLine(
                    color: AppTheme.gold.withValues(alpha: 0.4),
                    strokeWidth: 1.5,
                    dashArray: [4, 4],
                  ),
                  FlDotData(
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                          radius: 5,
                          color: AppTheme.gold,
                          strokeWidth: 2,
                          strokeColor: AppTheme.background,
                        ),
                  ),
                );
              }).toList();
            },
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppTheme.surface.withValues(alpha: 0.95),
              tooltipBorderRadius: BorderRadius.circular(12),
              tooltipBorder: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (spots) {
                return spots.map((spot) {
                  final idx = spot.spotIndex;
                  final point = widget.chartData[idx];
                  final formatter = NumberFormat('#,##0.00', 'tr_TR');

                  String deltaText = '';
                  Color deltaColor = Colors.white.withValues(alpha: 0.5);
                  if (idx > 0) {
                    final prev = widget.chartData[idx - 1].value;
                    final delta = point.value - prev;
                    final pct = prev > 0 ? (delta / prev) * 100 : 0.0;
                    final sign = delta >= 0 ? '+' : '';
                    deltaText =
                        '\n$sign₺${formatter.format(delta)} ($sign${pct.toStringAsFixed(2)}%)';
                    deltaColor = delta >= 0
                        ? const Color(0xFF34D399)
                        : const Color(0xFFEF4444);
                  }

                  return LineTooltipItem(
                    '₺${formatter.format(point.value)}',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      if (deltaText.isNotEmpty)
                        TextSpan(
                          text: deltaText,
                          style: TextStyle(
                            color: deltaColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      TextSpan(
                        text:
                            '\n${DateFormat('d MMMM', 'tr_TR').format(point.date)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: AppTheme.gold,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                      radius: 3.5,
                      color: AppTheme.gold,
                      strokeWidth: 1.5,
                      strokeColor: AppTheme.background,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.gold.withValues(alpha: 0.25),
                    AppTheme.gold.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 150.ms, duration: 500.ms);
  }

  double _calcLabelInterval(int count) {
    if (count <= 7) return 1;
    if (count <= 14) return 2;
    if (count <= 30) return 5;
    return (count / 6).ceilToDouble();
  }
}

// ─────────────────────────────────────────────
// Daily Change List
// ─────────────────────────────────────────────

class _DailyChangeList extends StatelessWidget {
  final List<ChartDataPoint> chartData;

  const _DailyChangeList({required this.chartData});

  @override
  Widget build(BuildContext context) {
    // Show last 7 days (reversed: newest first), skip if no previous day
    final displayData = chartData.reversed
        .take(7)
        .toList();

    return Column(
      children: displayData.asMap().entries.map((entry) {
        final idx = entry.key;
        final point = entry.value;

        // Find previous day index in original (sorted) list
        final originalIdx = chartData.indexOf(point);
        final hasPrev = originalIdx > 0;
        final prevValue = hasPrev ? chartData[originalIdx - 1].value : null;

        return _DailyChangeRow(
          point: point,
          prevValue: prevValue,
          animIndex: idx,
        );
      }).toList(),
    );
  }
}

class _DailyChangeRow extends StatelessWidget {
  final ChartDataPoint point;
  final double? prevValue;
  final int animIndex;

  const _DailyChangeRow({
    required this.point,
    required this.prevValue,
    required this.animIndex,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00', 'tr_TR');
    final isToday = _isToday(point.date);
    final isYesterday = _isYesterday(point.date);

    double? delta;
    double? pct;
    if (prevValue != null) {
      delta = point.value - prevValue!;
      pct = prevValue! > 0 ? (delta / prevValue!) * 100 : 0.0;
    }

    final isPositive = delta == null || delta >= 0;
    final deltaColor = delta == null
        ? Colors.white.withValues(alpha: 0.3)
        : (isPositive ? const Color(0xFF34D399) : const Color(0xFFEF4444));

    final dateLabel = isToday
        ? 'Bugün'
        : isYesterday
            ? 'Dün'
            : DateFormat('d MMMM', 'tr_TR').format(point.date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isToday
                ? AppTheme.gold.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            // Date indicator
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isToday
                    ? AppTheme.gold.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isToday ? Iconsax.calendar_tick : Iconsax.calendar_1,
                size: 16,
                color: isToday
                    ? AppTheme.gold
                    : Colors.white.withValues(alpha: 0.35),
              ),
            ),
            const Gap(12),

            // Date text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateLabel,
                    style: TextStyle(
                      color: isToday
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    DateFormat('EEEE', 'tr_TR').format(point.date),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Values
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₺${formatter.format(point.value)}',
                  style: const TextStyle(
                    fontFeatures: [FontFeature.tabularFigures()],
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.3,
                  ),
                ),
                const Gap(3),
                if (delta != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: deltaColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          delta >= 0
                              ? Iconsax.arrow_up_3
                              : Iconsax.arrow_down_2,
                          size: 10,
                          color: deltaColor,
                        ),
                        const Gap(3),
                        Text(
                          '${delta >= 0 ? '+' : ''}₺${formatter.format(delta.abs())}',
                          style: TextStyle(
                            fontFeatures: const [FontFeature.tabularFigures()],
                            color: deltaColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          '(${pct! >= 0 ? '+' : ''}${pct.toStringAsFixed(2)}%)',
                          style: TextStyle(
                            color: deltaColor.withValues(alpha: 0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    'Başlangıç',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.25),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
      delay: Duration(milliseconds: 200 + (animIndex * 60)),
      duration: 350.ms,
    ).slideX(begin: 0.03, end: 0, curve: Curves.easeOutCubic);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }
}

// ─────────────────────────────────────────────
// Allocation strip (Gold vs Forex)
// ─────────────────────────────────────────────

class _AllocationStrip extends StatelessWidget {
  final _AllocationData allocation;

  const _AllocationStrip({required this.allocation});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00', 'tr_TR');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          // Progress bar
          SizedBox(
            height: 8,
            child: Row(
              children: [
                if (allocation.goldValue > 0)
                  Expanded(
                    flex: allocation.goldPercent.round().clamp(1, 100),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                if (allocation.goldValue > 0 && allocation.forexValue > 0)
                  const Gap(4),
                if (allocation.forexValue > 0)
                  Expanded(
                    flex: allocation.forexPercent.round().clamp(1, 100),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF60A5FA),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Gap(16),
          // Labels
          Row(
            children: [
              Expanded(
                child: _AllocationLabel(
                  label: 'Altın',
                  value: '₺${formatter.format(allocation.goldValue)}',
                  percentage: '%${allocation.goldPercent.toStringAsFixed(0)}',
                  color: AppTheme.gold,
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              Expanded(
                child: _AllocationLabel(
                  label: 'Döviz',
                  value: '₺${formatter.format(allocation.forexValue)}',
                  percentage: '%${allocation.forexPercent.toStringAsFixed(0)}',
                  color: const Color(0xFF60A5FA),
                  isRight: true,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }
}

class _AllocationLabel extends StatelessWidget {
  final String label;
  final String value;
  final String percentage;
  final Color color;
  final bool isRight;

  const _AllocationLabel({
    required this.label,
    required this.value,
    required this.percentage,
    required this.color,
    this.isRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isRight ? 20 : 0,
        right: isRight ? 0 : 20,
      ),
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
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const Gap(8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Gap(6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                percentage,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontWeight: FontWeight.w400,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Asset row
// ─────────────────────────────────────────────

class _AssetRow extends StatelessWidget {
  final _BreakdownItem item;
  final int index;
  final double maxValue;

  const _AssetRow({
    required this.item,
    required this.index,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final barFraction = maxValue > 0 ? item.value / maxValue : 0.0;
    final formatter = NumberFormat('#,##0.00', 'tr_TR');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Color dot
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: item.color.withValues(alpha: 0.35),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                // Name + type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(2),
                      Text(
                        item.type,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Value + percentage
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₺${formatter.format(item.value)}',
                      style: const TextStyle(
                        fontFeatures: [FontFeature.tabularFigures()],
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Gap(2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '%${item.percentage.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: item.color,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Gap(10),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                height: 3,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Container(
                          width: constraints.maxWidth,
                          color: Colors.white.withValues(alpha: 0.04),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          width: constraints.maxWidth * barFraction,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                item.color.withValues(alpha: 0.6),
                                item.color,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
      delay: Duration(milliseconds: 150 + (index * 50)),
      duration: 350.ms,
    ).slideX(begin: 0.03, end: 0, curve: Curves.easeOutCubic);
  }
}

// ─────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.gold.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.wallet_money,
              color: AppTheme.gold.withValues(alpha: 0.6),
              size: 32,
            ),
          ),
          const Gap(16),
          const Text(
            'Henüz Varlık Yok',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
          const Gap(8),
          Text(
            'Varlık eklediğinizde portföy dağılımınız\nburada görüntülenecek.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Privacy blur wrapper
// ─────────────────────────────────────────────

class _PrivacyBlur extends ConsumerWidget {
  final bool enabled;
  final Widget child;

  const _PrivacyBlur({required this.enabled, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!enabled) return child;
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 6.6, sigmaY: 6.6),
      child: AbsorbPointer(child: child),
    );
  }
}
