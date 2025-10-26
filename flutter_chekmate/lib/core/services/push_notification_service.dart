import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Push notification service for web
/// Handles web push notifications for re-engagement
class PushNotificationService {
  // Singleton pattern
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  static const String _permissionKey = 'push_notification_permission';
  static const String _subscribedKey = 'push_notification_subscribed';

  bool _isInitialized = false;
  bool _isSubscribed = false;
  String? _subscriptionEndpoint;

  /// Initialize push notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _isSubscribed = prefs.getBool(_subscribedKey) ?? false;

      if (kDebugMode) {
        debugPrint('[Push Notifications] Initialized. Subscribed: $_isSubscribed');
      }

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Push Notifications] Initialization error: $e');
      }
    }
  }

  /// Request permission for push notifications
  Future<bool> requestPermission() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // For web, we would use the Notification API
      // This is a placeholder implementation
      // In production, you would use:
      // final permission = await html.Notification.requestPermission();

      // Simulate permission request
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // For now, assume permission is granted
      final granted = true;

      await prefs.setBool(_permissionKey, granted);

      if (kDebugMode) {
        debugPrint('[Push Notifications] Permission ${granted ? 'granted' : 'denied'}');
      }

      return granted;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Push Notifications] Permission request error: $e');
      }
      return false;
    }
  }

  /// Subscribe to push notifications
  Future<bool> subscribe() async {
    try {
      if (_isSubscribed) {
        if (kDebugMode) {
          debugPrint('[Push Notifications] Already subscribed');
        }
        return true;
      }

      // Request permission first
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        return false;
      }

      // In production, you would:
      // 1. Get service worker registration
      // 2. Subscribe to push manager
      // 3. Send subscription to your backend
      // 4. Store subscription details

      // Simulate subscription
      await Future<void>.delayed(const Duration(milliseconds: 500));

      _isSubscribed = true;
      _subscriptionEndpoint = 'https://fcm.googleapis.com/fcm/send/mock-endpoint';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_subscribedKey, true);

      if (kDebugMode) {
        debugPrint('[Push Notifications] Subscribed successfully');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Push Notifications] Subscription error: $e');
      }
      return false;
    }
  }

  /// Unsubscribe from push notifications
  Future<bool> unsubscribe() async {
    try {
      if (!_isSubscribed) {
        if (kDebugMode) {
          debugPrint('[Push Notifications] Not subscribed');
        }
        return true;
      }

      // In production, you would:
      // 1. Get service worker registration
      // 2. Unsubscribe from push manager
      // 3. Notify your backend

      // Simulate unsubscription
      await Future<void>.delayed(const Duration(milliseconds: 500));

      _isSubscribed = false;
      _subscriptionEndpoint = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_subscribedKey, false);

      if (kDebugMode) {
        debugPrint('[Push Notifications] Unsubscribed successfully');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Push Notifications] Unsubscription error: $e');
      }
      return false;
    }
  }

  /// Check if subscribed to push notifications
  bool get isSubscribed => _isSubscribed;

  /// Get subscription endpoint
  String? get subscriptionEndpoint => _subscriptionEndpoint;

  /// Schedule a local notification (for testing)
  Future<void> scheduleLocalNotification({
    required String title,
    required String body,
    Duration delay = const Duration(seconds: 5),
  }) async {
    if (kDebugMode) {
      debugPrint('[Push Notifications] Scheduling notification: $title');
    }

    // In production, this would trigger a service worker notification
    // For now, we just log it
    await Future<void>.delayed(delay);

    if (kDebugMode) {
      debugPrint('[Push Notifications] Notification triggered: $title - $body');
    }
  }

  /// Send notification to backend (for triggering push)
  Future<bool> sendNotificationToBackend({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('[Push Notifications] Sending to backend: $title');
      }

      // In production, you would:
      // 1. Call your backend API
      // 2. Backend sends push notification via FCM/VAPID
      // 3. Service worker receives and displays notification

      // Simulate API call
      await Future<void>.delayed(const Duration(milliseconds: 500));

      if (kDebugMode) {
        debugPrint('[Push Notifications] Sent to backend successfully');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Push Notifications] Backend send error: $e');
      }
      return false;
    }
  }

  /// Get notification permission status
  Future<String> getPermissionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final granted = prefs.getBool(_permissionKey) ?? false;

      if (granted) {
        return 'granted';
      } else {
        return 'default';
      }
    } catch (e) {
      return 'default';
    }
  }

  /// Check if notifications are supported
  bool get isSupported {
    // In production, check if browser supports notifications
    // For now, assume supported on web
    return kIsWeb;
  }
}

/// Notification types for ChekMate
enum NotificationType {
  newLike,
  newComment,
  newFollower,
  newMessage,
  ratingReminder,
  streakReminder,
  weeklyDigest,
}

/// Notification data model
class NotificationData {
  NotificationData({
    required this.type,
    required this.title,
    required this.body,
    this.userId,
    this.postId,
    this.actionUrl,
    this.imageUrl,
  });

  final NotificationType type;
  final String title;
  final String body;
  final String? userId;
  final String? postId;
  final String? actionUrl;
  final String? imageUrl;

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'title': title,
      'body': body,
      'userId': userId,
      'postId': postId,
      'actionUrl': actionUrl,
      'imageUrl': imageUrl,
    };
  }
}

