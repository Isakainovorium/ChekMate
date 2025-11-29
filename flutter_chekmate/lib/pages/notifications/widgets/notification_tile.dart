import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/notifications/domain/entities/notification_entity.dart';
import 'package:flutter_chekmate/shared/ui/components/app_avatar.dart';

/// Notification Tile Widget
///
/// Displays a single notification with avatar, content, timestamp,
/// and read/unread visual state. Supports different notification types
/// with distinct styling for safety alerts.
///
/// Sprint 1 - Task 1.2.5
/// Date: November 28, 2025

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    required this.notification,
    super.key,
    this.onTap,
    this.onDismiss,
    this.onMarkAsRead,
  });

  final NotificationEntity notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final VoidCallback? onMarkAsRead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Safety alerts get special styling
    if (notification.type == NotificationType.safety) {
      return _buildSafetyAlert(context, theme, isDark);
    }

    return Semantics(
      label: _buildSemanticLabel(),
      button: true,
      child: Dismissible(
        key: Key(notification.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDismiss?.call(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          color: AppColors.error,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: InkWell(
          onTap: () {
            onMarkAsRead?.call();
            onTap?.call();
          },
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: notification.isRead
                  ? Colors.transparent
                  : (isDark
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.05)),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.dividerDark : AppColors.divider,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with notification type indicator
                _buildAvatar(context),
                const SizedBox(width: AppSpacing.md),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with @mentions highlighted
                      _buildTitle(context, theme),
                      const SizedBox(height: AppSpacing.xs),

                      // Body
                      _buildBody(context, theme),
                      const SizedBox(height: AppSpacing.xs),

                      // Timestamp
                      Text(
                        notification.formattedTimestamp,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiary,
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
                    margin: const EdgeInsets.only(top: AppSpacing.xs),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyAlert(BuildContext context, ThemeData theme, bool isDark) {
    return Semantics(
      label: 'Safety alert: ${notification.title}. ${notification.body}',
      button: true,
      child: InkWell(
        onTap: () {
          onMarkAsRead?.call();
          onTap?.call();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.error.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning icon
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: AppColors.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      notification.body,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      notification.formattedTimestamp,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiary,
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
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Stack(
      children: [
        AppAvatar(
          imageUrl: notification.actorAvatar,
          name: notification.actorName,
          size: AppAvatarSize.medium,
        ),
        // Notification type badge
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _getTypeColor(),
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).scaffoldBackgroundColor,
                width: 2,
              ),
            ),
            child: Icon(
              _getTypeIcon(),
              size: 10,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    // Highlight actor name if present
    if (notification.actorName != null) {
      return RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          children: [
            TextSpan(
              text: notification.actorName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: ' ${_getActionText()}',
            ),
          ],
        ),
      );
    }

    return Text(
      notification.title,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    // Parse and highlight @mentions in body
    final body = notification.body;
    final mentionRegex = RegExp(r'@\w+');
    final matches = mentionRegex.allMatches(body);

    if (matches.isEmpty) {
      return Text(
        body,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    // Build rich text with highlighted mentions
    final spans = <TextSpan>[];
    var lastEnd = 0;

    for (final match in matches) {
      // Add text before mention
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: body.substring(lastEnd, match.start)));
      }
      // Add highlighted mention
      spans.add(TextSpan(
        text: match.group(0),
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ));
      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < body.length) {
      spans.add(TextSpan(text: body.substring(lastEnd)));
    }

    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodySmall?.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
        children: spans,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  String _getActionText() {
    switch (notification.type) {
      case NotificationType.like:
        return 'liked your post';
      case NotificationType.comment:
        return 'commented on your post';
      case NotificationType.rating:
        final ratingText = notification.ratingType?.name.toUpperCase() ?? '';
        return 'rated your date as $ratingText';
      case NotificationType.follow:
        return 'started following you';
      case NotificationType.mention:
        return 'mentioned you';
      case NotificationType.safety:
        return '';
      case NotificationType.system:
        return '';
    }
  }

  IconData _getTypeIcon() {
    switch (notification.type) {
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.comment:
        return Icons.chat_bubble;
      case NotificationType.rating:
        return Icons.star;
      case NotificationType.follow:
        return Icons.person_add;
      case NotificationType.mention:
        return Icons.alternate_email;
      case NotificationType.safety:
        return Icons.warning;
      case NotificationType.system:
        return Icons.notifications;
    }
  }

  Color _getTypeColor() {
    switch (notification.type) {
      case NotificationType.like:
        return AppColors.like;
      case NotificationType.comment:
        return AppColors.comment;
      case NotificationType.rating:
        return AppColors.primary;
      case NotificationType.follow:
        return AppColors.navyBlue;
      case NotificationType.mention:
        return const Color(0xFF9B59B6); // Purple
      case NotificationType.safety:
        return AppColors.error;
      case NotificationType.system:
        return AppColors.textSecondary;
    }
  }

  String _buildSemanticLabel() {
    final readStatus = notification.isRead ? 'Read' : 'Unread';
    final actor = notification.actorName ?? '';
    final action = _getActionText();
    final time = notification.formattedTimestamp;

    if (actor.isNotEmpty) {
      return '$readStatus notification. $actor $action. $time';
    }
    return '$readStatus notification. ${notification.title}. ${notification.body}. $time';
  }
}
