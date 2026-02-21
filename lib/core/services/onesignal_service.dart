import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:altin_takip/features/notifications/presentation/notification_detail_screen.dart';
import 'package:altin_takip/core/di.dart';
import 'package:altin_takip/features/notifications/domain/notifications_repository.dart';

/// OneSignal push notification service.
///
/// Handles initialization, permission requests, and
/// OneSignal ID retrieval for backend registration.
class OneSignalService {
  static const String _appId = '5e4ce483-dcb5-4a9f-9c02-63226f185f7c';

  String? _cachedOneSignalId;

  /// Initialize OneSignal SDK and listen for user state changes.
  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    OneSignal.Debug.setLogLevel(OSLogLevel.warn);
    OneSignal.initialize(_appId);

    // Cache the OneSignal ID whenever user state changes
    OneSignal.User.addObserver((state) {
      _cachedOneSignalId = state.current.onesignalId;
    });

    // Handle deep links when a user taps a notification
    OneSignal.Notifications.addClickListener((event) async {
      final additionalData = event.notification.additionalData;
      String? appUrl;

      // Check if 'app_url' exists in additional data
      if (additionalData != null && additionalData.containsKey('app_url')) {
        appUrl = additionalData['app_url'] as String?;
      }

      // Or fallback to launchUrl if set directly from OneSignal dashboard
      appUrl ??= event.notification.launchUrl;

      if (appUrl != null && appUrl.startsWith('altintakip://')) {
        _handleDeepLink(appUrl, navigatorKey);
      }
    });

    // Try to get the ID immediately if already available
    _cachedOneSignalId = await OneSignal.User.getOnesignalId();
  }

  /// Parses the deep link and redirects appropriately.
  Future<void> _handleDeepLink(
    String url,
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    final uri = Uri.parse(url);

    // Expected format: altintakip://notification/15
    if (uri.host == 'notification' && uri.pathSegments.isNotEmpty) {
      final idString = uri.pathSegments.first;
      final notificationId = int.tryParse(idString);

      if (notificationId != null) {
        // Wait briefly for app to boot/mount properly if opening from terminated state
        await Future.delayed(const Duration(milliseconds: 500));

        // Optionally, show a fast loading dialog or straight jump if we had a full domain provider structure ready.
        // We will fetch the notification detail and push the screen
        _fetchAndNavigateToNotification(notificationId, navigatorKey);
      }
    }
  }

  Future<void> _fetchAndNavigateToNotification(
    int id,
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    try {
      final repository = sl<NotificationsRepository>();
      final result = await repository.getNotifications(
        page: 1,
      ); // Simple way to fetch, ideally we'd have a getNotificationById.

      result.fold(
        (failure) {
          debugPrint('Bidirim detayı alınamadı: ${failure.message}');
        },
        (notificationsData) {
          // Find the specific notification from the loaded page/data if available
          // (If backend has an endpoint for specific notification, that should be used instead).
          final notification = notificationsData.firstWhere(
            (n) => n.id == id,
            orElse: () => throw Exception('Not found in initial page'),
          );

          final context = navigatorKey.currentContext;
          if (context == null || !context.mounted) return;

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  NotificationDetailScreen(notification: notification),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Deep link fetch hatası: $e');
    }
  }

  /// Request notification permission from the user.
  Future<bool> requestPermission() async {
    return await OneSignal.Notifications.requestPermission(true);
  }

  /// Returns the OneSignal User ID (the one shown in the dashboard).
  ///
  /// This is the user-level OneSignal ID that the backend needs
  /// for targeting push notifications.
  Future<String?> getOneSignalId() async {
    // Try the async getter first (most reliable)
    final id = await OneSignal.User.getOnesignalId();
    if (id != null) {
      _cachedOneSignalId = id;
      return id;
    }
    // Fall back to cached value from observer
    return _cachedOneSignalId;
  }

  /// Sets the external user ID for targeting from the backend.
  void setExternalUserId(String userId) {
    OneSignal.login(userId);
  }

  /// Removes the external user ID (on logout).
  void removeExternalUserId() {
    OneSignal.logout();
  }
}
