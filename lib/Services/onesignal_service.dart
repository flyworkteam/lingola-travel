import 'package:onesignal_flutter/onesignal_flutter.dart';

/// OneSignal Service for push notifications
class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;

  OneSignalService._internal();

  bool _isInitialized = false;

  /// Initialize OneSignal
  Future<void> initialize() async {
    if (_isInitialized) return;

    // TODO: Uncomment and configure when OneSignal App ID is available
    // OneSignal.initialize(AppConfig.oneSignalAppId);

    // Set log level for debugging
    // OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    // Request permission
    // await OneSignal.Notifications.requestPermission(true);

    _isInitialized = true;
    print('OneSignal initialized (TODO: Add App ID)');
  }

  /// Set external user ID (map to backend user)
  Future<void> setExternalUserId(String userId) async {
    if (!_isInitialized) await initialize();
    // TODO: Uncomment when OneSignal is configured
    // await OneSignal.login(userId);
    print('OneSignal external user ID set: $userId (TODO)');
  }

  /// Remove external user ID (on logout)
  Future<void> removeExternalUserId() async {
    if (!_isInitialized) return;
    // TODO: Uncomment when OneSignal is configured
    // await OneSignal.logout();
    print('OneSignal external user ID removed (TODO)');
  }

  /// Get player ID / push token
  Future<String?> getPlayerId() async {
    if (!_isInitialized) await initialize();
    // TODO: Implement when OneSignal is configured
    // final deviceState = await OneSignal.User.pushSubscription.id;
    // return deviceState;
    print('OneSignal get player ID (TODO)');
    return null;
  }

  /// Set notification opened handler
  void setNotificationOpenedHandler(
    Function(OSNotificationClickEvent) handler,
  ) {
    if (!_isInitialized) return;
    // TODO: Uncomment when OneSignal is configured
    // OneSignal.Notifications.addClickListener(handler);
  }

  /// Set notification received handler
  void setNotificationReceivedHandler(
    Function(OSNotificationWillDisplayEvent) handler,
  ) {
    if (!_isInitialized) return;
    // TODO: Uncomment when OneSignal is configured
    // OneSignal.Notifications.addForegroundWillDisplayListener(handler);
  }

  /// Send tags (for user segmentation)
  Future<void> sendTags(Map<String, dynamic> tags) async {
    if (!_isInitialized) await initialize();
    // TODO: Implement when OneSignal is configured
    // await OneSignal.User.addTags(tags);
    print('OneSignal tags sent: $tags (TODO)');
  }

  /// Delete tag
  Future<void> deleteTag(String key) async {
    if (!_isInitialized) return;
    // TODO: Implement when OneSignal is configured
    // await OneSignal.User.removeTag(key);
    print('OneSignal tag deleted: $key (TODO)');
  }

  /// Prompt for push permission
  Future<bool> promptForPushPermission() async {
    if (!_isInitialized) await initialize();
    // TODO: Implement when OneSignal is configured
    // return await OneSignal.Notifications.requestPermission(true);
    print('OneSignal permission prompt (TODO)');
    return false;
  }

  /// Check if user has granted permission
  Future<bool> hasPermission() async {
    if (!_isInitialized) await initialize();
    // TODO: Implement when OneSignal is configured
    // final permission = await OneSignal.Notifications.permission;
    // return permission;
    print('OneSignal check permission (TODO)');
    return false;
  }
}
