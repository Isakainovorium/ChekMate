import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/notifications/domain/entities/notification_entity.dart';

/// Notifications Repository
///
/// Data layer for managing notification data from Firestore.
/// Provides CRUD operations and real-time streams for notifications.
///
/// Sprint 1 - Task 1.2.2
/// Date: November 28, 2025

abstract class NotificationsRepository {
  /// Stream of notifications for a user
  Stream<List<NotificationEntity>> watchNotifications(String userId);

  /// Get a single notification by ID
  Future<NotificationEntity?> getNotification(String userId, String notificationId);

  /// Mark a notification as read
  Future<void> markAsRead(String userId, String notificationId);

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId);

  /// Delete a notification
  Future<void> deleteNotification(String userId, String notificationId);

  /// Clear all notifications
  Future<void> clearAll(String userId);

  /// Get unread count
  Future<int> getUnreadCount(String userId);

  /// Create a notification (for testing/admin)
  Future<void> createNotification(String userId, NotificationEntity notification);
}

/// Firestore implementation of NotificationsRepository
class FirestoreNotificationsRepository implements NotificationsRepository {
  FirestoreNotificationsRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Get the notifications collection reference for a user
  CollectionReference<Map<String, dynamic>> _notificationsRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications');
  }

  @override
  Stream<List<NotificationEntity>> watchNotifications(String userId) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }

    return _notificationsRef(userId)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return NotificationEntity.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Future<NotificationEntity?> getNotification(
    String userId,
    String notificationId,
  ) async {
    if (userId.isEmpty || notificationId.isEmpty) {
      return null;
    }

    final doc = await _notificationsRef(userId).doc(notificationId).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return NotificationEntity.fromFirestore(doc.data()!, doc.id);
  }

  @override
  Future<void> markAsRead(String userId, String notificationId) async {
    if (userId.isEmpty || notificationId.isEmpty) return;

    await _notificationsRef(userId).doc(notificationId).update({
      'isRead': true,
    });
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    if (userId.isEmpty) return;

    final batch = _firestore.batch();
    final unreadDocs = await _notificationsRef(userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in unreadDocs.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  @override
  Future<void> deleteNotification(String userId, String notificationId) async {
    if (userId.isEmpty || notificationId.isEmpty) return;

    await _notificationsRef(userId).doc(notificationId).delete();
  }

  @override
  Future<void> clearAll(String userId) async {
    if (userId.isEmpty) return;

    final batch = _firestore.batch();
    final allDocs = await _notificationsRef(userId).get();

    for (final doc in allDocs.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    if (userId.isEmpty) return 0;

    final snapshot = await _notificationsRef(userId)
        .where('isRead', isEqualTo: false)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  @override
  Future<void> createNotification(
    String userId,
    NotificationEntity notification,
  ) async {
    if (userId.isEmpty) return;

    await _notificationsRef(userId).doc(notification.id).set(
          notification.toFirestore(),
        );
  }
}

/// Mock implementation for testing and development
class MockNotificationsRepository implements NotificationsRepository {
  final List<NotificationEntity> _notifications = [];

  MockNotificationsRepository() {
    // Initialize with sample data
    _notifications.addAll(_sampleNotifications);
  }

  @override
  Stream<List<NotificationEntity>> watchNotifications(String userId) {
    return Stream.value(_notifications);
  }

  @override
  Future<NotificationEntity?> getNotification(
    String userId,
    String notificationId,
  ) async {
    try {
      return _notifications.firstWhere((n) => n.id == notificationId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> markAsRead(String userId, String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  @override
  Future<void> deleteNotification(String userId, String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
  }

  @override
  Future<void> clearAll(String userId) async {
    _notifications.clear();
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    return _notifications.where((n) => !n.isRead).length;
  }

  @override
  Future<void> createNotification(
    String userId,
    NotificationEntity notification,
  ) async {
    _notifications.insert(0, notification);
  }

  /// Sample notifications for development
  static List<NotificationEntity> get _sampleNotifications => [
        NotificationEntity(
          id: '1',
          type: NotificationType.like,
          title: 'New Like',
          body: 'Sarah liked your dating experience story',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          actorId: 'user_sarah',
          actorName: 'Sarah',
          actorAvatar: 'https://i.pravatar.cc/150?u=sarah',
          targetId: 'post_123',
          targetType: 'post',
        ),
        NotificationEntity(
          id: '2',
          type: NotificationType.rating,
          title: 'New Rating',
          body: 'Mike rated your date as WOW!',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          actorId: 'user_mike',
          actorName: 'Mike',
          actorAvatar: 'https://i.pravatar.cc/150?u=mike',
          targetId: 'date_456',
          targetType: 'date',
          ratingType: RatingType.wow,
        ),
        NotificationEntity(
          id: '3',
          type: NotificationType.comment,
          title: 'New Comment',
          body: 'Jessica commented: "This is so relatable!"',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          actorId: 'user_jessica',
          actorName: 'Jessica',
          actorAvatar: 'https://i.pravatar.cc/150?u=jessica',
          targetId: 'post_789',
          targetType: 'post',
        ),
        NotificationEntity(
          id: '4',
          type: NotificationType.safety,
          title: 'Community Safety Alert',
          body:
              'A user in your area has been reported for suspicious behavior. Stay safe!',
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
          isPriority: true,
        ),
        NotificationEntity(
          id: '5',
          type: NotificationType.follow,
          title: 'New Follower',
          body: 'Alex started following you',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          actorId: 'user_alex',
          actorName: 'Alex',
          actorAvatar: 'https://i.pravatar.cc/150?u=alex',
          isRead: true,
        ),
        NotificationEntity(
          id: '6',
          type: NotificationType.mention,
          title: 'You were mentioned',
          body: 'You were mentioned in a discussion about first dates',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          actorId: 'user_chris',
          actorName: 'Chris',
          actorAvatar: 'https://i.pravatar.cc/150?u=chris',
          targetId: 'post_101',
          targetType: 'post',
          isRead: true,
        ),
      ];
}
