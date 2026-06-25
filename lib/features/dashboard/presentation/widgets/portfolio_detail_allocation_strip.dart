import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/dashboard/presentation/widgets/portfolio_detail_models.dart';

/// Progress bar showing the balance distribution between Gold and Foreign currencies.
class PortfolioDetailAllocationStrip extends StatelessWidget {
  final PortfolioAllocationData allocation;

  const PortfolioDetailAllocationStrip({super.key, required this.allocation});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00', 'tr_TR');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          // Progress bar
          SizedBox(
            height: 8,
            child: Row(
              children: [
                if (allocation.goldValue > 0)
                  Expanded(
                    flex: allocation.goldPercent.round().clamp(1, 100),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                if (allocation.goldValue > 0 && allocation.forexValue > 0)
                  const Gap(4),
                if (allocation.forexValue > 0)
                  Expanded(
                    flex: allocation.forexPercent.round().clamp(1, 100),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF60A5FA),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Gap(16),
          // Labels
          Row(
            children: [
              Expanded(
                child: _AllocationLabel(
                  label: 'Altın',
                  value: '₺${formatter.format(allocation.goldValue)}',
                  percentage: '%${allocation.goldPercent.toStringAsFixed(0)}',
                  color: AppTheme.gold,
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              Expanded(
                child: _AllocationLabel(
                  label: 'Döviz',
                  value: '₺${formatter.format(allocation.forexValue)}',
                  percentage: '%${allocation.forexPercent.toStringAsFixed(0)}',
                  color: const Color(0xFF60A5FA),
                  isRight: true,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }
}

class _AllocationLabel extends StatelessWidget {
  final String label;
  final String value;
  final String percentage;
  final Color color;
  final bool isRight;

  const _AllocationLabel({
    required this.label,
    required this.value,
    required this.percentage,
    required this.color,
    this.isRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isRight ? 20 : 0,
        right: isRight ? 0 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const Gap(8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Gap(6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                percentage,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontWeight: FontWeight.w400,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
