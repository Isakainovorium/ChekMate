import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level function for handling background messages
/// Must be a top-level function or static method
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
  if (kDebugMode) {
    debugPrint('[FCM] Handling background message: ${message.messageId}');
    debugPrint('[FCM] Title: ${message.notification?.title}');
    debugPrint('[FCM] Body: ${message.notification?.body}');
    debugPrint('[FCM] Data: ${message.data}');
  }
}

/// FCMService - Firebase Cloud Messaging Service
///
/// Handles Firebase Cloud Messaging (FCM) and local notifications.
/// Manages notification permissions, token management, and message handling.
///
/// Features:
/// - FCM integration
/// - Local notifications
/// - Permission handling
/// - Token management
/// - Foreground/background/terminated message handling
///
/// Usage:
/// ```dart
/// await FCMService.initialize();
/// final token = await FCMService.getToken();
/// ```
class FCMService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;
  static String? _fcmToken;

  // Stream controllers for notification events
  static final StreamController<RemoteMessage> _messageStreamController =
      StreamController<RemoteMessage>.broadcast();
  static final StreamController<String> _tokenStreamController =
      StreamController<String>.broadcast();
  static final StreamController<RemoteMessage> _messageOpenedAppController =
      StreamController<RemoteMessage>.broadcast();

  /// Stream of foreground messages
  static Stream<RemoteMessage> get onMessage => _messageStreamController.stream;

  /// Stream of token updates
  static Stream<String> get onTokenRefresh => _tokenStreamController.stream;

  /// Stream of messages that opened the app
  static Stream<RemoteMessage> get onMessageOpenedApp =>
      _messageOpenedAppController.stream;

  /// Initialize FCM service
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request permission
      await requestPermission();

      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        debugPrint('[FCM] FCM Token: $_fcmToken');
      }

      // Listen to token refresh
      _firebaseMessaging.onTokenRefresh.listen((token) {
        _fcmToken = token;
        _tokenStreamController.add(token);
        if (kDebugMode) {
          debugPrint('[FCM] FCM Token refreshed: $token');
        }
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          debugPrint('[FCM] Foreground message received: ${message.messageId}');
        }
        _messageStreamController.add(message);
        _handleForegroundMessage(message);
      });

      // Handle background messages (when app is in background but not terminated)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          debugPrint('[FCM] Message opened app: ${message.messageId}');
        }
        _messageOpenedAppController.add(message);
      });

      // Check if app was opened from a terminated state
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        if (kDebugMode) {
          debugPrint(
            '[FCM] App opened from terminated state: ${initialMessage.messageId}',
          );
        }
        _messageOpenedAppController.add(initialMessage);
      }

      _initialized = true;
      if (kDebugMode) {
        debugPrint('[FCM] FCMService initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FCM] Error initializing FCMService: $e');
      }
      throw FCMServiceException('Failed to initialize: $e');
    }
  }

  /// Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    // Android initialization settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    const androidChannel = AndroidNotificationChannel(
      'chekmate_channel',
      'ChekMate Notifications',
      description: 'Notifications for ChekMate app',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      debugPrint('[FCM] Notification tapped: ${response.payload}');
    }
    // Payload can be used to navigate to specific screens
  }

  /// Handle foreground message
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      await showLocalNotification(
        id: message.hashCode,
        title: notification.title ?? 'ChekMate',
        body: notification.body ?? '',
        payload: message.data.toString(),
        imageUrl: android?.imageUrl,
      );
    }
  }

  /// Request notification permission
  static Future<NotificationSettings> requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission();

    if (kDebugMode) {
      debugPrint(
        '[FCM] Notification permission status: ${settings.authorizationStatus}',
      );
    }
    return settings;
  }

  /// Check notification permission status
  static Future<AuthorizationStatus> checkPermission() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus;
  }

  /// Get FCM token
  static Future<String?> getToken() async {
    if (_fcmToken != null) return _fcmToken;
    _fcmToken = await _firebaseMessaging.getToken();
    return _fcmToken;
  }

  /// Delete FCM token
  static Future<void> deleteToken() async {
    await _firebaseMessaging.deleteToken();
    _fcmToken = null;
  }

  /// Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    if (kDebugMode) {
      debugPrint('[FCM] Subscribed to topic: $topic');
    }
  }

  /// Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    if (kDebugMode) {
      debugPrint('[FCM] Unsubscribed from topic: $topic');
    }
  }

  /// Show local notification
  static Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'chekmate_channel',
      'ChekMate Notifications',
      channelDescription: 'Notifications for ChekMate app',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Schedule local notification
  /// Note: Requires timezone package for scheduling
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    // For now, use basic scheduling without timezone package
    // This can be enhanced later with timezone package for advanced scheduling
    final scheduledNotificationDateTime = scheduledDate;
    
    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      channelDescription: 'Scheduled notifications for ChekMate',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    // Use zonedSchedule for scheduling notifications
    // For basic implementation, we'll show immediate notification if scheduled time is in the past
    if (scheduledNotificationDateTime.isBefore(DateTime.now())) {
      await _localNotifications.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } else {
      // For future implementation with timezone package:
      // await _localNotifications.zonedSchedule(...)
      // For now, just show immediate notification with a note
      await _localNotifications.show(
        id,
        '$title (Scheduled)',
        '$body\n\nNote: Advanced scheduling requires timezone package',
        notificationDetails,
        payload: payload,
      );
    }
  }

  /// Cancel notification
  static Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Get pending notifications
  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    return _localNotifications.pendingNotificationRequests();
  }

  /// Set badge count (iOS only)
  static Future<void> setBadgeCount(int count) async {
    await _firebaseMessaging.setAutoInitEnabled(true);
    // Note: Badge count is managed by iOS automatically
    // This is a placeholder for future implementation
  }

  /// Clear badge count (iOS only)
  static Future<void> clearBadgeCount() async {
    await setBadgeCount(0);
  }

  /// Dispose resources
  static void dispose() {
    _messageStreamController.close();
    _tokenStreamController.close();
    _messageOpenedAppController.close();
  }
}

/// FCMServiceException - Custom exception for FCM errors
class FCMServiceException implements Exception {
  const FCMServiceException(this.message);
  final String message;

  @override
  String toString() => 'FCMServiceException: $message';
}
