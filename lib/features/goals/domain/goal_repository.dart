import 'package:fpdart/fpdart.dart';
import 'package:altin_takip/core/error/failures.dart';
import 'package:altin_takip/features/goals/domain/goal.dart';

abstract class GoalRepository {
  /// Fetch all goals for the current user
  Future<Either<Failure, List<Goal>>> getGoals();

  /// Fetch a single goal with full insights
  Future<Either<Failure, Goal>> getGoal(int id);

  /// Create a new goal
  Future<Either<Failure, Goal>> createGoal({
    required String name,
    required GoalCategory category,
    required double targetAmount,
    DateTime? targetDate,
    GoalPriority? priority,
  });

  /// Update an existing goal (partial update)
  Future<Either<Failure, Goal>> updateGoal(
    int id, {
    String? name,
    GoalCategory? category,
    double? targetAmount,
    DateTime? targetDate,
    bool clearTargetDate,
    GoalPriority? priority,
    GoalStatus? status,
  });

  /// Delete a goal
  Future<Either<Failure, Unit>> deleteGoal(int id);
}
