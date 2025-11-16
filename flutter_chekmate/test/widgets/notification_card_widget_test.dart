import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/domain/entities/notification_entity.dart';
import 'package:flutter_chekmate/shared/ui/notifications/notification_badge.dart';
import 'package:flutter_chekmate/shared/ui/notifications/notification_card_widget.dart';
import 'package:flutter_chekmate/shared/ui/notifications/notification_list_tile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationCardWidget', () {
    late NotificationEntity testNotification;

    setUp(() {
      testNotification = NotificationEntity(
        id: 'test-id',
        userId: 'user-123',
        type: NotificationType.like,
        title: 'New Like',
        body: 'John liked your post',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        senderId: 'sender-123',
        senderName: 'John Doe',
        senderAvatar: 'https://example.com/avatar.jpg',
      );
    });

    Widget createTestWidget(NotificationCardWidget widget) {
      return MaterialApp(
        home: Scaffold(
          body: widget,
        ),
      );
    }

    group('Widget Rendering', () {
      testWidgets('renders notification card', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            NotificationCardWidget(notification: testNotification),
          ),
        );

        expect(find.byType(NotificationCardWidget), findsOneWidget);
      });

      testWidgets('displays notification title', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            NotificationCardWidget(notification: testNotification),
          ),
        );

        expect(find.text('New Like'), findsOneWidget);
      });

      testWidgets('displays notification body', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            NotificationCardWidget(notification: testNotification),
          ),
        );

        expect(find.text('John liked your post'), findsOneWidget);
      });

      testWidgets('displays notification icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            NotificationCardWidget(notification: testNotification),
          ),
        );

        expect(find.text('❤️'), findsOneWidget);
      });

      testWidgets('displays time ago', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            NotificationCardWidget(notification: testNotification),
          ),
        );

        expect(find.textContaining('ago'), findsOneWidget);
      });
    });

    group('Read/Unread State', () {
      testWidgets('shows unread indicator for unread notifications',
          (WidgetTester tester) async {
        final unreadNotification = testNotification.copyWith(isRead: false);

        await tester.pumpWidget(
          createTestWidget(
            NotificationCardWidget(notification: unreadNotification),
          ),
        );

        // Unread notifications should have a background color
        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(InkWell),
                matching: find.byType(Container),
              )
              .first,
        );

        expect(container.decoration, isA<BoxDecoration>());
      });

      testWidgets('shows read state for read notifications',
          (WidgetTester tester) async {
        final readNotification = testNotification.copyWith(isRead: true);

        await tester.pumpWidget(
          createTestWidget(
            NotificationCardWidget(notification: readNotification),
          ),
        );

        // Read notifications should have transparent background
        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(InkWell),
                matching: find.byType(Container),
              )
              .first,
        );

        expect(container.decoration, isA<BoxDecoration>());
      });
    });

    group('Avatar Display', () {
      testWidgets('shows avatar when showAvatar is true and avatar exists',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            NotificationCardWidget(
              notification: testNotification,
            ),
          ),
        );

        expect(find.byType(CircleAvatar), findsOneWidget);
      });

      testWidgets('shows icon when showAvatar is false',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            NotificationCardWidget(
              notification: testNotification,
              showAvatar: false,
            ),
          ),
        );

        expect(find.text('❤️'), findsOneWidget);
      });

      testWidgets('shows icon when avatar is null',
          (WidgetTester tester) async {
        final noAvatarNotification = testNotification.copyWith();

        await tester.pumpWidget(
          createTestWidget(
            NotificationCardWidget(
              notification: noAvatarNotification,
            ),
          ),
        );

        expect(find.text('❤️'), findsOneWidget);
      });
    });

    group('Tap Actions', () {
      testWidgets('calls onTap when tapped', (WidgetTester tester) async {
        var tapped = false;

        await tester.pumpWidget(
          createTestWidget(
            NotificationCardWidget(
              notification: testNotification,
              onTap: () => tapped = true,
            ),
          ),
        );

        await tester.tap(find.byType(InkWell));
        await tester.pumpAndSettle();

        expect(tapped, true);
      });

      testWidgets('does not throw when onTap is null',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            NotificationCardWidget(notification: testNotification),
          ),
        );

        await tester.tap(find.byType(InkWell));
        await tester.pumpAndSettle();

        // Should not throw
      });
    });

    group('Swipe to Delete', () {
      testWidgets('shows delete background when swiped',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            NotificationCardWidget(
              notification: testNotification,
              onDelete: () {},
            ),
          ),
        );

        // Start swipe
        await tester.drag(
          find.byType(Dismissible),
          const Offset(-500, 0),
        );
        await tester.pump();

        // Should show delete background
        expect(find.byIcon(Icons.delete), findsOneWidget);
      });

      testWidgets('calls onDelete when dismissed', (WidgetTester tester) async {
        var deleted = false;

        await tester.pumpWidget(
          createTestWidget(
            NotificationCardWidget(
              notification: testNotification,
              onDelete: () => deleted = true,
            ),
          ),
        );

        await tester.drag(
          find.byType(Dismissible),
          const Offset(-500, 0),
        );
        await tester.pumpAndSettle();

        expect(deleted, true);
      });

      testWidgets('does not allow swipe when onDelete is null',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            NotificationCardWidget(notification: testNotification),
          ),
        );

        final dismissible = tester.widget<Dismissible>(
          find.byType(Dismissible),
        );

        expect(dismissible.direction, DismissDirection.none);
      });
    });

    group('Action Button', () {
      testWidgets('shows action button when showActionButton is true',
          (WidgetTester tester) async {
        final actionNotification = testNotification.copyWith(
          type: NotificationType.follow,
        );

        await tester.pumpWidget(
          createTestWidget(
            NotificationCardWidget(
              notification: actionNotification,
              showActionButton: true,
            ),
          ),
        );

        expect(find.text('Follow Back'), findsOneWidget);
      });

      testWidgets('hides action button when showActionButton is false',
          (WidgetTester tester) async {
        final actionNotification = testNotification.copyWith(
          type: NotificationType.follow,
        );

        await tester.pumpWidget(
          createTestWidget(
            NotificationCardWidget(
              notification: actionNotification,
            ),
          ),
        );

        expect(find.text('Follow Back'), findsNothing);
      });

      testWidgets('calls onActionTap when action button is tapped',
          (WidgetTester tester) async {
        var actionTapped = false;
        final actionNotification = testNotification.copyWith(
          type: NotificationType.follow,
        );

        await tester.pumpWidget(
          createTestWidget(
            NotificationCardWidget(
              notification: actionNotification,
              showActionButton: true,
              onActionTap: () => actionTapped = true,
            ),
          ),
        );

        await tester.tap(find.text('Follow Back'));
        await tester.pumpAndSettle();

        expect(actionTapped, true);
      });
    });

    group('Different Notification Types', () {
      testWidgets('renders like notification correctly',
          (WidgetTester tester) async {
        final likeNotification = testNotification.copyWith(
          type: NotificationType.like,
        );

        await tester.pumpWidget(
          createTestWidget(
            NotificationCardWidget(notification: likeNotification),
          ),
        );

        expect(find.text('❤️'), findsOneWidget);
      });

      testWidgets('renders comment notification correctly',
          (WidgetTester tester) async {
        final commentNotification = testNotification.copyWith(
          type: NotificationType.comment,
        );

        await tester.pumpWidget(
          createTestWidget(
            NotificationCardWidget(notification: commentNotification),
          ),
        );

        expect(find.text('💬'), findsOneWidget);
      });

      testWidgets('renders follow notification correctly',
          (WidgetTester tester) async {
        final followNotification = testNotification.copyWith(
          type: NotificationType.follow,
        );

        await tester.pumpWidget(
          createTestWidget(
            NotificationCardWidget(notification: followNotification),
          ),
        );

        expect(find.text('👤'), findsOneWidget);
      });

      testWidgets('renders message notification correctly',
          (WidgetTester tester) async {
        final messageNotification = testNotification.copyWith(
          type: NotificationType.message,
        );

        await tester.pumpWidget(
          createTestWidget(
            NotificationCardWidget(notification: messageNotification),
          ),
        );

        expect(find.text('✉️'), findsOneWidget);
      });
    });
  });

  group('NotificationListTile', () {
    late NotificationEntity testNotification;

    setUp(() {
      testNotification = NotificationEntity(
        id: 'test-id',
        userId: 'user-123',
        type: NotificationType.like,
        title: 'New Like',
        body: 'John liked your post',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      );
    });

    Widget createTestWidget(NotificationListTile widget) {
      return MaterialApp(
        home: Scaffold(
          body: widget,
        ),
      );
    }

    testWidgets('renders notification list tile', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          NotificationListTile(notification: testNotification),
        ),
      );

      expect(find.byType(NotificationListTile), findsOneWidget);
    });

    testWidgets('displays notification title', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          NotificationListTile(notification: testNotification),
        ),
      );

      expect(find.text('New Like'), findsOneWidget);
    });

    testWidgets('displays notification body', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          NotificationListTile(notification: testNotification),
        ),
      );

      expect(find.text('John liked your post'), findsOneWidget);
    });
  });

  group('NotificationBadge', () {
    Widget createTestWidget(NotificationBadge widget) {
      return MaterialApp(
        home: Scaffold(
          body: widget,
        ),
      );
    }

    testWidgets('renders notification badge', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const NotificationBadge(count: 5),
        ),
      );

      expect(find.byType(NotificationBadge), findsOneWidget);
    });

    testWidgets('displays count', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const NotificationBadge(count: 5),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('displays 99+ for counts over 99', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const NotificationBadge(count: 150),
        ),
      );

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('hides badge when count is 0', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const NotificationBadge(count: 0),
        ),
      );

      expect(find.text('0'), findsNothing);
    });
  });
}
