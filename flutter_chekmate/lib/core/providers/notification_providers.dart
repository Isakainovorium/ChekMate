import 'package:flutter_chekmate/core/models/notification_model.dart';
import 'package:flutter_chekmate/core/providers/auth_providers.dart';
import 'package:flutter_chekmate/core/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notification Service Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Notifications Provider
/// Get all notifications for current user
final notificationsProvider =
    StreamProvider.autoDispose<List<NotificationModel>>((ref) {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) {
    return Stream.value([]);
  }

  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.getNotifications(currentUserId);
});

/// Unread Notifications Count Provider
final unreadNotificationsCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) return 0;

  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.getUnreadCount(currentUserId);
});

/// Notification Controller Provider
final notificationControllerProvider = Provider<NotificationController>((ref) {
  return NotificationController(ref);
});

/// Notification Controller
/// Manages notification actions
class NotificationController {
  NotificationController(this.ref);
  final Ref ref;

  NotificationService get _notificationService =>
      ref.read(notificationServiceProvider);
  String? get _currentUserId => ref.read(currentUserIdProvider);

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _notificationService.markAsRead(notificationId);

    // Invalidate unread count
    ref.invalidate(unreadNotificationsCountProvider);
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    await _notificationService.markAllAsRead(_currentUserId!);

    // Invalidate unread count
    ref.invalidate(unreadNotificationsCountProvider);
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _notificationService.deleteNotification(notificationId);

    // Invalidate notifications
    ref.invalidate(notificationsProvider);
  }

  /// Delete all notifications
  Future<void> deleteAllNotifications() async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    await _notificationService.deleteAllNotifications(_currentUserId!);

    // Invalidate notifications
    ref.invalidate(notificationsProvider);
  }
}
