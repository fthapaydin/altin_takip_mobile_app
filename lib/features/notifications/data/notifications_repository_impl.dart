import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:altin_takip/core/error/failures.dart';
import 'package:altin_takip/features/notifications/data/notification_dto.dart';
import 'package:altin_takip/features/notifications/domain/notification.dart';
import 'package:altin_takip/features/notifications/domain/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final Dio _dio;

  NotificationsRepositoryImpl(this._dio);

  @override
  Future<Either<Failure, List<Notification>>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        'notifications',
        queryParameters: {'page': page, 'limit': limit},
      );

      final data = response.data['data'] as List;
      final notifications = data
          .map((e) => NotificationDto.fromJson(e as Map<String, dynamic>))
          .toList();

      return Right(notifications);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Bir hata oluştu'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Notification>> getNotificationDetail(int id) async {
    try {
      final response = await _dio.get('notifications/$id');
      final notification = NotificationDto.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Right(notification);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Bir hata oluştu'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(int id) async {
    try {
      // Assuming there's an endpoint or logic to mark as read,
      // usually a POST/PUT or implicitly done via getDetail.
      // If explicit endpoint exists:
      // await _dio.post('/api/notifications/$id/read');
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Bir hata oluştu'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
