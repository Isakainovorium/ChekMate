import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/providers/providers.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/notifications/domain/entities/notification_entity.dart';
import 'package:flutter_chekmate/features/notifications/presentation/providers/notifications_providers.dart';
import 'package:flutter_chekmate/pages/notifications/notification_settings_page.dart';
import 'package:flutter_chekmate/pages/notifications/widgets/notification_tile.dart';
import 'package:flutter_chekmate/shared/ui/loading/shimmer_loading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifications Page
///
/// Full-featured notifications page with filter tabs, pull-to-refresh,
/// shimmer loading, and empty states.
///
/// Sprint 1 - Task 1.2.4
/// Date: November 28, 2025

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// Get current user ID from auth provider
  String get _userId => ref.read(currentUserIdProvider).value ?? '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final filter = NotificationFilter.values[_tabController.index];
      ref.read(notificationFilterProvider.notifier).state = filter;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // isDark available for future theme-specific styling
    final unreadCount = ref.watch(unreadNotificationCountProvider(_userId));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notifications'),
            if (unreadCount > 0) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          // Mark all as read
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: unreadCount > 0
                ? () => _markAllAsRead(context)
                : null,
          ),
          // Filter/Settings
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More options',
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Notification Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: ListTile(
                  leading: Icon(Icons.delete_sweep),
                  title: Text('Clear All'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unread'),
            Tab(text: 'Mentions'),
            Tab(text: 'Ratings'),
            Tab(text: 'Safety'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: NotificationFilter.values.map((filter) {
          return _NotificationsList(
            userId: _userId,
            filter: filter,
          );
        }).toList(),
      ),
    );
  }

  void _markAllAsRead(BuildContext context) {
    ref
        .read(notificationsControllerProvider(_userId).notifier)
        .markAllAsRead();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'settings':
        // Navigate to notification settings
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const NotificationSettingsPage(),
          ),
        );
        break;
      case 'clear':
        _showClearConfirmation(context);
        break;
    }
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text(
          'Are you sure you want to clear all notifications? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(notificationsControllerProvider(_userId).notifier)
                  .clearAll();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

/// Notifications list with loading and empty states
class _NotificationsList extends ConsumerWidget {
  const _NotificationsList({
    required this.userId,
    required this.filter,
  });

  final String userId;
  final NotificationFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsStreamProvider(userId));

    return notificationsAsync.when(
      loading: () => _buildShimmerLoading(),
      error: (error, stack) => _buildErrorState(context, error),
      data: (notifications) {
        // Apply filter
        final filtered = _applyFilter(notifications);

        if (filtered.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Refresh is handled by StreamProvider
            ref.invalidate(notificationsStreamProvider(userId));
          },
          child: Semantics(
            label: 'Notifications list with ${filtered.length} items',
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final notification = filtered[index];
                return NotificationTile(
                  notification: notification,
                  onTap: () => _handleNotificationTap(context, notification),
                  onDismiss: () => _handleDismiss(context, ref, notification),
                  onMarkAsRead: () => _handleMarkAsRead(ref, notification),
                );
              },
            ),
          ),
        );
      },
    );
  }

  List<NotificationEntity> _applyFilter(List<NotificationEntity> notifications) {
    switch (filter) {
      case NotificationFilter.all:
        return notifications;
      case NotificationFilter.unread:
        return notifications.where((n) => !n.isRead).toList();
      case NotificationFilter.mentions:
        return notifications
            .where((n) => n.type == NotificationType.mention)
            .toList();
      case NotificationFilter.ratings:
        return notifications
            .where((n) => n.type == NotificationType.rating)
            .toList();
      case NotificationFilter.safety:
        return notifications
            .where((n) => n.type == NotificationType.safety)
            .toList();
    }
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 8,
      padding: const EdgeInsets.all(AppSpacing.md),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ShimmerCircle(size: 48),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(
                      width: double.infinity,
                      height: 16,
                      borderRadius: 4,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ShimmerBox(
                      width: 200,
                      height: 14,
                      borderRadius: 4,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ShimmerBox(
                      width: 80,
                      height: 12,
                      borderRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String title;
    String subtitle;
    IconData icon;

    switch (filter) {
      case NotificationFilter.all:
        title = 'No notifications yet';
        subtitle = 'When you get notifications, they\'ll show up here';
        icon = Icons.notifications_none;
        break;
      case NotificationFilter.unread:
        title = 'All caught up!';
        subtitle = 'You\'ve read all your notifications';
        icon = Icons.check_circle_outline;
        break;
      case NotificationFilter.mentions:
        title = 'No mentions';
        subtitle = 'When someone mentions you, it\'ll appear here';
        icon = Icons.alternate_email;
        break;
      case NotificationFilter.ratings:
        title = 'No ratings yet';
        subtitle = 'Ratings from your dates will show up here';
        icon = Icons.star_outline;
        break;
      case NotificationFilter.safety:
        title = 'No safety alerts';
        subtitle = 'Community safety alerts will appear here';
        icon = Icons.shield_outlined;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Unable to load notifications. Please try again.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () {
                // Retry would be handled by invalidating the provider
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationEntity notification,
  ) {
    // Navigate based on notification type and target
    if (notification.actionUrl != null) {
      // Deep link navigation
      // context.go(notification.actionUrl!);
    } else if (notification.targetId != null) {
      switch (notification.targetType) {
        case 'post':
          // Navigate to post
          // context.go('/post/${notification.targetId}');
          break;
        case 'profile':
          // Navigate to profile
          // context.go('/profile/${notification.actorId}');
          break;
        case 'date':
          // Navigate to date rating
          // context.go('/date/${notification.targetId}');
          break;
      }
    }

    // For now, show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tapped: ${notification.title}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleDismiss(
    BuildContext context,
    WidgetRef ref,
    NotificationEntity notification,
  ) {
    ref
        .read(notificationsControllerProvider(userId).notifier)
        .deleteNotification(notification.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification dismissed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Would need to re-create the notification
          },
        ),
      ),
    );
  }

  void _handleMarkAsRead(WidgetRef ref, NotificationEntity notification) {
    if (!notification.isRead) {
      ref
          .read(notificationsControllerProvider(userId).notifier)
          .markAsRead(notification.id);
    }
  }
}
