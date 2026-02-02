import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altin_takip/core/di.dart';
import 'package:altin_takip/features/notifications/domain/notification.dart';
import 'package:altin_takip/features/notifications/domain/notifications_repository.dart';
import 'package:altin_takip/features/notifications/presentation/notification_state.dart';

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, NotificationState>(
      NotificationsNotifier.new,
    );

class NotificationsNotifier extends Notifier<NotificationState> {
  late final NotificationsRepository _repository;
  int _page = 1;
  static const int _limit = 20;

  @override
  NotificationState build() {
    _repository = sl<NotificationsRepository>();
    return NotificationInitial();
  }

  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      _page = 1;

      // Preserve existing notifications if available to allow optimistic UI or background refresh
      List<Notification>? current;
      if (state is NotificationLoaded) {
        current = (state as NotificationLoaded).notifications;
      } else if (state is NotificationLoading) {
        current = (state as NotificationLoading).currentNotifications;
      } else if (state is NotificationError) {
        current = (state as NotificationError).currentNotifications;
      }

      state = NotificationLoading(currentNotifications: current);
    } else {
      if (state is NotificationLoaded) {
        state = NotificationLoading(
          currentNotifications: (state as NotificationLoaded).notifications,
        );
      }
    }

    final result = await _repository.getNotifications(
      page: _page,
      limit: _limit,
    );

    result.fold(
      (failure) => state = NotificationError(
        failure.message,
        currentNotifications: state is NotificationLoading
            ? (state as NotificationLoading).currentNotifications
            : null,
      ),
      (notifications) {
        if (refresh) {
          state = NotificationLoaded(
            notifications: notifications,
            hasMore: notifications.length >= _limit,
          );
        } else {
          final current = state is NotificationLoading
              ? (state as NotificationLoading).currentNotifications ?? []
              : <Notification>[];

          state = NotificationLoaded(
            notifications: [...current, ...notifications],
            hasMore: notifications.length >= _limit,
          );
        }
        if (notifications.isNotEmpty) _page++;
      },
    );
  }

  Future<void> markAsRead(int id) async {
    await _repository.markAsRead(id);
    final currentState = state;
    if (currentState is NotificationLoaded) {
      final updatedList = currentState.notifications.map((n) {
        if (n.id == id) {
          return n.copyWith(readAt: DateTime.now());
        }
        return n;
      }).toList();
      state = NotificationLoaded(
        notifications: updatedList,
        hasMore: currentState.hasMore,
      );
    }
  }
}
