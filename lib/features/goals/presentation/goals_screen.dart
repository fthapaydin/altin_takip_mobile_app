import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/widgets/app_bar_widget.dart';
import 'package:altin_takip/core/widgets/app_notification.dart';
import 'package:altin_takip/features/goals/presentation/goal_notifier.dart';
import 'package:altin_takip/features/goals/presentation/goal_state.dart';
import 'package:altin_takip/features/goals/presentation/goal_detail_screen.dart';
import 'package:altin_takip/features/goals/presentation/widgets/goal_card.dart';
import 'package:altin_takip/features/goals/presentation/widgets/goals_empty_state.dart';
import 'package:altin_takip/features/goals/presentation/widgets/goals_skeleton.dart';
import 'package:altin_takip/features/goals/presentation/widgets/add_goal_sheet.dart';
import 'package:altin_takip/features/goals/domain/goal.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:altin_takip/features/notifications/presentation/notifications_screen.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(goalProvider.notifier).loadGoals());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(goalProvider);

    // Listen for action errors
    ref.listen<GoalState>(goalProvider, (prev, next) {
      if (next is GoalLoaded && next.actionError != null) {
        AppNotification.show(
          context,
          message: next.actionError!,
          type: NotificationType.error,
        );
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBarWidget(
        title: 'Hedeflerim',
        showBack: false,
        centerTitle: false,
        isLargeTitle: true,
        actions: [
          AppBarActionButton(
            icon: Iconsax.notification,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          const Gap(8),
          AppBarActionButton(
            icon: Iconsax.add,
            onTap: () => AddGoalSheet.show(context),
          ),
          const Gap(16),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(GoalState state) {
    return switch (state) {
      GoalInitial() || GoalLoading() => const GoalsSkeleton(),
      GoalError(:final message) => _buildErrorState(message),
      GoalLoaded(:final goals, :final isRefreshing) =>
        goals.isEmpty
            ? GoalsEmptyState(onAdd: () => AddGoalSheet.show(context))
            : _buildGoalsList(state, isRefreshing),
    };
  }

  Widget _buildGoalsList(GoalLoaded state, bool isRefreshing) {
    final activeGoals = state.activeGoals;
    final pausedGoals = state.pausedGoals;
    final completedGoals = state.completedGoals;

    return RefreshIndicator(
      onRefresh: () => ref.read(goalProvider.notifier).loadGoals(refresh: true),
      color: AppTheme.gold,
      backgroundColor: AppTheme.surface,
      edgeOffset: MediaQuery.of(context).padding.top + AppBarWidget.getExpandedHeight(isLargeTitle: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.of(context).padding.top +
              AppBarWidget.getExpandedHeight(isLargeTitle: true) +
              12.0,
          20,
          120,
        ),
        children: [
          if (activeGoals.isNotEmpty) ...[
            _buildSectionHeader('Aktif Hedefler', activeGoals.length),
            const Gap(12),
            ...activeGoals.map(_buildGoalItem),
          ],
          if (pausedGoals.isNotEmpty) ...[
            const Gap(24),
            _buildSectionHeader('Duraklatılan Hedefler', pausedGoals.length),
            const Gap(12),
            ...pausedGoals.map(_buildGoalItem),
          ],
          if (completedGoals.isNotEmpty) ...[
            const Gap(24),
            _buildSectionHeader('Tamamlanan Hedefler', completedGoals.length),
            const Gap(12),
            ...completedGoals.map(_buildGoalItem),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalItem(Goal goal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GoalCard(
        goal: goal,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GoalDetailScreen(goalId: goal.id)),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 10,
          ),
        ),
        const Gap(8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.warning_2,
            color: Colors.red.withValues(alpha: 0.5),
            size: 48,
          ),
          const Gap(16),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(16),
          TextButton.icon(
            onPressed: () => ref.read(goalProvider.notifier).loadGoals(),
            icon: const Icon(Iconsax.refresh, size: 16),
            label: const Text('Tekrar Dene'),
            style: TextButton.styleFrom(foregroundColor: AppTheme.gold),
          ),
        ],
      ),
    );
  }
}
