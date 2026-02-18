import '../Models/api_response.dart';
import '../Models/notification_model.dart';
import 'base_repository.dart';

/// Notification Repository - Handles all notification-related API calls
class NotificationRepository extends BaseRepository {
  /// Get all notifications for the current user
  Future<ApiResponse<List<NotificationModel>>> getNotifications({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await apiClient.get(
        '/notifications',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      if (response.success && response.data != null) {
        final List<dynamic> notificationsJson =
            response.data['notifications'] ?? [];
        final notifications = notificationsJson
            .map(
              (json) =>
                  NotificationModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        return ApiResponse(success: true, data: notifications);
      }

      return ApiResponse(success: false, error: response.error);
    } catch (e) {
      return handleError(e);
    }
  }

  /// Get unread notification count
  Future<ApiResponse<int>> getUnreadCount() async {
    try {
      final response = await apiClient.get('/notifications/unread-count');

      if (response.success && response.data != null) {
        final count = response.data['unread_count'] as int? ?? 0;
        return ApiResponse(success: true, data: count);
      }

      return ApiResponse(success: false, error: response.error);
    } catch (e) {
      return handleError(e);
    }
  }

  /// Mark notification as read
  Future<ApiResponse<bool>> markAsRead(String notificationId) async {
    try {
      final response = await apiClient.put(
        '/notifications/$notificationId/read',
      );

      return ApiResponse(
        success: response.success,
        data: response.success,
        error: response.error,
      );
    } catch (e) {
      return handleError(e);
    }
  }

  /// Mark all notifications as read
  Future<ApiResponse<bool>> markAllAsRead() async {
    try {
      final response = await apiClient.put('/notifications/read-all');

      return ApiResponse(
        success: response.success,
        data: response.success,
        error: response.error,
      );
    } catch (e) {
      return handleError(e);
    }
  }

  /// Delete a notification
  Future<ApiResponse<bool>> deleteNotification(String notificationId) async {
    try {
      final response = await apiClient.delete('/notifications/$notificationId');

      return ApiResponse(
        success: response.success,
        data: response.success,
        error: response.error,
      );
    } catch (e) {
      return handleError(e);
    }
  }

  /// Delete all notifications
  Future<ApiResponse<bool>> deleteAllNotifications() async {
    try {
      final response = await apiClient.delete('/notifications/all');

      return ApiResponse(
        success: response.success,
        data: response.success,
        error: response.error,
      );
    } catch (e) {
      return handleError(e);
    }
  }

  /// Register device for push notifications (OneSignal player ID)
  Future<ApiResponse<bool>> registerDevice({
    required String playerId,
    required String platform, // 'ios' or 'android'
  }) async {
    try {
      final response = await apiClient.post(
        '/notifications/register-device',
        data: {'player_id': playerId, 'platform': platform},
      );

      return ApiResponse(
        success: response.success,
        data: response.success,
        error: response.error,
      );
    } catch (e) {
      return handleError(e);
    }
  }

  /// Unregister device (on logout)
  Future<ApiResponse<bool>> unregisterDevice(String playerId) async {
    try {
      final response = await apiClient.delete(
        '/notifications/unregister-device/$playerId',
      );

      return ApiResponse(
        success: response.success,
        data: response.success,
        error: response.error,
      );
    } catch (e) {
      return handleError(e);
    }
  }
}
