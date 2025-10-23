import 'package:flutter/material.dart';

import 'package:flutter_chekmate/core/models/notification_model.dart';
import 'package:flutter_chekmate/core/providers/notification_providers.dart';
import 'package:flutter_chekmate/features/notifications/widgets/notification_item_widget.dart';
import 'package:flutter_chekmate/features/notifications/widgets/notifications_header_widget.dart';
import 'package:flutter_chekmate/shared/ui/animations/micro_interactions.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Notifications Page - converted from Notifications.tsx
/// Enhanced with staggered animations and pulsing badge
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final unreadCountAsync = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          NotificationsHeaderWidget(
            unreadCount: unreadCountAsync.valueOrNull ?? 0,
            onMarkAllRead: () {
              ref.read(notificationControllerProvider).markAllAsRead();
            },
          ),
          Expanded(
            child: notificationsAsync.when(
              data: (notifications) {
                if (notifications.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.notifications_none,
                    title: 'No notifications yet',
                    message:
                        'When you get notifications, they\'ll show up here.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => const AppSeparator(),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Dismissible(
                      key: Key(notification.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        _handleNotificationDismiss(ref, notification);
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      child: NotificationItemWidget(
                        notification: notification,
                        onTap: () =>
                            _handleNotificationTap(context, ref, notification),
                        onDismiss: () =>
                            _handleNotificationDismiss(ref, notification),
                      ).staggeredFadeIn(
                        index: index,
                        delay: const Duration(milliseconds: 60),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: AppLoadingSpinner(),
              ),
              error: (error, stack) => AppEmptyState(
                icon: Icons.error_outline,
                title: 'Error loading notifications',
                message: error.toString(),
                action: AppButton(
                  onPressed: () => ref.refresh(notificationsProvider),
                  child: const Text('Retry'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notification,
  ) {
    // Mark as read
    if (!notification.isRead) {
      ref.read(notificationControllerProvider).markAsRead(notification.id);
    }

    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.like:
      case NotificationType.comment:
      case NotificationType.chek:
        // Navigate to post detail
        if (notification.targetId != null) {
          context.push('/post/${notification.targetId}');
        }
      case NotificationType.follow:
      case NotificationType.rating:
        // Navigate to user profile
        if (notification.actorId != null) {
          context.push('/profile/${notification.actorId}');
        }
      case NotificationType.message:
        // Navigate to chat conversation
        if (notification.actorId != null && notification.targetId != null) {
          context.push(
            '/chat/${notification.targetId}?userId=${notification.actorId}&userName=${notification.actorName ?? "User"}',
          );
        }
      case NotificationType.mention:
        // Navigate to post or comment where mentioned
        if (notification.targetId != null) {
          context.push('/post/${notification.targetId}');
        }
      case NotificationType.system:
        // No navigation for system notifications
        break;
    }
  }

  void _handleNotificationDismiss(
    WidgetRef ref,
    NotificationModel notification,
  ) {
    ref
        .read(notificationControllerProvider)
        .deleteNotification(notification.id);
  }
}

/// Mock notification model for backward compatibility
class MockNotificationModel {
  MockNotificationModel({
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

/// Mock notifications data for testing
class MockNotifications {
  static final List<MockNotificationModel> notifications = [
    MockNotificationModel(
      id: '1',
      userAvatar:
          'https://images.unsplash.com/photo-1618590067690-2db34a87750a',
      userName: 'Simone Gabrielle',
      action: 'Commented on your post.',
      timestamp: '3m ago',
      postImage: 'https://images.unsplash.com/photo-1758874089739-da0739746ea4',
    ),
    MockNotificationModel(
      id: '2',
      userAvatar:
          'https://images.unsplash.com/photo-1618590067690-2db34a87750a',
      userName: 'Simone Gabrielle',
      action: 'Liked your photo.',
      timestamp: '5m ago',
      postImage: 'https://images.unsplash.com/photo-1758874089739-da0739746ea4',
    ),
    MockNotificationModel(
      id: '3',
      userAvatar:
          'https://images.unsplash.com/photo-1618590067690-2db34a87750a',
      userName: 'Simone Gabrielle',
      action: 'Mentioned you in a comment.',
      timestamp: '2h ago',
      postImage: 'https://images.unsplash.com/photo-1758874089739-da0739746ea4',
    ),
    MockNotificationModel(
      id: '4',
      userAvatar:
          'https://images.unsplash.com/photo-1618590067690-2db34a87750a',
      userName: 'Simone Gabrielle',
      action: 'Shared your post.',
      timestamp: '3h ago',
      postImage: 'https://images.unsplash.com/photo-1758874089739-da0739746ea4',
    ),
    MockNotificationModel(
      id: '5',
      userAvatar:
          'https://images.unsplash.com/photo-1618590067690-2db34a87750a',
      userName: 'Simone Gabrielle',
      action: 'Commented on your photo.',
      timestamp: '5h ago',
      postImage: 'https://images.unsplash.com/photo-1758874089739-da0739746ea4',
    ),
    MockNotificationModel(
      id: '6',
      userAvatar:
          'https://images.unsplash.com/photo-1672685667592-0392f458f46f',
      userName: 'Tbabee100',
      action: 'Started following you.',
      timestamp: '7h ago',
      postImage: 'https://images.unsplash.com/photo-1758874089739-da0739746ea4',
    ),
    MockNotificationModel(
      id: '7',
      userAvatar:
          'https://images.unsplash.com/photo-1672685667592-0392f458f46f',
      userName: 'Tbabee100',
      action: 'Cheked your post',
      timestamp: 'Yesterday',
      postImage: 'https://images.unsplash.com/photo-1758874089739-da0739746ea4',
    ),
    MockNotificationModel(
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
