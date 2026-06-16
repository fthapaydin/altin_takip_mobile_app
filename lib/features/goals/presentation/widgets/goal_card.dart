import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/goals/domain/goal.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;

  const GoalCard({super.key, required this.goal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final progress = goal.progress;
    final percentage = progress?.progressPercentage ?? 0;
    final normalized = (percentage / 100).clamp(0.0, 1.0);
    final formatter = NumberFormat('#,##0', 'tr_TR');
    final color = _categoryColor(goal.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          gradient: _categoryGradient(goal.category),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left vertical indicator strip
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Container(
                width: 4,
                height: 38,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  _HeaderRow(goal: goal),
                  const Gap(16),
                  // Progress bar
                  _ProgressBar(normalized: normalized, category: goal.category),
                  const Gap(12),
                  // Amount row
                  _AmountRow(
                    progress: progress,
                    percentage: percentage,
                    formatter: formatter,
                    category: goal.category,
                  ),
                  // Target date row (if exists)
                  if (goal.targetDate != null) ...[
                    const Gap(12),
                    _TargetDateRow(targetDate: goal.targetDate!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0);
  }
}

// ── Shared Helpers ──

LinearGradient _categoryGradient(GoalCategory category) {
  switch (category) {
    case GoalCategory.gold:
      return const LinearGradient(
        colors: [Color(0xFF16140F), Color(0xFF0F0E0B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case GoalCategory.currency:
      return const LinearGradient(
        colors: [Color(0xFF0F131C), Color(0xFF090B10)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case GoalCategory.all:
      return const LinearGradient(
        colors: [Color(0xFF0F1614), Color(0xFF090E0D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
  }
}

Color _categoryColor(GoalCategory category) {
  switch (category) {
    case GoalCategory.gold:
      return AppTheme.gold;
    case GoalCategory.currency:
      return const Color(0xFF4C82F7);
    case GoalCategory.all:
      return const Color(0xFF34D399);
  }
}

// ── Sub Widgets ──

class _HeaderRow extends StatelessWidget {
  final Goal goal;
  const _HeaderRow({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  letterSpacing: -0.3,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Gap(2),
              Text(
                goal.category.displayName,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        // Priority + Status
        _StatusBadge(goal: goal),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Goal goal;
  const _StatusBadge({required this.goal});

  @override
  Widget build(BuildContext context) {
    if (goal.status == GoalStatus.active) {
      return _PriorityDot(priority: goal.priority);
    }

    final (Color color, String label) = switch (goal.status) {
      GoalStatus.completed => (const Color(0xFF34D399), 'Tamamlandı'),
      GoalStatus.paused => (Colors.amber, 'Duraklatıldı'),
      GoalStatus.cancelled => (Colors.red, 'İptal'),
      _ => (Colors.grey, ''),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _PriorityDot extends StatelessWidget {
  final GoalPriority priority;
  const _PriorityDot({required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = switch (priority) {
      GoalPriority.high => Colors.red,
      GoalPriority.medium => Colors.amber,
      GoalPriority.low => const Color(0xFF34D399),
    };

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double normalized;
  final GoalCategory category;
  const _ProgressBar({required this.normalized, required this.category});

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(category);
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 6,
        child: Stack(
          children: [
            Container(color: Colors.white.withValues(alpha: 0.06)),
            FractionallySizedBox(
              widthFactor: normalized,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final GoalProgress? progress;
  final double percentage;
  final NumberFormat formatter;
  final GoalCategory category;

  const _AmountRow({
    required this.progress,
    required this.percentage,
    required this.formatter,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '₺${formatter.format(progress?.currentValue ?? 0)} / ₺${formatter.format(progress?.targetAmount ?? 0)}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          '%${percentage.toStringAsFixed(1)}',
          style: TextStyle(
            color: _categoryColor(category),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _TargetDateRow extends StatelessWidget {
  final DateTime targetDate;
  const _TargetDateRow({required this.targetDate});

  @override
  Widget build(BuildContext context) {
    final remaining = targetDate.difference(DateTime.now()).inDays;
    final dateStr = DateFormat('d MMMM yyyy', 'tr_TR').format(targetDate);

    return Row(
      children: [
        Icon(
          Iconsax.calendar_1,
          size: 12,
          color: Colors.white.withValues(alpha: 0.3),
        ),
        const Gap(6),
        Text(
          dateStr,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.35),
            fontSize: 11,
          ),
        ),
        const Gap(8),
        Container(
          width: 3,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
        ),
        const Gap(8),
        Text(
          remaining > 0 ? '$remaining gün kaldı' : 'Süre doldu',
          style: TextStyle(
            color: remaining > 0
                ? Colors.white.withValues(alpha: 0.35)
                : Colors.red.withValues(alpha: 0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
