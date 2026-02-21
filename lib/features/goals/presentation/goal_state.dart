import 'package:altin_takip/features/goals/domain/goal.dart';

sealed class GoalState {
  const GoalState();
}

class GoalInitial extends GoalState {
  const GoalInitial();
}

class GoalLoading extends GoalState {
  const GoalLoading();
}

class GoalLoaded extends GoalState {
  final List<Goal> goals;
  final bool isRefreshing;
  final String? actionError;

  const GoalLoaded({
    required this.goals,
    this.isRefreshing = false,
    this.actionError,
  });

  List<Goal> get activeGoals =>
      goals.where((g) => g.status == GoalStatus.active).toList();

  List<Goal> get pausedGoals =>
      goals.where((g) => g.status == GoalStatus.paused).toList();

  List<Goal> get completedGoals =>
      goals.where((g) => g.status == GoalStatus.completed).toList();

  GoalLoaded copyWith({
    List<Goal>? goals,
    bool? isRefreshing,
    String? actionError,
  }) {
    return GoalLoaded(
      goals: goals ?? this.goals,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      actionError: actionError,
    );
  }
}

class GoalError extends GoalState {
  final String message;
  const GoalError(this.message);
}
