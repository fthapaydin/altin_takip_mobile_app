import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/di.dart';
import 'package:altin_takip/core/widgets/app_notification.dart';
import 'package:altin_takip/core/widgets/app_bar_widget.dart';
import 'package:altin_takip/features/goals/domain/goal.dart';
import 'package:altin_takip/features/goals/domain/goal_repository.dart';
import 'package:altin_takip/features/goals/presentation/goal_notifier.dart';
import 'package:altin_takip/features/goals/presentation/widgets/goal_insights_card.dart';
import 'package:altin_takip/features/goals/presentation/widgets/edit_goal_sheet.dart';
import 'package:altin_takip/features/goals/presentation/widgets/goal_detail_shimmer.dart';
import 'package:altin_takip/features/goals/presentation/widgets/goal_detail_action_sheet.dart';
import 'package:altin_takip/features/goals/presentation/widgets/goal_detail_progress_section.dart';
import 'package:altin_takip/features/goals/presentation/widgets/goal_detail_info_card.dart';
import 'package:altin_takip/features/goals/presentation/widgets/goal_detail_remaining_card.dart';

/// Screen presenting the detailed properties and configuration options of a goal.
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

  Future<void> _loadDetail({bool silent = false}) async {
    if (!silent) setState(() { _isInitialLoading = true; _error = null; });
    final result = await sl<GoalRepository>().getGoal(widget.goalId);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() { if (!silent) _error = failure.message; _isInitialLoading = false; }),
      (goal) => setState(() { _detailedGoal = goal; _isInitialLoading = false; }),
    );
  }

  Future<void> _refreshDetail() async {
    setState(() => _isRefreshing = true);
    await _loadDetail(silent: true);
    if (mounted) setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBarWidget(
        title: _detailedGoal?.name ?? 'Hedef Detayı',
        isLargeTitle: false,
        centerTitle: true,
        actions: [
          if (_detailedGoal != null && !_isActioning)
            AppBarActionButton(icon: Iconsax.more, onTap: () => _showActionsSheet(context)),
        ],
      ),
      body: Column(
        children: [
          if (_isActioning || _isRefreshing)
            LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.gold.withValues(alpha: 0.8)),
            ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  void _showActionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => GoalDetailActionSheet(
        goal: _detailedGoal!,
        onEdit: _handleEdit,
        onStatusChange: _handleStatusChange,
        onDelete: _handleDelete,
      ),
    );
  }

  Future<void> _handleEdit() async {
    await EditGoalSheet.show(context, _detailedGoal!);
    _refreshDetail();
  }

  Future<void> _handleStatusChange(GoalStatus status) async {
    setState(() => _isActioning = true);
    final success = await ref.read(goalProvider.notifier).updateGoal(widget.goalId, status: status);
    if (!mounted) return;
    if (success) {
      AppNotification.show(context, message: 'Durum güncellendi.', type: NotificationType.success);
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
        content: const Text('Bu hedefi silmek istediğinize emin misiniz?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
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
      final success = await ref.read(goalProvider.notifier).deleteGoal(widget.goalId);
      if (mounted && success) {
        Navigator.pop(context);
        AppNotification.show(context, message: 'Hedef silindi.', type: NotificationType.success);
      }
      if (mounted) setState(() => _isActioning = false);
    }
  }

  Widget _buildBody() {
    if (_isInitialLoading && _detailedGoal == null) return const GoalDetailShimmer();
    if (_error != null && _detailedGoal == null) return _buildErrorState();
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
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.of(context).padding.top + AppBarWidget.getExpandedHeight(isLargeTitle: false) + 12.0,
          20,
          40,
        ),
        children: [
          GoalDetailProgressSection(normalized: normalized, percentage: percentage).animate().fadeIn(duration: 400.ms),
          const Gap(20),
          GoalDetailInfoCard(
            goal: goal,
            currentValue: progress?.currentValue ?? 0,
            targetAmount: progress?.targetAmount ?? goal.targetAmount,
            formatter: formatter,
          ),
          const Gap(28),
          if (progress != null) ...[
            GoalDetailRemainingCard(remainingAmount: progress.remainingAmount, formatter: formatter),
            const Gap(28),
          ],
          if (goal.insights != null) GoalInsightsCard(insights: goal.insights!),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.warning_2, color: Colors.red.withValues(alpha: 0.5), size: 40),
          const Gap(12),
          Text(_error ?? 'Bir hata oluştu', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
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
