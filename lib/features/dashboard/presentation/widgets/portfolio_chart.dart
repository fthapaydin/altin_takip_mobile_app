import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/dashboard/domain/dashboard_models.dart';

/// Semi-transparent portfolio value chart widget
class PortfolioChart extends StatelessWidget {
  final List<ChartDataPoint> chartData;
  final double? totalCost;

  const PortfolioChart({super.key, required this.chartData, this.totalCost});

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return const SizedBox.shrink();
    }

    final values = chartData.map((e) => e.value).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    // Identify indices for min/max to highlight dots
    final minIndex = values.indexOf(minValue);
    final maxIndex = values.indexOf(maxValue);

    // Calculate Y range padding
    final range = maxValue - minValue;
    final padding = range == 0 ? 100.0 : range * 0.15; // 15% padding

    // Ensure cost line is visible if provided
    double effectiveMinY = minValue;
    double effectiveMaxY = maxValue;

    if (totalCost != null && totalCost! > 0) {
      if (totalCost! < effectiveMinY) effectiveMinY = totalCost!;
      if (totalCost! > effectiveMaxY) effectiveMaxY = totalCost!;
    }

    final totalVerticalRange =
        (effectiveMaxY + padding) - (effectiveMinY - padding);
    final verticalInterval = totalVerticalRange == 0
        ? 1.0
        : totalVerticalRange / 2.5;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: verticalInterval,
              getTitlesWidget: (value, meta) {
                if (value <= (effectiveMinY - padding) ||
                    value >= (effectiveMaxY + padding)) {
                  return const SizedBox.shrink(); // Don't show labels at absolute edges if strict
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    NumberFormat.compact(locale: 'tr_TR').format(value),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: (chartData.length / 4).ceilToDouble(), // Show ~4 labels
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= chartData.length) {
                  return const SizedBox.shrink();
                }

                final label = chartData[index].label;
                if (label == null || label.isEmpty)
                  return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (chartData.length - 1).toDouble(),
        minY: effectiveMinY - padding,
        maxY: effectiveMaxY + padding,
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            if (totalCost != null && totalCost! > 0)
              HorizontalLine(
                y: totalCost!,
                color: Colors.white.withValues(alpha: 0.2),
                strokeWidth: 1,
                dashArray: [4, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(right: 5, bottom: 2),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.2),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                  labelResolver: (line) => 'MALİYET',
                ),
              ),
          ],
        ),
        lineBarsData: [
          LineChartBarData(
            spots: chartData.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.value);
            }).toList(),
            isCurved: true,
            curveSmoothness: 0.4,
            color: const Color(0xFFFFD700),
            barWidth: 2,
            isStrokeCapRound: true,
            shadow: Shadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                if (index == minIndex || index == maxIndex) {
                  final isMax = index == maxIndex;
                  return FlDotCirclePainter(
                    radius: isMax ? 6 : 4, // Make max slightly larger
                    color: isMax ? Colors.white : AppTheme.background,
                    strokeWidth: 2,
                    strokeColor: isMax
                        ? AppTheme.gold
                        : Colors.white.withValues(alpha: 0.5),
                  );
                }
                return FlDotCirclePainter(
                  radius: 0,
                  color: Colors.transparent,
                  strokeWidth: 0,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFFFD700).withValues(alpha: 0.15),
                  const Color(0xFFFFD700).withValues(alpha: 0.0),
                ],
                stops: const [0, 0.8],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchSpotThreshold: 50, // Increase touch area
          distanceCalculator: (Offset touchPoint, Offset spotPixelPoint) {
            // Only consider horizontal distance for stickiness
            return (touchPoint.dx - spotPixelPoint.dx).abs();
          },
          getTouchedSpotIndicator:
              (LineChartBarData barData, List<int> spotIndexes) {
                return spotIndexes.map((spotIndex) {
                  return TouchedSpotIndicatorData(
                    FlLine(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                    FlDotData(
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 6,
                          color: const Color(0xFF1E1E1E),
                          strokeWidth: 3,
                          strokeColor: const Color(0xFFFFD700),
                        );
                      },
                    ),
                  );
                }).toList();
              },
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            getTooltipColor: (_) =>
                const Color(0xFF252525).withValues(alpha: 0.95),
            tooltipBorder: BorderSide(
              color: const Color(0xFFFFD700).withValues(alpha: 0.2),
              width: 1,
            ),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final index = touchedSpot.x.toInt();
                if (index < 0 || index >= chartData.length) return null;

                final data = chartData[index];
                final dateStr = DateFormat('d MMMM', 'tr_TR').format(data.date);
                final valueStr = NumberFormat(
                  '#,##0.00',
                  'tr_TR',
                ).format(data.value);

                return LineTooltipItem(
                  '$dateStr\n',
                  TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: '₺$valueStr',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }
}
