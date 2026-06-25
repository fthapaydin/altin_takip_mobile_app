import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/currencies/domain/currency_history.dart';

/// Line chart rendering historical values of a selected currency.
class CurrencyHistoryChart extends StatelessWidget {
  final List<CurrencyHistory> history;
  final bool isGold;

  const CurrencyHistoryChart({
    super.key,
    required this.history,
    required this.isGold,
  });

  @override
  Widget build(BuildContext context) {
    final spots = history
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.buying))
        .toList();

    if (history.isEmpty) return const SizedBox();

    double minY = history.map((e) => e.buying).reduce((a, b) => a < b ? a : b);
    double maxY = history.map((e) => e.buying).reduce((a, b) => a > b ? a : b);

    minY = minY * 0.999;
    maxY = maxY * 1.001;

    final themeColor = isGold ? AppTheme.gold : const Color(0xFF64B5F6);

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
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: themeColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  themeColor.withValues(alpha: 0.3),
                  themeColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
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
                    fontWeight: FontWeight.w400,
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
}
