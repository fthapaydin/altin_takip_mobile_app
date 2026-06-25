import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/dashboard/domain/dashboard_models.dart';

/// List displaying portfolio daily value changes for the last 7 days.
class PortfolioDetailChangeList extends StatelessWidget {
  final List<ChartDataPoint> chartData;

  const PortfolioDetailChangeList({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    final displayData = chartData.reversed.take(7).toList();

    return Column(
      children: displayData.asMap().entries.map((entry) {
        final idx = entry.key;
        final point = entry.value;

        final originalIdx = chartData.indexOf(point);
        final hasPrev = originalIdx > 0;
        final prevValue = hasPrev ? chartData[originalIdx - 1].value : null;

        return PortfolioDetailChangeRow(
          point: point,
          prevValue: prevValue,
          animIndex: idx,
        );
      }).toList(),
    );
  }
}

/// A row showing a single day's value and change compared to the previous day.
class PortfolioDetailChangeRow extends StatelessWidget {
  final ChartDataPoint point;
  final double? prevValue;
  final int animIndex;

  const PortfolioDetailChangeRow({
    super.key,
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
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isToday ? AppTheme.gold.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isToday ? Iconsax.calendar_tick : Iconsax.calendar_1,
                size: 16,
                color: isToday ? AppTheme.gold : Colors.white.withValues(alpha: 0.35),
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateLabel,
                    style: TextStyle(
                      color: isToday ? Colors.white : Colors.white.withValues(alpha: 0.7),
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
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: deltaColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          delta >= 0 ? Iconsax.arrow_up_3 : Iconsax.arrow_down_2,
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
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }
}
