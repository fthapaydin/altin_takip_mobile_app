import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:altin_takip/core/theme/app_theme.dart';

/// Top summary card displaying portfolio balance, total investment, profit/loss, and yield rate.
class PortfolioHeroBalanceCard extends StatelessWidget {
  final double totalWorth;
  final double totalCost;
  final double profitLoss;
  final double profitPercentage;

  const PortfolioHeroBalanceCard({
    super.key,
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
