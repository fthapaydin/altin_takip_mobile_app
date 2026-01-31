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

    // Find min/max values for scaling and highlighting
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

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
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
                color: Colors.white.withOpacity(0.3),
                strokeWidth: 1,
                dashArray: [5, 5],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(right: 5, bottom: 2),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
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
            curveSmoothness: 0.3,
            color: AppTheme.gold,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                // Highlight Min/Max
                if (index == minIndex || index == maxIndex) {
                  final isMax = index == maxIndex;
                  return FlDotCirclePainter(
                    radius: 5, // Larger radius
                    color: isMax
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFE57373), // Green for Max, Red for Low
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                }
                // Default dots
                return FlDotCirclePainter(
                  radius: 3,
                  color: AppTheme.gold,
                  strokeWidth: 1.5,
                  strokeColor: Colors.black,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.gold.withOpacity(0.15),
                  AppTheme.gold.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            tooltipPadding: const EdgeInsets.all(8),
            // tooltipBgColor -> Use getTooltipColor in newer versions or check version
            // Assuming latest fl_chart uses getTooltipColor callback or just color property
            getTooltipColor: (_) => const Color(0xFF2A2A2A),
            tooltipBorder: BorderSide(
              color: AppTheme.gold.withOpacity(0.5),
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
                  const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: '₺$valueStr',
                      style: const TextStyle(
                        color: AppTheme.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
          getTouchedSpotIndicator:
              (LineChartBarData barData, List<int> spotIndexes) {
                return spotIndexes.map((spotIndex) {
                  return TouchedSpotIndicatorData(
                    FlLine(
                      color: AppTheme.gold.withOpacity(0.5),
                      strokeWidth: 1,
                    ),
                    FlDotData(
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.gold,
                          strokeWidth: 2,
                          strokeColor: Colors.black,
                        );
                      },
                    ),
                  );
                }).toList();
              },
        ),
      ),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
    );
  }
}
