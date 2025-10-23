import 'package:cloud_firestore/cloud_firestore.dart';

/// Notification Type Enum
enum NotificationType {
  like,
  comment,
  follow,
  chek,
  message,
  mention,
  rating,
  system,
}

/// Notification Model
/// Represents a user notification
class NotificationModel {
  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.actorId,
    this.actorName,
    this.actorAvatar,
    this.targetId,
    this.targetType,
    this.data,
    this.readAt,
  });

  /// Create NotificationModel from Firestore document
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type']}',
        orElse: () => NotificationType.system,
      ),
      title: json['title'] as String,
      message: json['message'] as String,
      actorId: json['actorId'] as String?,
      actorName: json['actorName'] as String?,
      actorAvatar: json['actorAvatar'] as String?,
      targetId: json['targetId'] as String?,
      targetType: json['targetType'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      readAt: json['readAt'] != null
          ? (json['readAt'] as Timestamp).toDate()
          : null,
    );
  }
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final String? actorId;
  final String? actorName;
  final String? actorAvatar;
  final String? targetId; // Post ID, User ID, etc.
  final String? targetType; // 'post', 'user', 'comment', etc.
  final Map<String, dynamic>? data; // Additional data
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  /// Convert NotificationModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'title': title,
      'message': message,
      'actorId': actorId,
      'actorName': actorName,
      'actorAvatar': actorAvatar,
      'targetId': targetId,
      'targetType': targetType,
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
    };
  }

  /// Get icon for notification type
  String getIcon() {
    switch (type) {
      case NotificationType.like:
        return '❤️';
      case NotificationType.comment:
        return '💬';
      case NotificationType.follow:
        return '👤';
      case NotificationType.chek:
        return '✓';
      case NotificationType.message:
        return '📨';
      case NotificationType.mention:
        return '@';
      case NotificationType.rating:
        return '⭐';
      case NotificationType.system:
        return '🔔';
    }
  }

  /// Create a copy with updated fields
  NotificationModel copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? message,
    String? actorId,
    String? actorName,
    String? actorAvatar,
    String? targetId,
    String? targetType,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      actorId: actorId ?? this.actorId,
      actorName: actorName ?? this.actorName,
      actorAvatar: actorAvatar ?? this.actorAvatar,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}
