import 'dart:async';
import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// FCM Service Exception
class FCMServiceException implements Exception {
  const FCMServiceException(this.message);

  final String message;

  @override
  String toString() => 'FCMServiceException: $message';
}

/// FCM Service
/// Handles Firebase Cloud Messaging and local notifications
class FCMService {
  FCMService._();

  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Streams for FCM events
  static Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;
  static Stream<String> get onTokenRefresh => _firebaseMessaging.onTokenRefresh;
  static Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  /// Initialize FCM service
  static Future<void> initialize() async {
    try {
      // Request permission for iOS
      if (Platform.isIOS) {
        await _firebaseMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
      }

      // Initialize local notifications
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(settings);

      // Create notification channel for Android
      if (Platform.isAndroid) {
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'high_importance_channel',
          'High Importance Notifications',
          description: 'This channel is used for important notifications.',
          importance: Importance.high,
          playSound: true,
        );

        await _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);
      }

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (e) {
      throw FCMServiceException('Failed to initialize FCM service: $e');
    }
  }

  /// Request notification permission
  static Future<NotificationSettings> requestPermission() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      return settings;
    } catch (e) {
      throw FCMServiceException('Failed to request permission: $e');
    }
  }

  /// Check current permission status
  static Future<NotificationSettings> checkPermission() async {
    try {
      final settings = await _firebaseMessaging.getNotificationSettings();
      return settings;
    } catch (e) {
      throw FCMServiceException('Failed to check permission: $e');
    }
  }

  /// Get FCM token
  static Future<String?> getToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      throw FCMServiceException('Failed to get token: $e');
    }
  }

  /// Delete FCM token
  static Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
    } catch (e) {
      throw FCMServiceException('Failed to delete token: $e');
    }
  }

  /// Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    if (topic.isEmpty) {
      throw const FCMServiceException('Topic cannot be empty');
    }

    // Validate topic format (FCM topics must match [a-zA-Z0-9-_.~%]+)
    final topicRegex = RegExp(r'^[a-zA-Z0-9\-_.~%]+$');
    if (!topicRegex.hasMatch(topic)) {
      throw FCMServiceException('Invalid topic format: $topic');
    }

    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      throw FCMServiceException('Failed to subscribe to topic $topic: $e');
    }
  }

  /// Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    if (topic.isEmpty) {
      throw const FCMServiceException('Topic cannot be empty');
    }

    // Validate topic format
    final topicRegex = RegExp(r'^[a-zA-Z0-9\-_.~%]+$');
    if (!topicRegex.hasMatch(topic)) {
      throw FCMServiceException('Invalid topic format: $topic');
    }

    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
      throw FCMServiceException('Failed to unsubscribe from topic $topic: $e');
    }
  }

  /// Show local notification
  static Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
    NotificationDetails? notificationDetails,
  }) async {
    final details = notificationDetails ??
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        );

    await _localNotifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Get pending notifications (Android only)
  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    final pendingNotifications =
        await _localNotifications.pendingNotificationRequests();
    return pendingNotifications;
  }
}

/// Background message handler
/// Exposed for testing purposes
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages here
  // This function cannot access Flutter widgets or plugins directly
}
