import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/notifications/widgets/notification_item_widget.dart';
import 'package:flutter_chekmate/features/notifications/widgets/notifications_header_widget.dart';

/// Notifications Page - converted from Notifications.tsx
/// Shows list of user notifications
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          const NotificationsHeaderWidget(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              itemCount: MockNotifications.notifications.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey.shade100,
              ),
              itemBuilder: (context, index) {
                final notification = MockNotifications.notifications[index];
                return LegacyNotificationItemWidget(
                  userAvatar: notification.userAvatar,
                  userName: notification.userName,
                  action: notification.action,
                  timestamp: notification.timestamp,
                  postImage: notification.postImage,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Notification model
class NotificationModel {
  NotificationModel({
    required this.id,
    required this.userAvatar,
    required this.userName,
    required this.action,
    required this.timestamp,
    this.postImage,
  });
  final String id;
  final String userAvatar;
  final String userName;
  final String action;
  final String timestamp;
  final String? postImage;
}

/// Mock notifications data
class MockNotifications {
  static final List<NotificationModel> notifications = [
    NotificationModel(
      id: '1',
      userAvatar:
          'https://images.unsplash.com/photo-1618590067690-2db34a87750a',
      userName: 'Simone Gabrielle',
      action: 'Commented on your post.',
      timestamp: '3m ago',
      postImage: 'https://images.unsplash.com/photo-1758874089739-da0739746ea4',
    ),
    NotificationModel(
      id: '2',
      userAvatar:
          'https://images.unsplash.com/photo-1618590067690-2db34a87750a',
      userName: 'Simone Gabrielle',
      action: 'Liked your photo.',
      timestamp: '5m ago',
      postImage: 'https://images.unsplash.com/photo-1758874089739-da0739746ea4',
    ),
    NotificationModel(
      id: '3',
      userAvatar:
          'https://images.unsplash.com/photo-1618590067690-2db34a87750a',
      userName: 'Simone Gabrielle',
      action: 'Mentioned you in a comment.',
      timestamp: '2h ago',
      postImage: 'https://images.unsplash.com/photo-1758874089739-da0739746ea4',
    ),
    NotificationModel(
      id: '4',
      userAvatar:
          'https://images.unsplash.com/photo-1618590067690-2db34a87750a',
      userName: 'Simone Gabrielle',
      action: 'Shared your post.',
      timestamp: '3h ago',
      postImage: 'https://images.unsplash.com/photo-1758874089739-da0739746ea4',
    ),
    NotificationModel(
      id: '5',
      userAvatar:
          'https://images.unsplash.com/photo-1618590067690-2db34a87750a',
      userName: 'Simone Gabrielle',
      action: 'Commented on your photo.',
      timestamp: '5h ago',
      postImage: 'https://images.unsplash.com/photo-1758874089739-da0739746ea4',
    ),
    NotificationModel(
      id: '6',
      userAvatar:
          'https://images.unsplash.com/photo-1672685667592-0392f458f46f',
      userName: 'Tbabee100',
      action: 'Started following you.',
      timestamp: '7h ago',
      postImage: 'https://images.unsplash.com/photo-1758874089739-da0739746ea4',
    ),
    NotificationModel(
      id: '7',
      userAvatar:
          'https://images.unsplash.com/photo-1672685667592-0392f458f46f',
      userName: 'Tbabee100',
      action: 'Cheked your post',
      timestamp: 'Yesterday',
      postImage: 'https://images.unsplash.com/photo-1758874089739-da0739746ea4',
    ),
    NotificationModel(
      id: '8',
      userAvatar:
          'https://images.unsplash.com/photo-1672685667592-0392f458f46f',
      userName: 'Tbabee100',
      action: 'Cheked your post',
      timestamp: 'Yesterday',
      postImage: 'https://images.unsplash.com/photo-1758874089739-da0739746ea4',
    ),
  ];
}
