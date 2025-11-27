import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/domain/entities/notification_entity.dart';

/// Notification Card Widget
///
/// Displays a notification in a card format with appropriate styling,
/// icons, and interaction capabilities.
///
class NotificationCardWidget extends StatelessWidget {
  const NotificationCardWidget({
    required this.notification,
    this.onTap,
    this.onDismiss,
    this.onDelete,
    this.onActionTap,
    this.showAvatar = true,
    this.showActionButton = false,
    super.key,
  });

  final NotificationEntity notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final VoidCallback? onDelete;
  final VoidCallback? onActionTap;
  final bool showAvatar;
  final bool showActionButton;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: notification.isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: notification.isRead
          ? Theme.of(context).cardColor
          : Theme.of(context).cardColor.withOpacity(0.95),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconData(),
                  color: _getIconColor(context),
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Time
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTimeAgo(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Body
                    Text(
                      notification.body,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Action button (if enabled)
                    if (showActionButton && onActionTap != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: onActionTap,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'View',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Sender info (if available and showAvatar is true)
                    if (notification.senderName != null && showAvatar) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (notification.senderAvatar != null)
                            CircleAvatar(
                              radius: 12,
                              backgroundImage: NetworkImage(notification.senderAvatar!),
                            )
                          else
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              child: Icon(
                                Icons.person,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          const SizedBox(width: 8),
                          Text(
                            notification.senderName!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Unread indicator
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),

              // Dismiss/Delete button (if provided)
              if (onDismiss != null || onDelete != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 16,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
                  ),
                  onPressed: onDelete ?? onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData() {
    switch (notification.type) {
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.comment:
        return Icons.comment;
      case NotificationType.follow:
        return Icons.person_add;
      case NotificationType.message:
        return Icons.message;
      case NotificationType.mention:
        return Icons.alternate_email;
      case NotificationType.share:
        return Icons.share;
      case NotificationType.chek:
        return Icons.check_circle;
      case NotificationType.story:
        return Icons.camera_alt;
      case NotificationType.system:
        return Icons.info;
    }
  }

  Color _getIconBackgroundColor(BuildContext context) {
    switch (notification.type) {
      case NotificationType.like:
        return Colors.red.withOpacity(0.1);
      case NotificationType.comment:
        return Colors.blue.withOpacity(0.1);
      case NotificationType.follow:
        return Colors.green.withOpacity(0.1);
      case NotificationType.message:
        return Colors.purple.withOpacity(0.1);
      case NotificationType.mention:
        return Colors.orange.withOpacity(0.1);
      case NotificationType.share:
        return Colors.teal.withOpacity(0.1);
      case NotificationType.chek:
        return Colors.amber.withOpacity(0.1);
      case NotificationType.story:
        return Colors.pink.withOpacity(0.1);
      case NotificationType.system:
        return Colors.grey.withOpacity(0.1);
    }
  }

  Color _getIconColor(BuildContext context) {
    switch (notification.type) {
      case NotificationType.like:
        return Colors.red;
      case NotificationType.comment:
        return Colors.blue;
      case NotificationType.follow:
        return Colors.green;
      case NotificationType.message:
        return Colors.purple;
      case NotificationType.mention:
        return Colors.orange;
      case NotificationType.share:
        return Colors.teal;
      case NotificationType.chek:
        return Colors.amber;
      case NotificationType.story:
        return Colors.pink;
      case NotificationType.system:
        return Colors.grey;
    }
  }

  String _formatTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(notification.createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
