import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/di.dart';
import 'package:altin_takip/core/widgets/app_notification.dart';
import 'package:altin_takip/features/goals/domain/goal.dart';
import 'package:altin_takip/features/goals/domain/goal_repository.dart';
import 'package:altin_takip/features/goals/presentation/goal_notifier.dart';
import 'package:altin_takip/features/goals/presentation/widgets/goal_insights_card.dart';
import 'package:altin_takip/features/goals/presentation/widgets/edit_goal_sheet.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

class GoalDetailScreen extends ConsumerStatefulWidget {
  final int goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  ConsumerState<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailScreen> {
  Goal? _detailedGoal;
  bool _isInitialLoading = true;
  bool _isActioning = false;
  bool _isRefreshing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  /// Initial load shows shimmer. Subsequent calls silently update data.
  Future<void> _loadDetail({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isInitialLoading = true;
        _error = null;
      });
    }

    final result = await sl<GoalRepository>().getGoal(widget.goalId);
    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        if (!silent) _error = failure.message;
        _isInitialLoading = false;
      }),
      (goal) => setState(() {
        _detailedGoal = goal;
        _isInitialLoading = false;
      }),
    );
  }

  /// Silently refreshes data without shimmer.
  Future<void> _refreshDetail() async {
    setState(() => _isRefreshing = true);
    await _loadDetail(silent: true);
    if (mounted) setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          _detailedGoal?.name ?? 'Hedef Detayı',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          if (_detailedGoal != null && !_isActioning)
            IconButton(
              icon: const Icon(Iconsax.more, color: Colors.white, size: 20),
              onPressed: () => _showActionsSheet(context),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_isActioning || _isRefreshing)
            LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.gold.withValues(alpha: 0.8),
              ),
            ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // ── Custom Action Sheet ──

  void _showActionsSheet(BuildContext context) {
    final goal = _detailedGoal!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
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
                // Handle
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Gap(20),
                // Edit
                _SheetAction(
                  icon: Iconsax.edit_2,
                  label: 'Düzenle',
                  color: Colors.white,
                  onTap: () {
                    Navigator.pop(context);
                    _handleEdit();
                  },
                ),
                Divider(color: Colors.white.withValues(alpha: 0.04), height: 1),
                // Status actions
                ..._buildStatusActions(goal),
                Divider(color: Colors.white.withValues(alpha: 0.04), height: 1),
                // Delete
                _SheetAction(
                  icon: Iconsax.trash,
                  label: 'Hedefi Sil',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _handleDelete();
                  },
                ),
                const Gap(4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStatusActions(Goal goal) {
    if (goal.status == GoalStatus.active) {
      return [
        _SheetAction(
          icon: Iconsax.pause_circle,
          label: 'Duraklat',
          color: Colors.amber,
          onTap: () {
            Navigator.pop(context);
            _handleStatusChange(GoalStatus.paused);
          },
        ),
        _SheetAction(
          icon: Iconsax.tick_circle,
          label: 'Tamamlandı İşaretle',
          color: const Color(0xFF34D399),
          onTap: () {
            Navigator.pop(context);
            _handleStatusChange(GoalStatus.completed);
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
            _handleStatusChange(GoalStatus.active);
          },
        ),
        _SheetAction(
          icon: Iconsax.close_circle,
          label: 'İptal Et',
          color: Colors.orange,
          onTap: () {
            Navigator.pop(context);
            _handleStatusChange(GoalStatus.cancelled);
          },
        ),
      ];
    }
    if (goal.status == GoalStatus.completed ||
        goal.status == GoalStatus.cancelled) {
      return [
        _SheetAction(
          icon: Iconsax.refresh,
          label: 'Yeniden Aktifleştir',
          color: AppTheme.gold,
          onTap: () {
            Navigator.pop(context);
            _handleStatusChange(GoalStatus.active);
          },
        ),
      ];
    }
    return [];
  }

  // ── Handlers (silent refresh — no shimmer) ──

  Future<void> _handleEdit() async {
    await EditGoalSheet.show(context, _detailedGoal!);
    _refreshDetail();
  }

  Future<void> _handleStatusChange(GoalStatus status) async {
    setState(() => _isActioning = true);

    final success = await ref
        .read(goalProvider.notifier)
        .updateGoal(widget.goalId, status: status);

    if (!mounted) return;

    if (success) {
      AppNotification.show(
        context,
        message: 'Durum güncellendi.',
        type: NotificationType.success,
      );
      await _refreshDetail();
    }

    if (mounted) setState(() => _isActioning = false);
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hedefi Sil', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Bu hedefi kalıcı olarak silmek istediğinize emin misiniz?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isActioning = true);
      final success = await ref
          .read(goalProvider.notifier)
          .deleteGoal(widget.goalId);
      if (mounted && success) {
        Navigator.pop(context);
        AppNotification.show(
          context,
          message: 'Hedef silindi.',
          type: NotificationType.success,
        );
      }
      if (mounted) setState(() => _isActioning = false);
    }
  }

  // ── Body ──

  Widget _buildBody() {
    if (_isInitialLoading && _detailedGoal == null) {
      return _buildShimmer();
    }
    if (_error != null && _detailedGoal == null) {
      return _buildErrorState();
    }
    if (_detailedGoal == null) return const SizedBox();

    final goal = _detailedGoal!;
    final progress = goal.progress;
    final percentage = progress?.progressPercentage ?? 0;
    final normalized = (percentage / 100).clamp(0.0, 1.0);
    final formatter = NumberFormat('#,##0', 'tr_TR');

    return RefreshIndicator(
      onRefresh: _refreshDetail,
      color: AppTheme.gold,
      backgroundColor: AppTheme.surface,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          _ProgressSection(
            normalized: normalized,
            percentage: percentage,
          ).animate().fadeIn(duration: 400.ms),
          const Gap(20),

          _GoalInfoCard(
            goal: goal,
            currentValue: progress?.currentValue ?? 0,
            targetAmount: progress?.targetAmount ?? goal.targetAmount,
            formatter: formatter,
          ),
          const Gap(28),

          if (progress != null) ...[
            _RemainingCard(
              remainingAmount: progress.remainingAmount,
              formatter: formatter,
            ),
            const Gap(28),
          ],

          if (goal.insights != null) GoalInsightsCard(insights: goal.insights!),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.05),
      highlightColor: Colors.white.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          children: [
            // Progress ring
            Container(
              width: 160,
              height: 160,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const Gap(20),
            // Unified info card (price + 2x2 grid)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white),
              ),
              child: Column(
                children: [
                  // Price row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 8,
                              color: Colors.white,
                            ),
                            const Gap(8),
                            Container(
                              width: 80,
                              height: 18,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 30, color: Colors.white),
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 8,
                              color: Colors.white,
                            ),
                            const Gap(8),
                            Container(
                              width: 80,
                              height: 18,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(24),
                  Container(height: 1, color: Colors.white),
                  const Gap(24),
                  // Grid row 1
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              color: Colors.white,
                            ),
                            const Gap(12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 8,
                                  color: Colors.white,
                                ),
                                const Gap(6),
                                Container(
                                  width: 60,
                                  height: 14,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              color: Colors.white,
                            ),
                            const Gap(12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 8,
                                  color: Colors.white,
                                ),
                                const Gap(6),
                                Container(
                                  width: 60,
                                  height: 14,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(24),
                  Container(height: 1, color: Colors.white),
                  const Gap(24),
                  // Grid row 2
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              color: Colors.white,
                            ),
                            const Gap(12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 8,
                                  color: Colors.white,
                                ),
                                const Gap(6),
                                Container(
                                  width: 60,
                                  height: 14,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              color: Colors.white,
                            ),
                            const Gap(12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 8,
                                  color: Colors.white,
                                ),
                                const Gap(6),
                                Container(
                                  width: 60,
                                  height: 14,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(28),
            // Remaining card
            Container(
              width: double.infinity,
              height: 72,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white),
              ),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Gap(12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 60, height: 8, color: Colors.white),
                      const Gap(6),
                      Container(width: 100, height: 18, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(28),
            // Insights label
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 100,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const Gap(12),
            // Insights 2-col
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const Gap(10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 50,
                                height: 8,
                                color: Colors.white,
                              ),
                              const Gap(6),
                              Container(
                                width: 80,
                                height: 14,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: Container(
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const Gap(10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 50,
                                height: 8,
                                color: Colors.white,
                              ),
                              const Gap(6),
                              Container(
                                width: 80,
                                height: 14,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Gap(10),
            // Insights full-width
            Container(
              width: double.infinity,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 50, height: 8, color: Colors.white),
                        const Gap(6),
                        Container(width: 80, height: 14, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Gap(16),
            // Motivation
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 250, height: 10, color: Colors.white),
                  const Gap(4),
                  Container(width: 200, height: 10, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.warning_2,
            color: Colors.red.withValues(alpha: 0.5),
            size: 40,
          ),
          const Gap(12),
          Text(
            _error ?? 'Bir hata oluştu',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          ),
          const Gap(12),
          TextButton.icon(
            onPressed: _loadDetail,
            icon: const Icon(Iconsax.refresh, size: 16),
            label: const Text('Tekrar Dene'),
            style: TextButton.styleFrom(foregroundColor: AppTheme.gold),
          ),
        ],
      ),
    );
  }
}

// ── Action Sheet Item ──

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

// ── Sub Widgets ──

class _ProgressSection extends StatelessWidget {
  final double normalized;
  final double percentage;

  const _ProgressSection({required this.normalized, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 160,
        height: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: CircularProgressIndicator(
                value: normalized,
                strokeWidth: 8,
                strokeCap: StrokeCap.round,
                backgroundColor: Colors.white.withValues(alpha: 0.06),
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.gold),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '%${percentage.toStringAsFixed(1)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  'tamamlandı',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalInfoCard extends StatelessWidget {
  final Goal goal;
  final double currentValue;
  final double targetAmount;
  final NumberFormat formatter;

  const _GoalInfoCard({
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
          // Price row
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
          // Info grid - top row
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _infoCell(
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
                  child: _infoCell(
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
          // Info grid - bottom row
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _infoCell(
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
                  child: _infoCell(
                    label: 'HEDEF TARİH',
                    value: goal.targetDate != null
                        ? DateFormat(
                            'd MMM yyyy',
                            'tr_TR',
                          ).format(goal.targetDate!)
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

  Widget _infoCell({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
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

class _RemainingCard extends StatelessWidget {
  final double remainingAmount;
  final NumberFormat formatter;

  const _RemainingCard({
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
