import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/core/models/notification_model.dart';

/// Notification Service
/// Handles all notification operations
class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a notification
  Future<String> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String message,
    String? actorId,
    String? actorName,
    String? actorAvatar,
    String? targetId,
    String? targetType,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notificationId = _firestore.collection('notifications').doc().id;
      final now = DateTime.now();

      final notification = NotificationModel(
        id: notificationId,
        userId: userId,
        type: type,
        title: title,
        message: message,
        actorId: actorId,
        actorName: actorName,
        actorAvatar: actorAvatar,
        targetId: targetId,
        targetType: targetType,
        data: data,
        isRead: false,
        createdAt: now,
      );

      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .set(notification.toJson());

      return notificationId;
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  /// Create a like notification
  Future<void> createLikeNotification({
    required String postOwnerId,
    required String likerId,
    required String likerName,
    required String likerAvatar,
    required String postId,
  }) async {
    // Don't notify if user likes their own post
    if (postOwnerId == likerId) return;

    await createNotification(
      userId: postOwnerId,
      type: NotificationType.like,
      title: 'New Like',
      message: '$likerName liked your post',
      actorId: likerId,
      actorName: likerName,
      actorAvatar: likerAvatar,
      targetId: postId,
      targetType: 'post',
    );
  }

  /// Create a follow notification
  Future<void> createFollowNotification({
    required String followedUserId,
    required String followerId,
    required String followerName,
    required String followerAvatar,
  }) async {
    await createNotification(
      userId: followedUserId,
      type: NotificationType.follow,
      title: 'New Follower',
      message: '$followerName started following you',
      actorId: followerId,
      actorName: followerName,
      actorAvatar: followerAvatar,
      targetId: followerId,
      targetType: 'user',
    );
  }

  /// Create a chek notification
  Future<void> createChekNotification({
    required String postOwnerId,
    required String chekerId,
    required String chekerName,
    required String chekerAvatar,
    required String postId,
  }) async {
    // Don't notify if user cheks their own post
    if (postOwnerId == chekerId) return;

    await createNotification(
      userId: postOwnerId,
      type: NotificationType.chek,
      title: 'New Chek',
      message: '$chekerName cheked your post',
      actorId: chekerId,
      actorName: chekerName,
      actorAvatar: chekerAvatar,
      targetId: postId,
      targetType: 'post',
    );
  }

  /// Create a comment notification
  Future<void> createCommentNotification({
    required String postOwnerId,
    required String commenterId,
    required String commenterName,
    required String commenterAvatar,
    required String postId,
    required String commentText,
  }) async {
    // Don't notify if user comments on their own post
    if (postOwnerId == commenterId) return;

    await createNotification(
      userId: postOwnerId,
      type: NotificationType.comment,
      title: 'New Comment',
      message: '$commenterName commented: $commentText',
      actorId: commenterId,
      actorName: commenterName,
      actorAvatar: commenterAvatar,
      targetId: postId,
      targetType: 'post',
      data: {'commentText': commentText},
    );
  }

  /// Create a message notification
  Future<void> createMessageNotification({
    required String receiverId,
    required String senderId,
    required String senderName,
    required String senderAvatar,
    required String messagePreview,
  }) async {
    await createNotification(
      userId: receiverId,
      type: NotificationType.message,
      title: 'New Message',
      message: '$senderName sent you a message',
      actorId: senderId,
      actorName: senderName,
      actorAvatar: senderAvatar,
      targetId: senderId,
      targetType: 'user',
      data: {'messagePreview': messagePreview},
    );
  }

  /// Create a mention notification
  Future<void> createMentionNotification({
    required String mentionedUserId,
    required String mentionerId,
    required String mentionerName,
    required String mentionerAvatar,
    required String postId,
  }) async {
    await createNotification(
      userId: mentionedUserId,
      type: NotificationType.mention,
      title: 'You were mentioned',
      message: '$mentionerName mentioned you in a post',
      actorId: mentionerId,
      actorName: mentionerName,
      actorAvatar: mentionerAvatar,
      targetId: postId,
      targetType: 'post',
    );
  }

  /// Create a rating notification
  Future<void> createRatingNotification({
    required String ratedUserId,
    required String raterId,
    required String raterName,
    required String raterAvatar,
    required int rating,
  }) async {
    await createNotification(
      userId: ratedUserId,
      type: NotificationType.rating,
      title: 'New Rating',
      message: '$raterName rated you $rating stars',
      actorId: raterId,
      actorName: raterName,
      actorAvatar: raterAvatar,
      targetId: raterId,
      targetType: 'user',
      data: {'rating': rating},
    );
  }

  /// Get notifications for a user (real-time stream)
  Stream<List<NotificationModel>> getNotifications(String userId,
      {int limit = 50,}) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromJson(doc.data()))
          .toList();
    });
  }

  /// Get unread notifications count
  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      final unreadNotifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      if (unreadNotifications.docs.isEmpty) return;

      final batch = _firestore.batch();

      for (final doc in unreadNotifications.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  /// Delete all notifications for a user
  Future<void> deleteAllNotifications(String userId) async {
    try {
      final notifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      if (notifications.docs.isEmpty) return;

      final batch = _firestore.batch();

      for (final doc in notifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete all notifications: $e');
    }
  }
}
