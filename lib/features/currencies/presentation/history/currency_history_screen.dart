import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/currencies/presentation/history/currency_history_providers.dart';
import 'package:altin_takip/features/currencies/domain/currency_history.dart';
import 'package:altin_takip/features/currencies/domain/currency_history_data.dart';
import 'package:altin_takip/features/assets/domain/asset.dart'; // Added for Asset type
import 'package:intl/intl.dart';
import 'package:altin_takip/core/widgets/premium_error_view.dart';
import 'package:altin_takip/features/assets/presentation/add_asset_screen.dart';

class CurrencyHistoryScreen extends ConsumerStatefulWidget {
  final String currencyCode;
  final String currencyId;
  final String currencyName;
  final bool isGold;

  const CurrencyHistoryScreen({
    super.key,
    required this.currencyCode,
    required this.currencyId,
    required this.currencyName,
    required this.isGold,
  });

  @override
  ConsumerState<CurrencyHistoryScreen> createState() =>
      _CurrencyHistoryScreenState();
}

class _CurrencyHistoryScreenState extends ConsumerState<CurrencyHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(currencyHistoryProvider(widget.currencyId));
    final selectedRange =
        ref.watch(currencyHistoryRangeProvider)[widget.currencyId] ?? '1w';

    print(
      'DEBUG: CurrencyHistoryScreen ref.watch historyAsync for ${widget.currencyCode} (ID: ${widget.currencyId}): $historyAsync',
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              widget.currencyName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: historyAsync.when(
              data: (data) => _buildContent(data, selectedRange),
              loading: () => _buildLoading(),
              error: (error, stack) => PremiumErrorView(
                message: error.toString(),
                onRetry: () =>
                    ref.refresh(currencyHistoryProvider(widget.currencyId)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.05),
      highlightColor: Colors.white.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const Gap(8),
                    Container(
                      width: 80,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
            const Gap(20),
            // Chart Area
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const Gap(16),
            // Range Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return Container(
                  width: 40,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                );
              }),
            ),
            const Gap(16),
            // Transactions List
            Expanded(
              flex: 2,
              child: Column(
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(CurrencyHistoryData data, String selectedRange) {
    if (data.history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Icon(
                Icons.ssid_chart_rounded,
                size: 48,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            const Gap(24),
            Text(
              'Grafik Verisi Yok',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const Gap(8),
            Text(
              'Bu varlık için henüz fiyat geçmişi\noluşmamış.Daha sonra tekrar deneyebilirsin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    // Sort by date just in case
    // We create a copy to avoid mutating the provider state if it's cached reference
    final sortedHistory = List<CurrencyHistory>.from(data.history);
    sortedHistory.sort((a, b) => a.date.compareTo(b.date));

    final lastItem = sortedHistory.last;
    final firstItem = sortedHistory.first;
    final change = lastItem.buying - firstItem.buying;
    final percentage = (change / firstItem.buying) * 100;
    final isPositive = change >= 0;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildPriceItem('Alış', lastItem.buying),
                      const Gap(24),
                      _buildPriceItem('Satış', lastItem.selling),
                    ],
                  ),
                  const Gap(8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (isPositive ? Colors.green : Colors.red)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPositive
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              size: 14,
                              color: isPositive ? Colors.green : Colors.red,
                            ),
                            const Gap(4),
                            Text(
                              '%${percentage.abs().toStringAsFixed(2)}',
                              style: TextStyle(
                                color: isPositive ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(8),
                      Text(
                        'Son güncelleme: ${lastItem.date.hour == 0 && lastItem.date.minute == 0 ? DateFormat('dd.MM.yyyy').format(lastItem.date) : DateFormat('HH:mm').format(lastItem.date)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const Gap(20),
          // Chart
          Expanded(flex: 3, child: _buildChart(sortedHistory)),
          const Gap(16),
          // Range Selector
          _buildRangeSelector(selectedRange),
          const Gap(16),
          // Transactions List
          if (data.userAssets.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Geçmiş İşlemlerim',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Gap(16),
            Expanded(flex: 2, child: _buildTransactionsList(data.userAssets)),
          ] else
            Expanded(flex: 2, child: _buildEmptyTransactionsState()),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(List<Asset> assets) {
    // Sort transactions by date descending
    final sortedAssets = List<Asset>.from(assets);
    sortedAssets.sort((a, b) => b.date.compareTo(a.date));

    return ListView.separated(
      itemCount: sortedAssets.length,
      separatorBuilder: (context, index) => const Gap(12),
      itemBuilder: (context, index) {
        final asset = sortedAssets[index];
        final isBuy = asset.type == 'buy';

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isBuy ? Colors.green : Colors.red).withValues(
                    alpha: 0.1,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isBuy ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isBuy ? Colors.green : Colors.red,
                  size: 20,
                ),
              ),
              const Gap(12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBuy ? 'Alış' : 'Satış',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    DateFormat('dd.MM.yyyy').format(asset.date),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${NumberFormat('#,##0.###', 'tr_TR').format(asset.amount)} adet',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '₺${NumberFormat('#,##0.00', 'tr_TR').format(asset.price)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChart(List<CurrencyHistory> history) {
    final spots = history
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.buying))
        .toList();

    // Prevent crash if history is empty (handled above but safe check)
    if (history.isEmpty) return const SizedBox();

    // Calculate Y range
    double minY = history.map((e) => e.buying).reduce((a, b) => a < b ? a : b);
    double maxY = history.map((e) => e.buying).reduce((a, b) => a > b ? a : b);

    minY = minY * 0.999;
    maxY = maxY * 1.001;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white.withValues(alpha: 0.05),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: widget.isGold ? AppTheme.gold : const Color(0xFF64B5F6),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  (widget.isGold ? AppTheme.gold : const Color(0xFF64B5F6))
                      .withValues(alpha: 0.3),
                  (widget.isGold ? AppTheme.gold : const Color(0xFF64B5F6))
                      .withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true, // Added for safety
            getTooltipColor: (_) => AppTheme.surface,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index < 0 || index >= history.length) return null;
                final date = history[index].date;
                return LineTooltipItem(
                  '₺${NumberFormat('#,##0.00', 'tr_TR').format(spot.y)}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: date.hour == 0 && date.minute == 0
                          ? DateFormat('dd.MM.yyyy').format(date)
                          : DateFormat('dd.MM HH:mm').format(date),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRangeSelector(String selectedRange) {
    final ranges = ['1d', '1w', '1m', '3m', '1y', 'all'];
    final labels = {
      '1d': '1G',
      '1w': '1H',
      '1m': '1A',
      '3m': '3A',
      '1y': '1Y',
      'all': 'Tümü',
    };

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: ranges.map((range) {
          final isSelected = range == selectedRange;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                ref
                    .read(currencyHistoryRangeProvider.notifier)
                    .setRange(widget.currencyId, range);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (widget.isGold ? AppTheme.gold : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    labels[range]!,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white54,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyTransactionsState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.history_toggle_off_rounded,
            size: 32,
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        const Gap(16),
        Text(
          'İşlem Geçmişi Yok',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(4),
        Text(
          'Bu varlık için henüz işlem kaydınız bulunmuyor.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        const Gap(24),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AddAssetScreen(initialCurrencyCode: widget.currencyCode),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            foregroundColor: AppTheme.gold,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_circle_outline_rounded, size: 18),
              Gap(8),
              Text('İşlem Ekle'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceItem(String label, double price) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Gap(4),
        Text(
          '₺${NumberFormat('#,##0.00', 'tr_TR').format(price)}',
          style: TextStyle(
            color: widget.isGold ? AppTheme.gold : Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
