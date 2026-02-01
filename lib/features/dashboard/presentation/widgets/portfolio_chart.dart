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
                color: Colors.white.withValues(alpha: 0.3),
                strokeWidth: 1,
                dashArray: [5, 5],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(right: 5, bottom: 2),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
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
            curveSmoothness: 0.35,
            // Use gradient for the line
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFDD835), // Brighter Gold
                AppTheme.gold, // Standard Gold
                Color(0xFFFFA000), // Darker Amber
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                // Highlight Min/Max with a "Ring" style
                if (index == minIndex || index == maxIndex) {
                  final isMax = index == maxIndex;
                  final color = isMax
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFEF5350); // Green/Red
                  return FlDotCirclePainter(
                    radius: 6,
                    color: AppTheme.background, // Hollow center (matches bg)
                    strokeWidth: 3,
                    strokeColor: color,
                  );
                }
                // Hide other dots for a cleaner look
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
                  AppTheme.gold.withValues(alpha: 0.25),
                  AppTheme.gold.withValues(alpha: 0.1),
                  AppTheme.gold.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          getTouchedSpotIndicator:
              (LineChartBarData barData, List<int> spotIndexes) {
                return spotIndexes.map((spotIndex) {
                  return TouchedSpotIndicatorData(
                    FlLine(
                      color: AppTheme.gold.withValues(alpha: 0.5),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                    FlDotData(
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 6,
                          color: AppTheme.gold,
                          strokeWidth: 3,
                          strokeColor: Colors.white,
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
                const Color(0xFF2A2A2A).withValues(alpha: 0.9),

            tooltipBorder: BorderSide(
              color: AppTheme.gold.withValues(alpha: 0.3),
              width: 1,
            ),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final index = touchedSpot.x.toInt();
                if (index < 0 || index >= chartData.length) return null;

                final data = chartData[index];
                final dateStr = DateFormat('d MMM', 'tr_TR').format(data.date);
                final valueStr = NumberFormat(
                  '#,##0.00',
                  'tr_TR',
                ).format(data.value);

                return LineTooltipItem(
                  '$dateStr\n',
                  TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                  children: [
                    TextSpan(
                      text: '₺$valueStr',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
      ),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }
}
