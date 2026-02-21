import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/goals/domain/goal.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';

class GoalInsightsCard extends StatelessWidget {
  final GoalInsights insights;

  const GoalInsightsCard({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0', 'tr_TR');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AKILLI ÖNERİLER',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 10,
            letterSpacing: 1.5,
          ),
        ),
        const Gap(12),
        // Insights grid
        Row(
          children: [
            Expanded(
              child: _InsightTile(
                icon: Iconsax.calendar_tick,
                label: 'Aylık Gereksinim',
                value: insights.monthlyRequired != null
                    ? '₺${formatter.format(insights.monthlyRequired)}'
                    : '—',
                color: AppTheme.gold,
              ),
            ),
            const Gap(10),
            Expanded(
              child: _InsightTile(
                icon: Iconsax.timer_1,
                label: 'Tahmini Süre',
                value: insights.estimatedCompletionMonths != null
                    ? '${insights.estimatedCompletionMonths} ay'
                    : '—',
                color: const Color(0xFF4C82F7),
              ),
            ),
          ],
        ),
        const Gap(10),
        _InsightTile(
          icon: Iconsax.clock,
          label: 'Kalan Süre',
          value: insights.remainingMonths != null
              ? '${insights.remainingMonths} ay'
              : '—',
          color: const Color(0xFF34D399),
          fullWidth: true,
        ),
        const Gap(16),
        // Motivation message
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.gold.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.gold.withValues(alpha: 0.1)),
          ),
          child: Text(
            insights.message,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }
}

class _InsightTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool fullWidth;

  const _InsightTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 11, color: color.withValues(alpha: 0.7)),
                    const Gap(4),
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
