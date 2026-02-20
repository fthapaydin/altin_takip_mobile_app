import 'package:onesignal_flutter/onesignal_flutter.dart';

/// OneSignal push notification service.
///
/// Handles initialization, permission requests, and
/// subscription ID retrieval for backend registration.
class OneSignalService {
  static const String _appId = '5e4ce483-dcb5-4a9f-9c02-63226f185f7c';

  /// Initialize OneSignal SDK.
  Future<void> initialize() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.warn);
    OneSignal.initialize(_appId);
  }

  /// Request notification permission from the user.
  Future<bool> requestPermission() async {
    return await OneSignal.Notifications.requestPermission(true);
  }

  /// Returns the OneSignal subscription (player) ID, or null if not available.
  String? getSubscriptionId() {
    return OneSignal.User.pushSubscription.id;
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
