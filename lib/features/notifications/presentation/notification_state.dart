import 'package:equatable/equatable.dart';
import 'package:altin_takip/features/notifications/domain/notification.dart';

sealed class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {
  final List<Notification>? currentNotifications;
  const NotificationLoading({this.currentNotifications});
}

class NotificationLoaded extends NotificationState {
  final List<Notification> notifications;
  final bool hasMore;

  const NotificationLoaded({required this.notifications, this.hasMore = true});

  @override
  List<Object?> get props => [notifications, hasMore];
}

class NotificationError extends NotificationState {
  final String message;
  final List<Notification>? currentNotifications;

  const NotificationError(this.message, {this.currentNotifications});

  @override
  List<Object?> get props => [message, currentNotifications];
}
