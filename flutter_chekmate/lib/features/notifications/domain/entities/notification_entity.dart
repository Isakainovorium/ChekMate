/// Notification Entity
///
/// Domain entity representing a user notification in the ChekMate app.
/// Notifications inform users about community activity, ratings, mentions,
/// and safety alerts.
///
/// Sprint 1 - Task 1.2.1
/// Date: November 28, 2025

/// Types of notifications in ChekMate
enum NotificationType {
  /// Someone liked your experience post
  like,

  /// Someone commented on your post
  comment,

  /// Someone rated your date (WOW/GTFOH/ChekMate)
  rating,

  /// Someone followed you
  follow,

  /// You were @mentioned in a post or comment
  mention,

  /// Community safety alert (high priority)
  safety,

  /// System notification (updates, announcements)
  system,
}

/// Rating types for the Rate Your Date feature
enum RatingType {
  /// "That's Amazing; Sweet!" - Exceptional dates
  wow,

  /// "NOT RECOMMENDED" - Bad experiences
  gtfoh,

  /// "Smart Play" - Outsmarted a tricky situation
  chekmate,
}

/// Notification entity
class NotificationEntity {
  const NotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    this.actorId,
    this.actorName,
    this.actorAvatar,
    this.targetId,
    this.targetType,
    this.ratingType,
    this.isRead = false,
    this.isPriority = false,
    this.actionUrl,
    this.metadata,
  });

  /// Unique notification ID
  final String id;

  /// Type of notification
  final NotificationType type;

  /// Notification title
  final String title;

  /// Notification body/message
  final String body;

  /// When the notification was created
  final DateTime timestamp;

  /// ID of the user who triggered the notification (if applicable)
  final String? actorId;

  /// Name of the user who triggered the notification
  final String? actorName;

  /// Avatar URL of the user who triggered the notification
  final String? actorAvatar;

  /// ID of the target content (post, comment, etc.)
  final String? targetId;

  /// Type of target content ('post', 'comment', 'profile', etc.)
  final String? targetType;

  /// Rating type if this is a rating notification
  final RatingType? ratingType;

  /// Whether the notification has been read
  final bool isRead;

  /// Whether this is a priority notification (safety alerts)
  final bool isPriority;

  /// Deep link URL for the notification action
  final String? actionUrl;

  /// Additional metadata
  final Map<String, dynamic>? metadata;

  /// Create a copy with updated fields
  NotificationEntity copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    DateTime? timestamp,
    String? actorId,
    String? actorName,
    String? actorAvatar,
    String? targetId,
    String? targetType,
    RatingType? ratingType,
    bool? isRead,
    bool? isPriority,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      actorId: actorId ?? this.actorId,
      actorName: actorName ?? this.actorName,
      actorAvatar: actorAvatar ?? this.actorAvatar,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      ratingType: ratingType ?? this.ratingType,
      isRead: isRead ?? this.isRead,
      isPriority: isPriority ?? this.isPriority,
      actionUrl: actionUrl ?? this.actionUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Create from Firestore document
  factory NotificationEntity.fromFirestore(Map<String, dynamic> data, String id) {
    return NotificationEntity(
      id: id,
      type: NotificationType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => NotificationType.system,
      ),
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      timestamp: data['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int)
          : DateTime.now(),
      actorId: data['actorId'] as String?,
      actorName: data['actorName'] as String?,
      actorAvatar: data['actorAvatar'] as String?,
      targetId: data['targetId'] as String?,
      targetType: data['targetType'] as String?,
      ratingType: data['ratingType'] != null
          ? RatingType.values.firstWhere(
              (r) => r.name == data['ratingType'],
              orElse: () => RatingType.wow,
            )
          : null,
      isRead: data['isRead'] as bool? ?? false,
      isPriority: data['isPriority'] as bool? ?? false,
      actionUrl: data['actionUrl'] as String?,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'type': type.name,
      'title': title,
      'body': body,
      'timestamp': timestamp.millisecondsSinceEpoch,
      if (actorId != null) 'actorId': actorId,
      if (actorName != null) 'actorName': actorName,
      if (actorAvatar != null) 'actorAvatar': actorAvatar,
      if (targetId != null) 'targetId': targetId,
      if (targetType != null) 'targetType': targetType,
      if (ratingType != null) 'ratingType': ratingType!.name,
      'isRead': isRead,
      'isPriority': isPriority,
      if (actionUrl != null) 'actionUrl': actionUrl,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Get icon for notification type
  String get iconName {
    switch (type) {
      case NotificationType.like:
        return 'favorite';
      case NotificationType.comment:
        return 'chat_bubble';
      case NotificationType.rating:
        return 'star';
      case NotificationType.follow:
        return 'person_add';
      case NotificationType.mention:
        return 'alternate_email';
      case NotificationType.safety:
        return 'warning';
      case NotificationType.system:
        return 'notifications';
    }
  }

  /// Get color for notification type
  String get colorHex {
    switch (type) {
      case NotificationType.like:
        return '#FF6B6B'; // Red
      case NotificationType.comment:
        return '#4ECDC4'; // Teal
      case NotificationType.rating:
        return '#F5A623'; // Gold
      case NotificationType.follow:
        return '#1E3A8A'; // Navy
      case NotificationType.mention:
        return '#9B59B6'; // Purple
      case NotificationType.safety:
        return '#E74C3C'; // Alert Red
      case NotificationType.system:
        return '#95A5A6'; // Gray
    }
  }

  /// Format timestamp for display
  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NotificationEntity(id: $id, type: $type, title: $title, isRead: $isRead)';
  }
}

/// Filter options for notifications list
enum NotificationFilter {
  /// Show all notifications
  all,

  /// Show only unread notifications
  unread,

  /// Show only mentions
  mentions,

  /// Show only ratings
  ratings,

  /// Show only safety alerts
  safety,
}
