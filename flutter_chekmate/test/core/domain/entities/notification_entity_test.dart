import 'package:flutter_chekmate/core/domain/entities/notification_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationEntity', () {
    late NotificationEntity notification;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime.now().subtract(const Duration(hours: 2));
      notification = NotificationEntity(
        id: 'test-id',
        userId: 'user-123',
        type: NotificationType.like,
        title: 'New Like',
        body: 'John liked your post',
        createdAt: testDate,
        isRead: false,
        senderId: 'sender-123',
        senderName: 'John Doe',
        senderAvatar: 'https://example.com/avatar.jpg',
      );
    });

    group('icon getter', () {
      test('returns correct icon for like notification', () {
        final likeNotification = notification.copyWith(type: NotificationType.like);
        expect(likeNotification.icon, '❤️');
      });

      test('returns correct icon for comment notification', () {
        final commentNotification = notification.copyWith(type: NotificationType.comment);
        expect(commentNotification.icon, '💬');
      });

      test('returns correct icon for follow notification', () {
        final followNotification = notification.copyWith(type: NotificationType.follow);
        expect(followNotification.icon, '👤');
      });

      test('returns correct icon for message notification', () {
        final messageNotification = notification.copyWith(type: NotificationType.message);
        expect(messageNotification.icon, '✉️');
      });

      test('returns correct icon for mention notification', () {
        final mentionNotification = notification.copyWith(type: NotificationType.mention);
        expect(mentionNotification.icon, '@');
      });

      test('returns correct icon for share notification', () {
        final shareNotification = notification.copyWith(type: NotificationType.share);
        expect(shareNotification.icon, '🔄');
      });

      test('returns correct icon for chek notification', () {
        final chekNotification = notification.copyWith(type: NotificationType.chek);
        expect(chekNotification.icon, '✓');
      });

      test('returns correct icon for story notification', () {
        final storyNotification = notification.copyWith(type: NotificationType.story);
        expect(storyNotification.icon, '📸');
      });

      test('returns correct icon for system notification', () {
        final systemNotification = notification.copyWith(type: NotificationType.system);
        expect(systemNotification.icon, '🔔');
      });
    });

    group('timeAgo getter', () {
      test('returns "Just now" for notifications less than 60 seconds old', () {
        final recentNotification = notification.copyWith(
          createdAt: DateTime.now().subtract(const Duration(seconds: 30)),
        );
        expect(recentNotification.timeAgo, 'Just now');
      });

      test('returns correct minutes for notifications less than 1 hour old', () {
        final minutesNotification = notification.copyWith(
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        );
        expect(minutesNotification.timeAgo, '5 minutes ago');
      });

      test('returns singular "minute" for 1 minute old notification', () {
        final oneMinuteNotification = notification.copyWith(
          createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
        );
        expect(oneMinuteNotification.timeAgo, '1 minute ago');
      });

      test('returns correct hours for notifications less than 24 hours old', () {
        final hoursNotification = notification.copyWith(
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        );
        expect(hoursNotification.timeAgo, '3 hours ago');
      });

      test('returns singular "hour" for 1 hour old notification', () {
        final oneHourNotification = notification.copyWith(
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        );
        expect(oneHourNotification.timeAgo, '1 hour ago');
      });

      test('returns correct days for notifications less than 7 days old', () {
        final daysNotification = notification.copyWith(
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        );
        expect(daysNotification.timeAgo, '3 days ago');
      });

      test('returns singular "day" for 1 day old notification', () {
        final oneDayNotification = notification.copyWith(
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(oneDayNotification.timeAgo, '1 day ago');
      });

      test('returns correct weeks for notifications less than 30 days old', () {
        final weeksNotification = notification.copyWith(
          createdAt: DateTime.now().subtract(const Duration(days: 14)),
        );
        expect(weeksNotification.timeAgo, '2 weeks ago');
      });

      test('returns singular "week" for 1 week old notification', () {
        final oneWeekNotification = notification.copyWith(
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
        );
        expect(oneWeekNotification.timeAgo, '1 week ago');
      });

      test('returns correct months for notifications less than 365 days old', () {
        final monthsNotification = notification.copyWith(
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
        );
        expect(monthsNotification.timeAgo, '2 months ago');
      });

      test('returns singular "month" for 1 month old notification', () {
        final oneMonthNotification = notification.copyWith(
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        );
        expect(oneMonthNotification.timeAgo, '1 month ago');
      });

      test('returns correct years for notifications more than 365 days old', () {
        final yearsNotification = notification.copyWith(
          createdAt: DateTime.now().subtract(const Duration(days: 730)),
        );
        expect(yearsNotification.timeAgo, '2 years ago');
      });

      test('returns singular "year" for 1 year old notification', () {
        final oneYearNotification = notification.copyWith(
          createdAt: DateTime.now().subtract(const Duration(days: 365)),
        );
        expect(oneYearNotification.timeAgo, '1 year ago');
      });
    });

    group('isRecent getter', () {
      test('returns true for notifications less than 24 hours old', () {
        final recentNotification = notification.copyWith(
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        );
        expect(recentNotification.isRecent, true);
      });

      test('returns false for notifications more than 24 hours old', () {
        final oldNotification = notification.copyWith(
          createdAt: DateTime.now().subtract(const Duration(hours: 25)),
        );
        expect(oldNotification.isRecent, false);
      });

      test('returns true for notifications exactly 23 hours old', () {
        final borderlineNotification = notification.copyWith(
          createdAt: DateTime.now().subtract(const Duration(hours: 23)),
        );
        expect(borderlineNotification.isRecent, true);
      });
    });

    group('isToday getter', () {
      test('returns true for notifications created today', () {
        final todayNotification = notification.copyWith(
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        );
        expect(todayNotification.isToday, true);
      });

      test('returns false for notifications created yesterday', () {
        final yesterdayNotification = notification.copyWith(
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(yesterdayNotification.isToday, false);
      });
    });

    group('formattedDate getter', () {
      test('returns formatted date string', () {
        final testNotification = notification.copyWith(
          createdAt: DateTime(2025, 10, 17, 14, 30),
        );
        expect(testNotification.formattedDate, 'Oct 17, 2025 at 2:30 PM');
      });
    });

    group('requiresAction getter', () {
      test('returns true for follow notifications', () {
        final followNotification = notification.copyWith(type: NotificationType.follow);
        expect(followNotification.requiresAction, true);
      });

      test('returns true for message notifications', () {
        final messageNotification = notification.copyWith(type: NotificationType.message);
        expect(messageNotification.requiresAction, true);
      });

      test('returns false for like notifications', () {
        final likeNotification = notification.copyWith(type: NotificationType.like);
        expect(likeNotification.requiresAction, false);
      });

      test('returns false for comment notifications', () {
        final commentNotification = notification.copyWith(type: NotificationType.comment);
        expect(commentNotification.requiresAction, false);
      });
    });

    group('actionButtonText getter', () {
      test('returns "Follow Back" for follow notifications', () {
        final followNotification = notification.copyWith(type: NotificationType.follow);
        expect(followNotification.actionButtonText, 'Follow Back');
      });

      test('returns "Reply" for message notifications', () {
        final messageNotification = notification.copyWith(type: NotificationType.message);
        expect(messageNotification.actionButtonText, 'Reply');
      });

      test('returns "View" for other notification types', () {
        final likeNotification = notification.copyWith(type: NotificationType.like);
        expect(likeNotification.actionButtonText, 'View');
      });
    });

    group('Equatable', () {
      test('two notifications with same properties are equal', () {
        final notification1 = NotificationEntity(
          id: 'test-id',
          userId: 'user-123',
          type: NotificationType.like,
          title: 'Test',
          body: 'Test body',
          createdAt: testDate,
          isRead: false,
        );

        final notification2 = NotificationEntity(
          id: 'test-id',
          userId: 'user-123',
          type: NotificationType.like,
          title: 'Test',
          body: 'Test body',
          createdAt: testDate,
          isRead: false,
        );

        expect(notification1, notification2);
      });

      test('two notifications with different properties are not equal', () {
        final notification1 = NotificationEntity(
          id: 'test-id-1',
          userId: 'user-123',
          type: NotificationType.like,
          title: 'Test',
          body: 'Test body',
          createdAt: testDate,
          isRead: false,
        );

        final notification2 = NotificationEntity(
          id: 'test-id-2',
          userId: 'user-123',
          type: NotificationType.like,
          title: 'Test',
          body: 'Test body',
          createdAt: testDate,
          isRead: false,
        );

        expect(notification1, isNot(notification2));
      });
    });

    group('copyWith', () {
      test('creates new instance with updated properties', () {
        final updatedNotification = notification.copyWith(
          isRead: true,
          title: 'Updated Title',
        );

        expect(updatedNotification.isRead, true);
        expect(updatedNotification.title, 'Updated Title');
        expect(updatedNotification.id, notification.id);
        expect(updatedNotification.userId, notification.userId);
      });

      test('preserves original properties when not specified', () {
        final updatedNotification = notification.copyWith(isRead: true);

        expect(updatedNotification.title, notification.title);
        expect(updatedNotification.body, notification.body);
        expect(updatedNotification.type, notification.type);
      });
    });
  });
}

