import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/models/notification_model.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// Notification Item Widget - converted from NotificationItem.tsx
/// Individual notification item with avatar, text, and optional post image using design system components
class NotificationItemWidget extends StatelessWidget {
  const NotificationItemWidget({
    required this.notification,
    super.key,
    this.onTap,
    this.onDismiss,
  });

  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread indicator
            if (!notification.isRead)
              const AppBadge(
                label: '',
                variant: AppBadgeVariant.error,
                size: AppBadgeSize.small,
              )
            else
              const SizedBox(width: 8),

            const SizedBox(width: 12),

            // User avatar
            AppAvatar(
              imageUrl: notification.actorAvatar,
              name: notification.actorName ?? 'User',
            ),

            const SizedBox(width: 12),

            // Notification content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification text
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: notification.actorName ?? 'Someone',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: ' ${_getActionText()}',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Timestamp
                  Text(
                    _formatTimestamp(notification.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),

                  // Additional content based on notification type
                  if (notification.type == NotificationType.message &&
                      notification.data?['messageText'] != null) ...[
                    const SizedBox(height: 8),
                    AppCard(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        notification.data!['messageText'] as String? ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Action buttons and post preview
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Dismiss button
                if (onDismiss != null)
                  AppTooltip(
                    message: 'Dismiss',
                    child: AppButton(
                      onPressed: onDismiss,
                      variant: AppButtonVariant.text,
                      size: AppButtonSize.sm,
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                // Post preview image (if available)
                if (_hasPostPreview()) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _getPostImageUrl(),
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey.shade400,
                            size: 24,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getActionText() {
    switch (notification.type) {
      case NotificationType.like:
        return 'liked your post';
      case NotificationType.comment:
        return 'commented on your post';
      case NotificationType.follow:
        return 'started following you';
      case NotificationType.chek:
        return 'cheked your post';
      case NotificationType.message:
        return 'sent you a message';
      case NotificationType.mention:
        return 'mentioned you in a comment';
      case NotificationType.rating:
        return 'rated your profile';
      case NotificationType.system:
        return notification.message;
    }
  }

  bool _hasPostPreview() {
    return notification.targetType == 'post' &&
        notification.data?['postImageUrl'] != null;
  }

  String _getPostImageUrl() {
    return notification.data?['postImageUrl'] as String? ?? '';
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

/// Legacy notification item widget for backward compatibility with mock data
class LegacyNotificationItemWidget extends StatelessWidget {
  const LegacyNotificationItemWidget({
    required this.userAvatar,
    required this.userName,
    required this.action,
    required this.timestamp,
    super.key,
    this.postImage,
    this.onTap,
  });

  final String userAvatar;
  final String userName;
  final String action;
  final String timestamp;
  final String? postImage;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bullet point indicator
            const AppBadge(
              label: '',
              variant: AppBadgeVariant.error,
              size: AppBadgeSize.small,
            ),

            const SizedBox(width: 12),

            // User avatar
            AppAvatar(
              imageUrl: userAvatar,
              name: userName,
            ),

            const SizedBox(width: 12),

            // Notification text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    action,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timestamp,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            // Post image preview
            if (postImage != null) ...[
              const SizedBox(width: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  postImage!,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey.shade400,
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
