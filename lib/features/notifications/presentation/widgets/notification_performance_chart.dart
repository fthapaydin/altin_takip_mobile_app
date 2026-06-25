import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/dashboard/presentation/widgets/portfolio_chart.dart';
import 'package:altin_takip/features/dashboard/domain/dashboard_models.dart';

/// Performance chart panel shown in notification details, fully redesigned with glassmorphism.
class NotificationPerformanceChart extends StatelessWidget {
  final List<ChartDataPoint> chartDataPoints;
  final double currentValue;
  final double changeAmount;
  final double changePercentage;

  const NotificationPerformanceChart({
    super.key,
    required this.chartDataPoints,
    required this.currentValue,
    required this.changeAmount,
    required this.changePercentage,
  });

  @override
  Widget build(BuildContext context) {
    if (chartDataPoints.isEmpty) return const SizedBox.shrink();

    final isPositive = changePercentage >= 0;
    final trendColor = isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PERFORMANS ANALİZİ',
          style: GoogleFonts.ubuntu(
            color: AppTheme.gold.withValues(alpha: 0.8),
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
          ),
        ),
        const Gap(16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                offset: const Offset(0, 16),
                blurRadius: 32,
                spreadRadius: -8,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PORTFÖY DEĞERİ',
                              style: GoogleFonts.ubuntu(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              '₺${NumberFormat('#,##0.00', 'tr_TR').format(currentValue)}',
                              style: GoogleFonts.ubuntu(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: trendColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: trendColor.withValues(alpha: 0.15),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${isPositive ? '+' : ''}${NumberFormat('#,##0.00', 'tr_TR').format(changeAmount)}',
                                style: GoogleFonts.ubuntu(
                                  color: trendColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                              const Gap(6),
                              Text(
                                '(%${changePercentage.toStringAsFixed(2)})',
                                style: GoogleFonts.ubuntu(
                                  color: trendColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Gap(24),
                    SizedBox(
                      height: 200,
                      child: PortfolioChart(
                        chartData: chartDataPoints,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
