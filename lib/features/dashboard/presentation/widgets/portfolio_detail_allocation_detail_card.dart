import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/dashboard/presentation/widgets/portfolio_detail_models.dart';

/// Card showing numerical details of Gold, Forex, and Total portfolio worth.
class PortfolioDetailAllocationDetailCard extends StatelessWidget {
  final PortfolioAllocationData allocation;

  const PortfolioDetailAllocationDetailCard({super.key, required this.allocation});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00', 'tr_TR');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detay',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
            ),
          ),
          const Gap(16),
          _AllocationDetailRow(
            label: 'Altın',
            value: '₺${formatter.format(allocation.goldValue)}',
            percent: '%${allocation.goldPercent.toStringAsFixed(1)}',
            color: AppTheme.gold,
          ),
          const Gap(12),
          _AllocationDetailRow(
            label: 'Döviz',
            value: '₺${formatter.format(allocation.forexValue)}',
            percent: '%${allocation.forexPercent.toStringAsFixed(1)}',
            color: const Color(0xFF60A5FA),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white12, height: 1),
          ),
          _AllocationDetailRow(
            label: 'Toplam',
            value: '₺${formatter.format(allocation.total)}',
            percent: '%100',
            color: Colors.white,
            isBold: true,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }
}

class _AllocationDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final String percent;
  final Color color;
  final bool isBold;

  const _AllocationDetailRow({
    required this.label,
    required this.value,
    required this.percent,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const Gap(10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isBold ? Colors.white : Colors.white.withValues(alpha: 0.7),
              fontSize: isBold ? 14 : 13,
              fontWeight: isBold ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          percent,
          style: TextStyle(
            color: color.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        const Gap(16),
        Text(
          value,
          style: TextStyle(
            fontFeatures: const [FontFeature.tabularFigures()],
            color: isBold ? Colors.white : Colors.white.withValues(alpha: 0.9),
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.w500 : FontWeight.w400,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}
