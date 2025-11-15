import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// NotificationsHeader - Header for notifications page with actions
class NotificationsHeaderWidget extends StatelessWidget {
  const NotificationsHeaderWidget({
    super.key,
    this.unreadCount = 0,
    this.onMarkAllRead,
    this.onSettings,
    this.onFilter,
    this.selectedFilter = NotificationFilter.all,
  });

  final int unreadCount;
  final VoidCallback? onMarkAllRead;
  final VoidCallback? onSettings;
  final ValueChanged<NotificationFilter>? onFilter;
  final NotificationFilter selectedFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppCard(
      margin: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and actions row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifications',
                      style: theme.textTheme.headlineSmall,
                    ),
                    if (unreadCount > 0) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '$unreadCount unread',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Action buttons
              Row(
                children: [
                  if (unreadCount > 0 && onMarkAllRead != null)
                    AppButton(
                      onPressed: onMarkAllRead,
                      variant: AppButtonVariant.text,
                      size: AppButtonSize.sm,
                      child: const Text('Mark all read'),
                    ),
                  
                  if (onSettings != null)
                    IconButton(
                      onPressed: onSettings,
                      icon: const Icon(Icons.settings_outlined),
                      tooltip: 'Notification settings',
                    ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Filter tabs
          if (onFilter != null)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: NotificationFilter.values.map((filter) {
                  final isSelected = filter == selectedFilter;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: FilterChip(
                      label: Text(_getFilterLabel(filter)),
                      selected: isSelected,
                      onSelected: (_) => onFilter!(filter),
                      backgroundColor: theme.colorScheme.surface,
                      selectedColor: theme.colorScheme.primaryContainer,
                      checkmarkColor: theme.colorScheme.primary,
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  String _getFilterLabel(NotificationFilter filter) {
    switch (filter) {
      case NotificationFilter.all:
        return 'All';
      case NotificationFilter.unread:
        return 'Unread';
      case NotificationFilter.likes:
        return 'Likes';
      case NotificationFilter.comments:
        return 'Comments';
      case NotificationFilter.follows:
        return 'Follows';
      case NotificationFilter.mentions:
        return 'Mentions';
    }
  }
}

enum NotificationFilter {
  all,
  unread,
  likes,
  comments,
  follows,
  mentions,
}
