import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:altin_takip/core/error/failures.dart';
import 'package:altin_takip/core/network/dio_client.dart';
import 'package:altin_takip/core/network/network_exception_handler.dart';
import 'package:altin_takip/features/goals/data/goal_dto.dart';
import 'package:altin_takip/features/goals/domain/goal.dart';
import 'package:altin_takip/features/goals/domain/goal_repository.dart';

class GoalRepositoryImpl implements GoalRepository {
  final DioClient _dioClient;

  GoalRepositoryImpl(this._dioClient);

  @override
  Future<Either<Failure, List<Goal>>> getGoals() async {
    try {
      final response = await _dioClient.dio.get('goals');
      final List data = response.data['data'] ?? [];
      final goals = data.map<Goal>((json) => GoalDto.fromJson(json)).toList();
      return Right(goals);
    } catch (e) {
      return Left(ServerFailure(NetworkExceptionHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, Goal>> getGoal(int id) async {
    try {
      final response = await _dioClient.dio.get('goals/$id');
      return Right(GoalDto.fromJson(response.data['data']));
    } catch (e) {
      return Left(ServerFailure(NetworkExceptionHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, Goal>> createGoal({
    required String name,
    required GoalCategory category,
    required double targetAmount,
    DateTime? targetDate,
    GoalPriority? priority,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
        'category': category.apiValue,
        'target_amount': targetAmount,
      };
      if (targetDate != null) {
        body['target_date'] = _formatDate(targetDate);
      }
      if (priority != null) {
        body['priority'] = priority.apiValue;
      }

      final response = await _dioClient.dio.post('goals', data: body);
      return Right(GoalDto.fromJson(response.data['data']));
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 422) {
        return Left(
          ValidationFailure(NetworkExceptionHandler.getErrorMessage(e)),
        );
      }
      return Left(ServerFailure(NetworkExceptionHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, Goal>> updateGoal(
    int id, {
    String? name,
    GoalCategory? category,
    double? targetAmount,
    DateTime? targetDate,
    bool clearTargetDate = false,
    GoalPriority? priority,
    GoalStatus? status,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (category != null) body['category'] = category.apiValue;
      if (targetAmount != null) body['target_amount'] = targetAmount;
      if (clearTargetDate) {
        body['target_date'] = null;
      } else if (targetDate != null) {
        body['target_date'] = _formatDate(targetDate);
      }
      if (priority != null) body['priority'] = priority.apiValue;
      if (status != null) body['status'] = status.apiValue;

      final response = await _dioClient.dio.put('goals/$id', data: body);
      return Right(GoalDto.fromJson(response.data['data']));
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 422) {
        return Left(
          ValidationFailure(NetworkExceptionHandler.getErrorMessage(e)),
        );
      }
      return Left(ServerFailure(NetworkExceptionHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteGoal(int id) async {
    try {
      await _dioClient.dio.delete('goals/$id');
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(NetworkExceptionHandler.getErrorMessage(e)));
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
