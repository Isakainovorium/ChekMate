import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/notifications/domain/entities/notification_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifications Providers
///
/// Riverpod providers for managing notification state and data.
///
/// Sprint 1 - Task 1.2.3
/// Date: November 28, 2025

/// Firestore instance provider
final _firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Stream of notifications for a user
final notificationsStreamProvider = StreamProvider.family<List<NotificationEntity>, String>(
  (ref, userId) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }

    final firestore = ref.watch(_firestoreProvider);

    return firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return NotificationEntity.fromFirestore(
          doc.data(),
          doc.id,
        );
      }).toList();
    });
  },
);

/// Filtered notifications based on current filter
final filteredNotificationsProvider = Provider.family<List<NotificationEntity>, String>(
  (ref, userId) {
    final notificationsAsync = ref.watch(notificationsStreamProvider(userId));
    final filter = ref.watch(notificationFilterProvider);

    return notificationsAsync.when(
      data: (notifications) {
        switch (filter) {
          case NotificationFilter.all:
            return notifications;
          case NotificationFilter.unread:
            return notifications.where((n) => !n.isRead).toList();
          case NotificationFilter.mentions:
            return notifications
                .where((n) => n.type == NotificationType.mention)
                .toList();
          case NotificationFilter.ratings:
            return notifications
                .where((n) => n.type == NotificationType.rating)
                .toList();
          case NotificationFilter.safety:
            return notifications
                .where((n) => n.type == NotificationType.safety)
                .toList();
        }
      },
      loading: () => [],
      error: (_, __) => [],
    );
  },
);

/// Current notification filter
final notificationFilterProvider = StateProvider<NotificationFilter>((ref) {
  return NotificationFilter.all;
});

/// Unread notification count
final unreadNotificationCountProvider = Provider.family<int, String>(
  (ref, userId) {
    final notificationsAsync = ref.watch(notificationsStreamProvider(userId));

    return notificationsAsync.when(
      data: (notifications) => notifications.where((n) => !n.isRead).length,
      loading: () => 0,
      error: (_, __) => 0,
    );
  },
);

/// Priority (safety) notification count
final priorityNotificationCountProvider = Provider.family<int, String>(
  (ref, userId) {
    final notificationsAsync = ref.watch(notificationsStreamProvider(userId));

    return notificationsAsync.when(
      data: (notifications) =>
          notifications.where((n) => n.isPriority && !n.isRead).length,
      loading: () => 0,
      error: (_, __) => 0,
    );
  },
);

/// Notifications controller for actions
class NotificationsController extends StateNotifier<AsyncValue<void>> {
  NotificationsController(this._firestore, this._userId)
      : super(const AsyncValue.data(null));

  final FirebaseFirestore _firestore;
  final String _userId;

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    if (_userId.isEmpty) return;

    state = const AsyncValue.loading();
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (_userId.isEmpty) return;

    state = const AsyncValue.loading();
    try {
      final batch = _firestore.batch();
      final unreadDocs = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in unreadDocs.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    if (_userId.isEmpty) return;

    state = const AsyncValue.loading();
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notifications')
          .doc(notificationId)
          .delete();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    if (_userId.isEmpty) return;

    state = const AsyncValue.loading();
    try {
      final batch = _firestore.batch();
      final allDocs = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notifications')
          .get();

      for (final doc in allDocs.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider for notifications controller
final notificationsControllerProvider = StateNotifierProvider.family<
    NotificationsController, AsyncValue<void>, String>(
  (ref, userId) {
    final firestore = ref.watch(_firestoreProvider);
    return NotificationsController(firestore, userId);
  },
);

/// Mock notifications for development/testing
class MockNotifications {
  static List<NotificationEntity> get sampleNotifications => [
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
          body: 'Mike rated your date as WOW! 🎉',
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
          body: 'Jessica commented: "This is so relatable! 😂"',
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
          title: '⚠️ Community Safety Alert',
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
          body: '@ChekMate_User was mentioned in a discussion about first dates',
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
