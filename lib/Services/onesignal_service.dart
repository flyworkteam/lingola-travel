import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'dart:io' show Platform;
import '../Core/Config/app_config.dart';

/// OneSignal Service for push notifications
class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;

  OneSignalService._internal();

  bool _isInitialized = false;
  String? _playerId;

  /// Initialize OneSignal
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Check if OneSignal App ID is configured
      if (AppConfig.oneSignalAppId == 'YOUR_ONESIGNAL_APP_ID' ||
          AppConfig.oneSignalAppId.isEmpty) {
        print(
          '⚠️ OneSignal App ID not configured. Please add it to app_config.dart',
        );
        return;
      }

      // Initialize OneSignal
      OneSignal.initialize(AppConfig.oneSignalAppId);

      // Set log level for debugging
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

      // Request permission
      final hasPermission = await OneSignal.Notifications.requestPermission(
        true,
      );
      print('✅ OneSignal permission: $hasPermission');

      // Get player ID
      _playerId = OneSignal.User.pushSubscription.id;
      print('✅ OneSignal Player ID: $_playerId');

      // Set notification handlers
      _setupNotificationHandlers();

      _isInitialized = true;
      print('✅ OneSignal initialized successfully');
    } catch (e) {
      print('❌ OneSignal initialization error: $e');
    }
  }

  /// Set up notification event handlers
  void _setupNotificationHandlers() {
    // Handle notification opened
    OneSignal.Notifications.addClickListener((event) {
      print('🔔 Notification clicked: ${event.notification.notificationId}');
      print('📦 Additional data: ${event.notification.additionalData}');

      // Handle notification tap action here
      // You can navigate to specific screens based on additionalData
    });

    // Handle notification received while app is in foreground
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      print(
        '🔔 Notification received in foreground: ${event.notification.title}',
      );

      // You can prevent notification display if needed
      // event.preventDefault();

      // By default, notification will be displayed
      event.notification.display();
    });

    // Handle permission state changes
    OneSignal.Notifications.addPermissionObserver((state) {
      print('🔔 Notification permission changed: $state');
    });

    // Handle subscription state changes
    OneSignal.User.pushSubscription.addObserver((state) {
      print('🔔 Push subscription changed:');
      print('   ID: ${state.current.id}');
      print('   Token: ${state.current.token}');
      print('   Opted In: ${state.current.optedIn}');

      // Update player ID when it changes
      _playerId = state.current.id;
    });
  }

  /// Set external user ID (map to backend user)
  Future<void> setExternalUserId(String userId) async {
    if (!_isInitialized) await initialize();
    if (!_isInitialized) return; // Skip if not initialized

    try {
      await OneSignal.login(userId);
      print('✅ OneSignal external user ID set: $userId');
    } catch (e) {
      print('❌ Set external user ID error: $e');
    }
  }

  /// Remove external user ID (on logout)
  Future<void> removeExternalUserId() async {
    if (!_isInitialized) return;

    try {
      await OneSignal.logout();
      print('✅ OneSignal external user ID removed');
    } catch (e) {
      print('❌ Remove external user ID error: $e');
    }
  }

  /// Get player ID / push token
  Future<String?> getPlayerId() async {
    if (!_isInitialized) await initialize();
    if (!_isInitialized) return null;

    try {
      _playerId = OneSignal.User.pushSubscription.id;
      print('✅ OneSignal Player ID: $_playerId');
      return _playerId;
    } catch (e) {
      print('❌ Get player ID error: $e');
      return null;
    }
  }

  /// Get device platform
  String getPlatform() {
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'unknown';
  }

  /// Send tags (for user segmentation)
  Future<void> sendTags(Map<String, String> tags) async {
    if (!_isInitialized) await initialize();
    if (!_isInitialized) return;

    try {
      await OneSignal.User.addTags(tags);
      print('✅ OneSignal tags sent: $tags');
    } catch (e) {
      print('❌ Send tags error: $e');
    }
  }

  /// Delete tag
  Future<void> deleteTag(String key) async {
    if (!_isInitialized) return;

    try {
      await OneSignal.User.removeTag(key);
      print('✅ OneSignal tag deleted: $key');
    } catch (e) {
      print('❌ Delete tag error: $e');
    }
  }

  /// Prompt for push permission
  Future<bool> promptForPushPermission() async {
    if (!_isInitialized) await initialize();
    if (!_isInitialized) return false;

    try {
      final result = await OneSignal.Notifications.requestPermission(true);
      print('✅ OneSignal permission result: $result');
      return result;
    } catch (e) {
      print('❌ Permission prompt error: $e');
      return false;
    }
  }

  /// Check if user has granted permission
  Future<bool> hasPermission() async {
    if (!_isInitialized) await initialize();
    if (!_isInitialized) return false;

    try {
      final permission = await OneSignal.Notifications.permission;
      return permission;
    } catch (e) {
      print('❌ Check permission error: $e');
      return false;
    }
  }

  /// Opt user in to push notifications
  Future<void> optIn() async {
    if (!_isInitialized) await initialize();
    if (!_isInitialized) return;

    try {
      await OneSignal.User.pushSubscription.optIn();
      print('✅ OneSignal opted in');
    } catch (e) {
      print('❌ Opt in error: $e');
    }
  }

  /// Opt user out of push notifications
  Future<void> optOut() async {
    if (!_isInitialized) return;

    try {
      await OneSignal.User.pushSubscription.optOut();
      print('✅ OneSignal opted out');
    } catch (e) {
      print('❌ Opt out error: $e');
    }
  }
}
