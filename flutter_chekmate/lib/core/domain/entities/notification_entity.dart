import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Notification Type Enum
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

/// Notification Entity
///
/// Represents a notification in the ChekMate application.
/// Used for displaying user notifications throughout the app.
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
  final String? senderId;
  final String? senderName;
  final String? senderAvatar;

  /// Get icon for notification type
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

  /// Get time ago string (e.g., "5 minutes ago", "2 hours ago")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return minutes == 1 ? '1 minute ago' : '$minutes minutes ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return hours == 1 ? '1 hour ago' : '$hours hours ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return days == 1 ? '1 day ago' : '$days days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    }
  }

  /// Check if notification is recent (less than 24 hours old)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24;
  }

  /// Check if notification was created today
  bool get isToday {
    final now = DateTime.now();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }

  /// Get formatted date string (e.g., "Oct 17, 2025 at 2:30 PM")
  String get formattedDate {
    final dateFormat = DateFormat('MMM d, y \'at\' h:mm a');
    return dateFormat.format(createdAt);
  }

  /// Check if notification requires user action
  bool get requiresAction {
    return type == NotificationType.follow || type == NotificationType.message;
  }

  /// Get action button text based on notification type
  String get actionButtonText {
    switch (type) {
      case NotificationType.follow:
        return 'Follow Back';
      case NotificationType.message:
        return 'Reply';
      default:
        return 'View';
    }
  }

  /// Create a copy with updated properties
  NotificationEntity copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? isRead,
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
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        title,
        body,
        createdAt,
        isRead,
        senderId,
        senderName,
        senderAvatar,
      ];
}

