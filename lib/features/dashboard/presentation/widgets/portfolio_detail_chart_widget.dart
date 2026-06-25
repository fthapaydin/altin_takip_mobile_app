import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/dashboard/domain/dashboard_models.dart';

/// Interative line chart showing daily portfolio value changes.
class PortfolioDetailChartWidget extends StatefulWidget {
  final List<ChartDataPoint> chartData;

  const PortfolioDetailChartWidget({super.key, required this.chartData});

  @override
  State<PortfolioDetailChartWidget> createState() => _PortfolioDetailChartWidgetState();
}

class _PortfolioDetailChartWidgetState extends State<PortfolioDetailChartWidget> {
  @override
  Widget build(BuildContext context) {
    final spots = widget.chartData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    final values = widget.chartData.map((p) => p.value).toList();
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final yPadding = (maxY - minY) * 0.15;
    final effectiveMin = (minY - yPadding).clamp(0, double.infinity).toDouble();
    final effectiveMax = (maxY + yPadding).toDouble();

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
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
              tooltipBorder: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
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
                    deltaText = '\n$sign₺${formatter.format(delta)} ($sign${pct.toStringAsFixed(2)}%)';
                    deltaColor = delta >= 0 ? const Color(0xFF34D399) : const Color(0xFFEF4444);
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
                        text: '\n${DateFormat('d MMMM', 'tr_TR').format(point.date)}',
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
