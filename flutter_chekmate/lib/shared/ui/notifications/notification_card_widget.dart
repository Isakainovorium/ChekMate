import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/domain/entities/notification_entity.dart';

/// NotificationCardWidget - Shared UI Component
///
/// A card widget for displaying notifications in a list.
/// Shows notification icon, title, body, time, and read status.
///
/// Features:
/// - Notification icon based on type
/// - Read/unread indicator
/// - Time ago display
/// - Tap action
/// - Swipe to delete (optional)
///
/// Usage:
/// ```dart
/// NotificationCardWidget(
///   notification: notification,
///   onTap: () {
///     // Navigate to notification target
///   },
/// )
/// ```
class NotificationCardWidget extends StatelessWidget {
  const NotificationCardWidget({
    required this.notification,
    super.key,
    this.onTap,
    this.onDelete,
    this.showAvatar = true,
    this.showActionButton = false,
    this.onActionTap,
  });

  final NotificationEntity notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showAvatar;
  final bool showActionButton;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(notification.id),
      direction: onDelete != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead
                ? Colors.transparent
                : theme.primaryColor.withValues(alpha: 0.05),
            border: Border(
              bottom: BorderSide(
                color: theme.dividerColor,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar or Icon
              if (showAvatar && notification.senderAvatar != null)
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(notification.senderAvatar!),
                )
              else
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(theme),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      notification.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Body
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Time
                    Text(
                      notification.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),

                    // Action Button
                    if (showActionButton &&
                        notification.requiresAction &&
                        notification.actionButtonText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: OutlinedButton(
                          onPressed: onActionTap,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: Text(notification.actionButtonText!),
                        ),
                      ),
                  ],
                ),
              ),

              // Unread indicator
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 8, top: 8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(ThemeData theme) {
    switch (notification.type) {
      case NotificationType.like:
        return Colors.red.withValues(alpha: 0.1);
      case NotificationType.comment:
        return Colors.blue.withValues(alpha: 0.1);
      case NotificationType.follow:
        return Colors.green.withValues(alpha: 0.1);
      case NotificationType.message:
        return Colors.purple.withValues(alpha: 0.1);
      case NotificationType.mention:
        return Colors.orange.withValues(alpha: 0.1);
      case NotificationType.share:
        return Colors.teal.withValues(alpha: 0.1);
      case NotificationType.chek:
        return theme.primaryColor.withValues(alpha: 0.1);
      case NotificationType.story:
        return Colors.pink.withValues(alpha: 0.1);
      case NotificationType.system:
        return Colors.grey.withValues(alpha: 0.1);
    }
  }
}

/// NotificationListTile - Compact notification display
///
/// A compact list tile for displaying notifications.
class NotificationListTile extends StatelessWidget {
  const NotificationListTile({
    required this.notification,
    super.key,
    this.onTap,
  });

  final NotificationEntity notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Text(
        notification.icon,
        style: const TextStyle(fontSize: 24),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        notification.body,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            notification.timeAgo,
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          if (!notification.isRead)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}

/// NotificationBadge - Badge showing unread count
///
/// A badge widget for displaying unread notification count.
class NotificationBadge extends StatelessWidget {
  const NotificationBadge({
    required this.count,
    super.key,
    this.child,
    this.showZero = false,
  });

  final int count;
  final Widget? child;
  final bool showZero;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (count == 0 && !showZero) {
      return child ?? const SizedBox.shrink();
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child ?? const SizedBox.shrink(),
        Positioned(
          right: -8,
          top: -8,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.scaffoldBackgroundColor,
                width: 2,
              ),
            ),
            constraints: const BoxConstraints(
              minWidth: 20,
              minHeight: 20,
            ),
            child: Center(
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
