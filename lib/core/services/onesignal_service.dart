import 'dart:async';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// OneSignal push notification service.
///
/// Handles initialization, permission requests, and
/// OneSignal ID retrieval for backend registration.
class OneSignalService {
  static const String _appId = '5e4ce483-dcb5-4a9f-9c02-63226f185f7c';

  String? _cachedOneSignalId;

  /// Initialize OneSignal SDK and listen for user state changes.
  Future<void> initialize() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.warn);
    OneSignal.initialize(_appId);

    // Cache the OneSignal ID whenever user state changes
    OneSignal.User.addObserver((state) {
      _cachedOneSignalId = state.current.onesignalId;
    });

    // Try to get the ID immediately if already available
    _cachedOneSignalId = await OneSignal.User.getOnesignalId();
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
