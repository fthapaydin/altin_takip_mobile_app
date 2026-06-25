import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/goals/domain/goal.dart';

/// Card containing primary parameters of a goal, such as current, target, priority, status, and target date.
class GoalDetailInfoCard extends StatelessWidget {
  final Goal goal;
  final double currentValue;
  final double targetAmount;
  final NumberFormat formatter;

  const GoalDetailInfoCard({
    super.key,
    required this.goal,
    required this.currentValue,
    required this.targetAmount,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = switch (goal.priority) {
      GoalPriority.high => Colors.red,
      GoalPriority.medium => Colors.amber,
      GoalPriority.low => const Color(0xFF34D399),
    };

    final statusColor = switch (goal.status) {
      GoalStatus.active => const Color(0xFF34D399),
      GoalStatus.completed => const Color(0xFF34D399),
      GoalStatus.paused => Colors.amber,
      GoalStatus.cancelled => Colors.red,
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'MEVCUT',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 8,
                          letterSpacing: 1,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        '₺${formatter.format(currentValue)}',
                        style: const TextStyle(
                          color: AppTheme.gold,
                          fontSize: 18,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'HEDEF',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 8,
                          letterSpacing: 1,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        '₺${formatter.format(targetAmount)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 18,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.04)),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _GoalInfoCell(
                    label: 'KATEGORİ',
                    value: goal.category.displayName,
                    icon: Iconsax.category,
                    color: AppTheme.gold,
                  ),
                ),
                Container(
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
                Expanded(
                  child: _GoalInfoCell(
                    label: 'ÖNCELİK',
                    value: goal.priority.displayName,
                    icon: Iconsax.flag,
                    color: priorityColor,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.04)),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _GoalInfoCell(
                    label: 'DURUM',
                    value: goal.status.displayName,
                    icon: Iconsax.tick_circle,
                    color: statusColor,
                  ),
                ),
                Container(
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
                Expanded(
                  child: _GoalInfoCell(
                    label: 'HEDEF TARİH',
                    value: goal.targetDate != null
                        ? DateFormat('d MMM yyyy', 'tr_TR').format(goal.targetDate!)
                        : '—',
                    icon: Iconsax.calendar_1,
                    color: Colors.white,
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

class _GoalInfoCell extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _GoalInfoCell({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color.withValues(alpha: 0.6)),
          const Gap(10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 8,
                  letterSpacing: 1,
                ),
              ),
              const Gap(3),
              Text(
                value,
                style: TextStyle(
                  color: color.withValues(alpha: 0.9),
                  fontSize: 13,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
