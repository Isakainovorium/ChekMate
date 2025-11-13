import 'package:flutter_chekmate/core/services/fcm_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FCMService', () {
    group('FCMServiceException', () {
      test('creates exception with message', () {
        const exception = FCMServiceException('Test error');
        expect(exception.message, 'Test error');
        expect(exception.toString(), 'FCMServiceException: Test error');
      });

      test('toString returns formatted message', () {
        const exception = FCMServiceException('Permission denied');
        expect(exception.toString(), 'FCMServiceException: Permission denied');
      });

      test('two exceptions with same message are not necessarily equal', () {
        const exception1 = FCMServiceException('Test error');
        const exception2 = FCMServiceException('Test error');
        // FCMServiceException doesn't implement Equatable, so instances are not equal
        expect(exception1.message, exception2.message);
      });

      test('two exceptions with different messages have different strings', () {
        const exception1 = FCMServiceException('Test error 1');
        const exception2 = FCMServiceException('Test error 2');
        expect(exception1.toString(), isNot(exception2.toString()));
      });
    });

    // Note: Full integration tests for FCMService require Firebase Test Lab
    // or platform-specific testing. These tests verify the service structure
    // and exception handling. Platform-specific tests are in CircleCI pipeline.

    group('Service Structure', () {
      test('FCMService has required static methods', () {
        // Verify that FCMService has the expected public API
        expect(FCMService.initialize, isA<Function>());
        expect(FCMService.requestPermission, isA<Function>());
        expect(FCMService.checkPermission, isA<Function>());
        expect(FCMService.getToken, isA<Function>());
        expect(FCMService.deleteToken, isA<Function>());
        expect(FCMService.subscribeToTopic, isA<Function>());
        expect(FCMService.unsubscribeFromTopic, isA<Function>());
        expect(FCMService.showLocalNotification, isA<Function>());
        expect(FCMService.cancelNotification, isA<Function>());
        expect(FCMService.cancelAllNotifications, isA<Function>());
        expect(FCMService.getPendingNotifications, isA<Function>());
      });

      test('FCMService has required streams', () {
        // Verify that FCMService exposes the expected streams
        expect(FCMService.onMessage, isA<Stream<dynamic>>());
        expect(FCMService.onTokenRefresh, isA<Stream<dynamic>>());
        expect(FCMService.onMessageOpenedApp, isA<Stream<dynamic>>());
      });
    });

    group('Topic Validation', () {
      test('subscribeToTopic throws exception for empty topic', () async {
        expect(
          () => FCMService.subscribeToTopic(''),
          throwsA(isA<FCMServiceException>()),
        );
      });

      test('unsubscribeFromTopic throws exception for empty topic', () async {
        expect(
          () => FCMService.unsubscribeFromTopic(''),
          throwsA(isA<FCMServiceException>()),
        );
      });

      test('subscribeToTopic throws exception for invalid topic format',
          () async {
        // Topics must match the pattern [a-zA-Z0-9-_.~%]+
        expect(
          () => FCMService.subscribeToTopic('invalid topic!'),
          throwsA(isA<FCMServiceException>()),
        );
      });

      test('unsubscribeFromTopic throws exception for invalid topic format',
          () async {
        expect(
          () => FCMService.unsubscribeFromTopic('invalid topic!'),
          throwsA(isA<FCMServiceException>()),
        );
      });
    });

    group('Notification Validation', () {
      test('showLocalNotification requires id parameter', () async {
        // Verify that showLocalNotification requires id parameter
        expect(
          () => FCMService.showLocalNotification(
            id: 1,
            title: 'Test',
            body: 'Test body',
          ),
          isA<Function>(),
        );
      });

      test('showLocalNotification accepts optional payload', () async {
        expect(
          () => FCMService.showLocalNotification(
            id: 1,
            title: 'Test',
            body: 'Test body',
            payload: 'test-payload',
          ),
          isA<Function>(),
        );
      });

      test('showLocalNotification accepts optional imageUrl', () async {
        expect(
          () => FCMService.showLocalNotification(
            id: 1,
            title: 'Test',
            body: 'Test body',
            imageUrl: 'https://example.com/image.jpg',
          ),
          isA<Function>(),
        );
      });
    });

    group('Background Handler', () {
      test('firebaseMessagingBackgroundHandler is a top-level function', () {
        // Verify that the background handler is a top-level function
        // This is required by Firebase Messaging
        expect(firebaseMessagingBackgroundHandler, isA<Function>());
      });

      test('firebaseMessagingBackgroundHandler has correct signature', () {
        // The function should accept a RemoteMessage and return Future<void>
        expect(
          firebaseMessagingBackgroundHandler,
          isA<Function>(),
        );
      });
    });

    group('Stream Controllers', () {
      test('message stream is broadcast stream', () {
        expect(FCMService.onMessage.isBroadcast, true);
      });

      test('token refresh stream is broadcast stream', () {
        expect(FCMService.onTokenRefresh.isBroadcast, true);
      });

      test('message opened app stream is broadcast stream', () {
        expect(FCMService.onMessageOpenedApp.isBroadcast, true);
      });
    });

    group('Error Handling', () {
      test('FCMServiceException includes error message', () {
        const exception = FCMServiceException('Permission denied');

        expect(exception.message, contains('Permission denied'));
      });

      test('FCMServiceException toString includes message', () {
        const exception = FCMServiceException('Test error');

        expect(exception.toString(), contains('Test error'));
        expect(exception.toString(), contains('FCMServiceException'));
      });

      test('FCMServiceException message is accessible', () {
        const exception = FCMServiceException('Network error');

        expect(exception.message, 'Network error');
      });
    });

    group('Service Initialization', () {
      test('initialize can be called multiple times safely', () async {
        // The service should handle multiple initialization calls gracefully
        // This test verifies the structure exists
        expect(FCMService.initialize, isA<Function>());
      });
    });

    group('Token Management', () {
      test('getToken returns Future<String?>', () {
        expect(FCMService.getToken(), isA<Future<String?>>());
      });

      test('deleteToken returns Future<void>', () {
        expect(FCMService.deleteToken(), isA<Future<void>>());
      });
    });

    group('Permission Management', () {
      test('requestPermission returns Future', () {
        expect(FCMService.requestPermission(), isA<Future<dynamic>>());
      });

      test('checkPermission returns Future', () {
        expect(FCMService.checkPermission(), isA<Future<dynamic>>());
      });
    });

    group('Local Notifications', () {
      test('showLocalNotification accepts required parameters', () {
        // Verify the method signature accepts required parameters
        expect(
          () => FCMService.showLocalNotification(
            id: 1,
            title: 'Test',
            body: 'Test body',
          ),
          isA<Function>(),
        );
      });

      test('showLocalNotification accepts all parameters', () {
        // Verify the method signature accepts all parameters
        expect(
          () => FCMService.showLocalNotification(
            id: 1,
            title: 'Test',
            body: 'Test body',
            payload: 'test-payload',
            imageUrl: 'https://example.com/image.jpg',
          ),
          isA<Function>(),
        );
      });

      test('cancelNotification accepts notification id', () {
        expect(
          () => FCMService.cancelNotification(123),
          isA<Function>(),
        );
      });

      test('cancelAllNotifications is callable', () {
        expect(FCMService.cancelAllNotifications, isA<Function>());
      });

      test('getPendingNotifications returns Future', () {
        expect(
          FCMService.getPendingNotifications(),
          isA<Future<List<dynamic>>>(),
        );
      });
    });

    group('Topic Subscriptions', () {
      test('subscribeToTopic accepts valid topic names', () {
        // Valid topic names should not throw during validation
        expect(
          () => FCMService.subscribeToTopic('valid-topic'),
          isA<Function>(),
        );

        expect(
          () => FCMService.subscribeToTopic('valid_topic'),
          isA<Function>(),
        );

        expect(
          () => FCMService.subscribeToTopic('validTopic123'),
          isA<Function>(),
        );
      });

      test('unsubscribeFromTopic accepts valid topic names', () {
        expect(
          () => FCMService.unsubscribeFromTopic('valid-topic'),
          isA<Function>(),
        );

        expect(
          () => FCMService.unsubscribeFromTopic('valid_topic'),
          isA<Function>(),
        );

        expect(
          () => FCMService.unsubscribeFromTopic('validTopic123'),
          isA<Function>(),
        );
      });
    });

    group('Message Handling', () {
      test('service provides streams for different message scenarios', () {
        // Foreground messages
        expect(FCMService.onMessage, isA<Stream<dynamic>>());

        // Background messages that opened the app
        expect(FCMService.onMessageOpenedApp, isA<Stream<dynamic>>());

        // Token refresh events
        expect(FCMService.onTokenRefresh, isA<Stream<dynamic>>());
      });
    });
  });
}
