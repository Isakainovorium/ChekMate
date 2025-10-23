import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chekmate/core/services/fcm_service.dart';
import 'package:flutter_chekmate/shared/ui/notifications/notification_card_widget.dart';

/// FCMExamplePage - Example Page
///
/// Demonstrates how to use FCM service for push notifications.
/// Shows FCM token, permission status, and notification handling.
///
/// Features:
/// - Display FCM token
/// - Request permissions
/// - Show notification examples
/// - Handle foreground/background messages
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (_) => FCMExamplePage()),
/// )
/// ```
class FCMExamplePage extends StatefulWidget {
  const FCMExamplePage({super.key});

  @override
  State<FCMExamplePage> createState() => _FCMExamplePageState();
}

class _FCMExamplePageState extends State<FCMExamplePage> {
  String? _fcmToken;
  AuthorizationStatus? _permissionStatus;
  final List<RemoteMessage> _messages = [];
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    try {
      // Initialize FCM
      await FCMService.initialize();

      // Get token
      final token = await FCMService.getToken();
      setState(() => _fcmToken = token);

      // Check permission
      final status = await FCMService.checkPermission();
      setState(() => _permissionStatus = status);

      // Listen to foreground messages
      FCMService.onMessage.listen((message) {
        setState(() {
          _messages.insert(0, message);
          _notificationCount++;
        });
      });

      // Listen to messages that opened the app
      FCMService.onMessageOpenedApp.listen((message) {
        _showMessageDialog(message);
      });

      // Listen to token refresh
      FCMService.onTokenRefresh.listen((token) {
        setState(() => _fcmToken = token);
      });
    } on Exception catch (e) {
      _showError('Failed to initialize FCM: $e');
    }
  }

  Future<void> _requestPermission() async {
    try {
      final settings = await FCMService.requestPermission();
      setState(() => _permissionStatus = settings.authorizationStatus);

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _showSuccess('Permission granted!');
      } else {
        _showError('Permission denied');
      }
    } on Exception catch (e) {
      _showError('Failed to request permission: $e');
    }
  }

  Future<void> _copyToken() async {
    if (_fcmToken != null) {
      await Clipboard.setData(ClipboardData(text: _fcmToken!));
      _showSuccess('Token copied to clipboard!');
    }
  }

  Future<void> _sendTestNotification() async {
    try {
      await FCMService.showLocalNotification(
        id: DateTime.now().millisecondsSinceEpoch,
        title: 'Test Notification',
        body: 'This is a test notification from ChekMate!',
        payload: 'test_payload',
      );
      _showSuccess('Test notification sent!');
    } on Exception catch (e) {
      _showError('Failed to send notification: $e');
    }
  }

  Future<void> _subscribeToTopic() async {
    try {
      await FCMService.subscribeToTopic('chekmate_updates');
      _showSuccess('Subscribed to chekmate_updates topic!');
    } on Exception catch (e) {
      _showError('Failed to subscribe: $e');
    }
  }

  Future<void> _unsubscribeFromTopic() async {
    try {
      await FCMService.unsubscribeFromTopic('chekmate_updates');
      _showSuccess('Unsubscribed from chekmate_updates topic!');
    } on Exception catch (e) {
      _showError('Failed to unsubscribe: $e');
    }
  }

  void _showMessageDialog(RemoteMessage message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message.notification?.title ?? 'Notification'),
        content: Text(message.notification?.body ?? 'No body'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FCM Example'),
        actions: [
          NotificationBadge(
            count: _notificationCount,
            child: IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                setState(() => _notificationCount = 0);
              },
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section 1: FCM Token
          const Text(
            '1. FCM Token',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _fcmToken ?? 'Loading...',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _copyToken,
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Token'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section 2: Permission Status
          const Text(
            '2. Permission Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(
                _permissionStatus == AuthorizationStatus.authorized
                    ? Icons.check_circle
                    : Icons.cancel,
                color: _permissionStatus == AuthorizationStatus.authorized
                    ? Colors.green
                    : Colors.red,
              ),
              title: Text(
                _permissionStatus?.toString() ?? 'Unknown',
              ),
              trailing: ElevatedButton(
                onPressed: _requestPermission,
                child: const Text('Request'),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section 3: Actions
          const Text(
            '3. Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _sendTestNotification,
            icon: const Icon(Icons.notifications),
            label: const Text('Send Test Notification'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _subscribeToTopic,
            icon: const Icon(Icons.add),
            label: const Text('Subscribe to Topic'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _unsubscribeFromTopic,
            icon: const Icon(Icons.remove),
            label: const Text('Unsubscribe from Topic'),
          ),
          const SizedBox(height: 24),

          // Section 4: Received Messages
          const Text(
            '4. Received Messages',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (_messages.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No messages received yet'),
              ),
            )
          else
            ..._messages.map(
              (message) => Card(
                child: ListTile(
                  leading: const Icon(Icons.message),
                  title: Text(message.notification?.title ?? 'No title'),
                  subtitle: Text(message.notification?.body ?? 'No body'),
                  trailing: Text(
                    DateTime.now().toString().substring(11, 19),
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () => _showMessageDialog(message),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
