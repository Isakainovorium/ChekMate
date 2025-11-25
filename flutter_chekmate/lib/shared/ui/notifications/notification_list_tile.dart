import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/domain/entities/notification_entity.dart';

/// Notification List Tile Widget
///
/// A compact widget for displaying notifications in a list format.
/// Optimized for use in ListView or similar scrollable widgets.
class NotificationListTile extends StatelessWidget {
  const NotificationListTile({
    required this.notification,
    this.onTap,
    super.key,
  });

  final NotificationEntity notification;
  final VoidCallback? onTap;

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
        return Colors.pink;
      case NotificationType.story:
        return Colors.indigo;
      case NotificationType.system:
        return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _getIconColor(context);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            notification.icon,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
      title: Text(
        notification.title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification.body,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: notification.isRead
                  ? Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6)
                  : Theme.of(context).textTheme.bodySmall?.color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            notification.timeAgo,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
              fontSize: 10,
            ),
          ),
        ],
      ),
      trailing: notification.isRead
          ? null
          : Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      dense: true,
    );
  }
}
