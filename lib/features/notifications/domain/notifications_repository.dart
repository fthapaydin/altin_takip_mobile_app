import 'package:fpdart/fpdart.dart';
import 'package:altin_takip/core/error/failures.dart';
import 'package:altin_takip/features/notifications/domain/notification.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, List<Notification>>> getNotifications({
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, Notification>> getNotificationDetail(int id);

  Future<Either<Failure, void>> markAsRead(int id);
}
