import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// Notification Sort Option
enum NotificationSortOption {
  time,
  type,
  unreadFirst,
}

extension NotificationSortOptionExtension on NotificationSortOption {
  String get label {
    switch (this) {
      case NotificationSortOption.time:
        return 'Sort by time';
      case NotificationSortOption.type:
        return 'Sort by type';
      case NotificationSortOption.unreadFirst:
        return 'Unread first';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationSortOption.time:
        return Icons.access_time;
      case NotificationSortOption.type:
        return Icons.category;
      case NotificationSortOption.unreadFirst:
        return Icons.mark_email_unread;
    }
  }
}

/// Notifications Header Widget - converted from NotificationsHeader.tsx
/// Header for notifications page with decorative circle and design system components
class NotificationsHeaderWidget extends StatelessWidget {
  const NotificationsHeaderWidget({
    super.key,
    this.unreadCount = 0,
    this.onMarkAllRead,
    this.onSettings,
    this.currentSortOption = NotificationSortOption.time,
    this.onSortChanged,
  });

  final int unreadCount;
  final VoidCallback? onMarkAllRead;
  final VoidCallback? onSettings;
  final NotificationSortOption currentSortOption;
  final void Function(NotificationSortOption)? onSortChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      child: Stack(
        children: [
          // Orange circle decoration
          Positioned(
            top: -64,
            left: -64,
            child: Container(
              width: 128,
              height: 128,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header row with title and actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Unread count badge
                      if (unreadCount > 0)
                        AppBadge(
                          label: unreadCount.toString(),
                          variant: AppBadgeVariant.error,
                          size: AppBadgeSize.small,
                        )
                      else
                        const SizedBox(width: 24),

                      // Title
                      const Expanded(
                        child: Text(
                          'Activity and Notifications',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Settings button
                      AppTooltip(
                        message: 'Settings',
                        child: AppButton(
                          onPressed: onSettings,
                          variant: AppButtonVariant.text,
                          size: AppButtonSize.sm,
                          child: const Icon(
                            Icons.settings_outlined,
                            size: 20,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Filter controls row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Mark all as read button
                      if (unreadCount > 0)
                        AppButton(
                          onPressed: onMarkAllRead,
                          variant: AppButtonVariant.text,
                          size: AppButtonSize.sm,
                          child: const Text(
                            'Mark all read',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      else
                        const Text(
                          'All caught up!',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),

                      // Sort dropdown
                      AppButton(
                        onPressed: onSortChanged != null
                            ? () => _showSortOptions(context)
                            : null,
                        variant: AppButtonVariant.text,
                        size: AppButtonSize.sm,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currentSortOption.label,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: Colors.grey.shade700,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Sort notifications by',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...NotificationSortOption.values.map((option) {
              final isSelected = option == currentSortOption;
              return ListTile(
                leading: Icon(
                  option.icon,
                  color: isSelected ? Theme.of(context).primaryColor : null,
                ),
                title: Text(
                  option.label,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Theme.of(context).primaryColor : null,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).primaryColor,
                      )
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  onSortChanged?.call(option);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
