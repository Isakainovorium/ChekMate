import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppNotificationBanner - System-wide notification banners
class AppNotificationBanner extends StatefulWidget {
  const AppNotificationBanner({
    required this.message,
    super.key,
    this.title,
    this.type = AppNotificationBannerType.info,
    this.duration = const Duration(seconds: 4),
    this.showCloseButton = true,
    this.onTap,
    this.onClose,
    this.action,
    this.icon,
  });

  final String message;
  final String? title;
  final AppNotificationBannerType type;
  final Duration duration;
  final bool showCloseButton;
  final VoidCallback? onTap;
  final VoidCallback? onClose;
  final AppNotificationAction? action;
  final IconData? icon;

  static void show({
    required BuildContext context,
    required String message,
    String? title,
    AppNotificationBannerType type = AppNotificationBannerType.info,
    Duration duration = const Duration(seconds: 4),
    bool showCloseButton = true,
    VoidCallback? onTap,
    VoidCallback? onClose,
    AppNotificationAction? action,
    IconData? icon,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: AppNotificationBanner(
          message: message,
          title: title,
          type: type,
          duration: duration,
          showCloseButton: showCloseButton,
          onTap: onTap,
          onClose: () {
            overlayEntry.remove();
            onClose?.call();
          },
          action: action,
          icon: icon,
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-dismiss after duration
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  @override
  State<AppNotificationBanner> createState() => _AppNotificationBannerState();
}

class _AppNotificationBannerState extends State<AppNotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      widget.onClose?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _getTypeConfig(widget.type, theme);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: config.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        // Icon
                        Icon(
                          widget.icon ?? config.icon,
                          color: config.iconColor,
                          size: 24,
                        ),

                        const SizedBox(width: AppSpacing.md),

                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.title != null)
                                Text(
                                  widget.title!,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: config.textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              Text(
                                widget.message,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: config.textColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Action button
                        if (widget.action != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          TextButton(
                            onPressed: widget.action!.onPressed,
                            style: TextButton.styleFrom(
                              foregroundColor: config.actionColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.xs,
                              ),
                            ),
                            child: Text(widget.action!.label),
                          ),
                        ],

                        // Close button
                        if (widget.showCloseButton) ...[
                          const SizedBox(width: AppSpacing.sm),
                          IconButton(
                            onPressed: _dismiss,
                            icon: Icon(
                              Icons.close,
                              color: config.textColor.withOpacity(0.7),
                              size: 20,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  _NotificationConfig _getTypeConfig(
    AppNotificationBannerType type,
    ThemeData theme,
  ) {
    switch (type) {
      case AppNotificationBannerType.success:
        return _NotificationConfig(
          backgroundColor: Colors.green.shade50,
          textColor: Colors.green.shade800,
          iconColor: Colors.green.shade600,
          actionColor: Colors.green.shade700,
          icon: Icons.check_circle,
        );
      case AppNotificationBannerType.warning:
        return _NotificationConfig(
          backgroundColor: Colors.orange.shade50,
          textColor: Colors.orange.shade800,
          iconColor: Colors.orange.shade600,
          actionColor: Colors.orange.shade700,
          icon: Icons.warning,
        );
      case AppNotificationBannerType.error:
        return _NotificationConfig(
          backgroundColor: Colors.red.shade50,
          textColor: Colors.red.shade800,
          iconColor: Colors.red.shade600,
          actionColor: Colors.red.shade700,
          icon: Icons.error,
        );
      case AppNotificationBannerType.info:
        return _NotificationConfig(
          backgroundColor: theme.colorScheme.primaryContainer,
          textColor: theme.colorScheme.onPrimaryContainer,
          iconColor: theme.colorScheme.primary,
          actionColor: theme.colorScheme.primary,
          icon: Icons.info,
        );
    }
  }
}

/// AppInAppNotification - In-app notification overlay
class AppInAppNotification extends StatefulWidget {
  const AppInAppNotification({
    required this.title,
    required this.message,
    super.key,
    this.avatar,
    this.timestamp,
    this.onTap,
    this.onDismiss,
    this.duration = const Duration(seconds: 5),
  });

  final String title;
  final String message;
  final Widget? avatar;
  final String? timestamp;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final Duration duration;

  static void show({
    required BuildContext context,
    required String title,
    required String message,
    Widget? avatar,
    String? timestamp,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
    Duration duration = const Duration(seconds: 5),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: AppInAppNotification(
          title: title,
          message: message,
          avatar: avatar,
          timestamp: timestamp,
          onTap: onTap,
          onDismiss: () {
            overlayEntry.remove();
            onDismiss?.call();
          },
          duration: duration,
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  @override
  State<AppInAppNotification> createState() => _AppInAppNotificationState();
}

class _AppInAppNotificationState extends State<AppInAppNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SlideTransition(
      position: _slideAnimation,
      child: Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.up,
        onDismissed: (_) => widget.onDismiss?.call(),
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    // Avatar
                    if (widget.avatar != null)
                      widget.avatar!
                    else
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications,
                          color: theme.colorScheme.onPrimary,
                          size: 20,
                        ),
                      ),

                    const SizedBox(width: AppSpacing.md),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.timestamp != null)
                                Text(
                                  widget.timestamp!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            widget.message,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Dismiss button
                    IconButton(
                      onPressed: _dismiss,
                      icon: Icon(
                        Icons.close,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// AppSnackBarNotification - Enhanced snackbar notifications
class AppSnackBarNotification {
  static void show(
    BuildContext context, {
    required String message,
    AppNotificationBannerType type = AppNotificationBannerType.info,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    final config = _getSnackBarConfig(type, theme);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon ?? config.icon,
              color: config.iconColor,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: config.textColor),
              ),
            ),
          ],
        ),
        backgroundColor: config.backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: config.actionColor,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  static _NotificationConfig _getSnackBarConfig(
    AppNotificationBannerType type,
    ThemeData theme,
  ) {
    switch (type) {
      case AppNotificationBannerType.success:
        return _NotificationConfig(
          backgroundColor: Colors.green.shade600,
          textColor: Colors.white,
          iconColor: Colors.white,
          actionColor: Colors.white,
          icon: Icons.check_circle,
        );
      case AppNotificationBannerType.warning:
        return _NotificationConfig(
          backgroundColor: Colors.orange.shade600,
          textColor: Colors.white,
          iconColor: Colors.white,
          actionColor: Colors.white,
          icon: Icons.warning,
        );
      case AppNotificationBannerType.error:
        return _NotificationConfig(
          backgroundColor: Colors.red.shade600,
          textColor: Colors.white,
          iconColor: Colors.white,
          actionColor: Colors.white,
          icon: Icons.error,
        );
      case AppNotificationBannerType.info:
        return _NotificationConfig(
          backgroundColor: theme.colorScheme.primary,
          textColor: theme.colorScheme.onPrimary,
          iconColor: theme.colorScheme.onPrimary,
          actionColor: theme.colorScheme.onPrimary,
          icon: Icons.info,
        );
    }
  }
}

/// AppNotificationManager - Global notification management
class AppNotificationManager {
  static final List<OverlayEntry> _activeNotifications = [];

  static void showBanner({
    required BuildContext context,
    required String message,
    String? title,
    AppNotificationBannerType type = AppNotificationBannerType.info,
    Duration duration = const Duration(seconds: 4),
    bool showCloseButton = true,
    VoidCallback? onTap,
    VoidCallback? onClose,
    AppNotificationAction? action,
    IconData? icon,
  }) {
    AppNotificationBanner.show(
      context: context,
      message: message,
      title: title,
      type: type,
      duration: duration,
      showCloseButton: showCloseButton,
      onTap: onTap,
      onClose: onClose,
      action: action,
      icon: icon,
    );
  }

  static void showInApp({
    required BuildContext context,
    required String title,
    required String message,
    Widget? avatar,
    String? timestamp,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
    Duration duration = const Duration(seconds: 5),
  }) {
    AppInAppNotification.show(
      context: context,
      title: title,
      message: message,
      avatar: avatar,
      timestamp: timestamp,
      onTap: onTap,
      onDismiss: onDismiss,
      duration: duration,
    );
  }

  static void showSnackBar({
    required BuildContext context,
    required String message,
    AppNotificationBannerType type = AppNotificationBannerType.info,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
    IconData? icon,
  }) {
    AppSnackBarNotification.show(
      context,
      message: message,
      type: type,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
      icon: icon,
    );
  }

  static void dismissAll() {
    for (final entry in _activeNotifications) {
      if (entry.mounted) {
        entry.remove();
      }
    }
    _activeNotifications.clear();
  }
}

/// Configuration classes and enums
class _NotificationConfig {
  const _NotificationConfig({
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.actionColor,
    required this.icon,
  });
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final Color actionColor;
  final IconData icon;
}

class AppNotificationAction {
  const AppNotificationAction({
    required this.label,
    required this.onPressed,
  });
  final String label;
  final VoidCallback onPressed;
}

enum AppNotificationBannerType {
  info,
  success,
  warning,
  error,
}
