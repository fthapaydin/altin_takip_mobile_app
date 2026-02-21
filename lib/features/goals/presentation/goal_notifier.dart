import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altin_takip/core/di.dart';
import 'package:altin_takip/features/goals/domain/goal.dart';
import 'package:altin_takip/features/goals/domain/goal_repository.dart';
import 'package:altin_takip/features/goals/presentation/goal_state.dart';

final goalProvider = NotifierProvider<GoalNotifier, GoalState>(
  GoalNotifier.new,
);

class GoalNotifier extends Notifier<GoalState> {
  late final GoalRepository _repository;

  @override
  GoalState build() {
    _repository = sl<GoalRepository>();
    return const GoalInitial();
  }

  Future<void> loadGoals({bool refresh = false}) async {
    if (state is GoalLoading) return;

    if (refresh && state is GoalLoaded) {
      state = (state as GoalLoaded).copyWith(isRefreshing: true);
    } else {
      state = const GoalLoading();
    }

    final result = await _repository.getGoals();
    result.fold(
      (failure) {
        if (state is GoalLoaded) {
          state = (state as GoalLoaded).copyWith(
            isRefreshing: false,
            actionError: failure.message,
          );
        } else {
          state = GoalError(failure.message);
        }
      },
      (goals) {
        state = GoalLoaded(goals: goals);
      },
    );
  }

  Future<bool> createGoal({
    required String name,
    required GoalCategory category,
    required double targetAmount,
    DateTime? targetDate,
    GoalPriority? priority,
  }) async {
    final result = await _repository.createGoal(
      name: name,
      category: category,
      targetAmount: targetAmount,
      targetDate: targetDate,
      priority: priority,
    );

    return result.fold(
      (failure) {
        if (state is GoalLoaded) {
          state = (state as GoalLoaded).copyWith(actionError: failure.message);
        }
        return false;
      },
      (newGoal) {
        if (state is GoalLoaded) {
          final current = state as GoalLoaded;
          state = current.copyWith(goals: [newGoal, ...current.goals]);
        } else {
          state = GoalLoaded(goals: [newGoal]);
        }
        return true;
      },
    );
  }

  Future<bool> updateGoal(
    int id, {
    String? name,
    GoalCategory? category,
    double? targetAmount,
    DateTime? targetDate,
    bool clearTargetDate = false,
    GoalPriority? priority,
    GoalStatus? status,
  }) async {
    final result = await _repository.updateGoal(
      id,
      name: name,
      category: category,
      targetAmount: targetAmount,
      targetDate: targetDate,
      clearTargetDate: clearTargetDate,
      priority: priority,
      status: status,
    );

    return result.fold(
      (failure) {
        if (state is GoalLoaded) {
          state = (state as GoalLoaded).copyWith(actionError: failure.message);
        }
        return false;
      },
      (updatedGoal) {
        if (state is GoalLoaded) {
          final current = state as GoalLoaded;
          final updatedList = current.goals.map((g) {
            return g.id == id ? updatedGoal : g;
          }).toList();
          state = current.copyWith(goals: updatedList);
        }
        return true;
      },
    );
  }

  Future<bool> deleteGoal(int id) async {
    final result = await _repository.deleteGoal(id);

    return result.fold(
      (failure) {
        if (state is GoalLoaded) {
          state = (state as GoalLoaded).copyWith(actionError: failure.message);
        }
        return false;
      },
      (_) {
        if (state is GoalLoaded) {
          final current = state as GoalLoaded;
          state = current.copyWith(
            goals: current.goals.where((g) => g.id != id).toList(),
          );
        }
        return true;
      },
    );
  }
}
