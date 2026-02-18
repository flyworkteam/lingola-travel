import 'package:equatable/equatable.dart';

/// Notification Model - Represents an in-app notification
class NotificationModel extends Equatable {
  final String id;
  final String? userId; // null for broadcast notifications
  final String icon; // Emoji or icon path
  final String title;
  final String message;
  final bool isPremiumPromo; // Sticky for free users
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    this.userId,
    required this.icon,
    required this.title,
    required this.message,
    this.isPremiumPromo = false,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      icon: json['icon'] as String? ?? '🔔',
      title: json['title'] as String,
      message: json['message'] as String,
      isPremiumPromo: (json['is_premium_promo'] as int? ?? 0) == 1,
      isRead: (json['is_read'] as int? ?? 0) == 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'icon': icon,
      'title': title,
      'message': message,
      'is_premium_promo': isPremiumPromo ? 1 : 0,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? icon,
    String? title,
    String? message,
    bool? isPremiumPromo,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      icon: icon ?? this.icon,
      title: title ?? this.title,
      message: message ?? this.message,
      isPremiumPromo: isPremiumPromo ?? this.isPremiumPromo,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get formatted time (e.g., "2h ago", "Yesterday")
  String getFormattedTime() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    icon,
    title,
    message,
    isPremiumPromo,
    isRead,
    createdAt,
  ];
}
