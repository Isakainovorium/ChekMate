import 'package:equatable/equatable.dart';

/// NotificationEntity - Domain Layer
///
/// Pure Dart class representing a notification in the ChekMate app.
/// Contains no framework dependencies - only business logic.
///
/// Clean Architecture: Domain Layer
class NotificationEntity extends Equatable {
  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    this.imageUrl,
    this.data,
    this.actionUrl,
    this.senderId,
    this.senderName,
    this.senderAvatar,
  });

  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? imageUrl;
  final Map<String, dynamic>? data;
  final String? actionUrl;
  final String? senderId;
  final String? senderName;
  final String? senderAvatar;

  // ========== BUSINESS LOGIC METHODS ==========

  /// Get notification icon based on type
  String get icon {
    switch (type) {
      case NotificationType.like:
        return '❤️';
      case NotificationType.comment:
        return '💬';
      case NotificationType.follow:
        return '👤';
      case NotificationType.message:
        return '✉️';
      case NotificationType.mention:
        return '@';
      case NotificationType.share:
        return '🔄';
      case NotificationType.chek:
        return '✓';
      case NotificationType.story:
        return '📸';
      case NotificationType.system:
        return '🔔';
    }
  }

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Check if notification is recent (within 24 hours)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24;
  }

  /// Check if notification is today
  bool get isToday {
    final now = DateTime.now();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }

  /// Get formatted date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (isToday) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${createdAt.month}/${createdAt.day}/${createdAt.year}';
    }
  }

  /// Check if notification requires action
  bool get requiresAction {
    return type == NotificationType.follow ||
        type == NotificationType.message ||
        type == NotificationType.mention;
  }

  /// Get action button text
  String? get actionButtonText {
    switch (type) {
      case NotificationType.follow:
        return 'Follow Back';
      case NotificationType.message:
        return 'Reply';
      case NotificationType.mention:
        return 'View';
      default:
        return null;
    }
  }

  // ========== EQUATABLE ==========

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        title,
        body,
        createdAt,
        isRead,
        imageUrl,
        data,
        actionUrl,
        senderId,
        senderName,
        senderAvatar,
      ];

  // ========== COPY WITH ==========

  NotificationEntity copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? isRead,
    String? imageUrl,
    Map<String, dynamic>? data,
    String? actionUrl,
    String? senderId,
    String? senderName,
    String? senderAvatar,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
      actionUrl: actionUrl ?? this.actionUrl,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
    );
  }

  // ========== TO STRING ==========

  @override
  String toString() {
    return 'NotificationEntity(id: $id, type: $type, title: $title, isRead: $isRead)';
  }
}

/// NotificationType - Enum for notification types
enum NotificationType {
  like,
  comment,
  follow,
  message,
  mention,
  share,
  chek,
  story,
  system,
}

/// Extension for NotificationType
extension NotificationTypeExtension on NotificationType {
  String get name {
    switch (this) {
      case NotificationType.like:
        return 'like';
      case NotificationType.comment:
        return 'comment';
      case NotificationType.follow:
        return 'follow';
      case NotificationType.message:
        return 'message';
      case NotificationType.mention:
        return 'mention';
      case NotificationType.share:
        return 'share';
      case NotificationType.chek:
        return 'chek';
      case NotificationType.story:
        return 'story';
      case NotificationType.system:
        return 'system';
    }
  }

  static NotificationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'like':
        return NotificationType.like;
      case 'comment':
        return NotificationType.comment;
      case 'follow':
        return NotificationType.follow;
      case 'message':
        return NotificationType.message;
      case 'mention':
        return NotificationType.mention;
      case 'share':
        return NotificationType.share;
      case 'chek':
        return NotificationType.chek;
      case 'story':
        return NotificationType.story;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.system;
    }
  }
}

