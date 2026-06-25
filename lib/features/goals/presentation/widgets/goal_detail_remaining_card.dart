import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';

/// Card showing the remaining target budget amount for a goal.
class GoalDetailRemainingCard extends StatelessWidget {
  final double remainingAmount;
  final NumberFormat formatter;

  const GoalDetailRemainingCard({
    super.key,
    required this.remainingAmount,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
              color: Colors.amber.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KALAN TUTAR',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
              const Gap(4),
              Text(
                '₺${formatter.format(remainingAmount)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
