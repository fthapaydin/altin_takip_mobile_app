import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/goals/domain/goal.dart';

/// Modal bottom sheet actions menu for managing goal statuses and options.
class GoalDetailActionSheet extends StatelessWidget {
  final Goal goal;
  final VoidCallback onEdit;
  final ValueChanged<GoalStatus> onStatusChange;
  final VoidCallback onDelete;

  const GoalDetailActionSheet({
    super.key,
    required this.goal,
    required this.onEdit,
    required this.onStatusChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(20),
              _SheetAction(
                icon: Iconsax.edit_2,
                label: 'Düzenle',
                color: Colors.white,
                onTap: () {
                  Navigator.pop(context);
                  onEdit();
                },
              ),
              Divider(color: Colors.white.withValues(alpha: 0.04), height: 1),
              ..._buildStatusActions(context),
              Divider(color: Colors.white.withValues(alpha: 0.04), height: 1),
              _SheetAction(
                icon: Iconsax.trash,
                label: 'Hedefi Sil',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
              const Gap(4),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStatusActions(BuildContext context) {
    if (goal.status == GoalStatus.active) {
      return [
        _SheetAction(
          icon: Iconsax.pause_circle,
          label: 'Duraklat',
          color: Colors.amber,
          onTap: () {
            Navigator.pop(context);
            onStatusChange(GoalStatus.paused);
          },
        ),
        _SheetAction(
          icon: Iconsax.tick_circle,
          label: 'Tamamlandı İşaretle',
          color: const Color(0xFF34D399),
          onTap: () {
            Navigator.pop(context);
            onStatusChange(GoalStatus.completed);
          },
        ),
      ];
    }
    if (goal.status == GoalStatus.paused) {
      return [
        _SheetAction(
          icon: Iconsax.play_circle,
          label: 'Devam Ettir',
          color: const Color(0xFF34D399),
          onTap: () {
            Navigator.pop(context);
            onStatusChange(GoalStatus.active);
          },
        ),
        _SheetAction(
          icon: Iconsax.close_circle,
          label: 'İptal Et',
          color: Colors.orange,
          onTap: () {
            Navigator.pop(context);
            onStatusChange(GoalStatus.cancelled);
          },
        ),
      ];
    }
    if (goal.status == GoalStatus.completed || goal.status == GoalStatus.cancelled) {
      return [
        _SheetAction(
          icon: Iconsax.refresh,
          label: 'Yeniden Aktifleştir',
          color: AppTheme.gold,
          onTap: () {
            Navigator.pop(context);
            onStatusChange(GoalStatus.active);
          },
        ),
      ];
    }
    return [];
  }
}

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SheetAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: color.withValues(alpha: 0.08),
        highlightColor: color.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const Gap(14),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              Icon(
                Iconsax.arrow_right_3,
                size: 14,
                color: color.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
