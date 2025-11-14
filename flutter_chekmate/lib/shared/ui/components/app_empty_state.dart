import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// AppEmptyState - Comprehensive empty state displays
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    this.icon,
    this.title,
    this.message,
    this.action,
    this.type = AppEmptyStateType.generic,
    this.size = AppEmptyStateSize.medium,
  });

  final IconData? icon;
  final String? title;
  final String? message;
  final Widget? action;
  final AppEmptyStateType type;
  final AppEmptyStateSize size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _getEmptyStateConfig(type);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(_getPadding()),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(
              icon ?? config.icon,
              size: _getIconSize(),
              color: theme.colorScheme.onSurfaceVariant,
            ),

            SizedBox(height: _getSpacing()),

            // Title
            Text(
              title ?? config.title,
              style: _getTitleStyle(theme),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: _getSpacing() / 2),

            // Message
            Text(
              message ?? config.message,
              style: _getMessageStyle(theme),
              textAlign: TextAlign.center,
            ),

            if (action != null) ...[
              SizedBox(height: _getSpacing()),
              action!,
            ],
          ],
        ),
      ),
    );
  }

  _EmptyStateConfig _getEmptyStateConfig(AppEmptyStateType type) {
    switch (type) {
      case AppEmptyStateType.noData:
        return const _EmptyStateConfig(
          icon: Icons.inbox_outlined,
          title: 'No Data Available',
          message: 'There\'s no data to display at the moment.',
        );
      case AppEmptyStateType.noResults:
        return const _EmptyStateConfig(
          icon: Icons.search_off,
          title: 'No Results Found',
          message:
              'Try adjusting your search or filters to find what you\'re looking for.',
        );
      case AppEmptyStateType.noConnection:
        return const _EmptyStateConfig(
          icon: Icons.wifi_off,
          title: 'No Connection',
          message: 'Please check your internet connection and try again.',
        );
      case AppEmptyStateType.noNotifications:
        return const _EmptyStateConfig(
          icon: Icons.notifications_none,
          title: 'No Notifications',
          message: 'You\'re all caught up! No new notifications.',
        );
      case AppEmptyStateType.noMessages:
        return const _EmptyStateConfig(
          icon: Icons.message_outlined,
          title: 'No Messages',
          message: 'Start a conversation to see messages here.',
        );
      case AppEmptyStateType.noPosts:
        return const _EmptyStateConfig(
          icon: Icons.article_outlined,
          title: 'No Posts Yet',
          message: 'Be the first to share something!',
        );
      case AppEmptyStateType.noFavorites:
        return const _EmptyStateConfig(
          icon: Icons.favorite_border,
          title: 'No Favorites',
          message: 'Items you favorite will appear here.',
        );
      case AppEmptyStateType.noFiles:
        return const _EmptyStateConfig(
          icon: Icons.folder_outlined,
          title: 'No Files',
          message: 'Upload files to get started.',
        );
      case AppEmptyStateType.maintenance:
        return const _EmptyStateConfig(
          icon: Icons.build_outlined,
          title: 'Under Maintenance',
          message: 'We\'re making improvements. Please check back later.',
        );
      case AppEmptyStateType.generic:
        return const _EmptyStateConfig(
          icon: Icons.info_outline,
          title: 'Nothing Here',
          message: 'There\'s nothing to show right now.',
        );
    }
  }

  double _getPadding() {
    switch (size) {
      case AppEmptyStateSize.small:
        return AppSpacing.lg;
      case AppEmptyStateSize.medium:
        return AppSpacing.xl;
      case AppEmptyStateSize.large:
        return AppSpacing.xxl;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppEmptyStateSize.small:
        return 48.0;
      case AppEmptyStateSize.medium:
        return 64.0;
      case AppEmptyStateSize.large:
        return 80.0;
    }
  }

  double _getSpacing() {
    switch (size) {
      case AppEmptyStateSize.small:
        return AppSpacing.md;
      case AppEmptyStateSize.medium:
        return AppSpacing.lg;
      case AppEmptyStateSize.large:
        return AppSpacing.xl;
    }
  }

  TextStyle? _getTitleStyle(ThemeData theme) {
    switch (size) {
      case AppEmptyStateSize.small:
        return theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        );
      case AppEmptyStateSize.medium:
        return theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        );
      case AppEmptyStateSize.large:
        return theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
        );
    }
  }

  TextStyle? _getMessageStyle(ThemeData theme) {
    return theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
  }
}

/// AppEmptyStateBuilder - Builder for different empty states
class AppEmptyStateBuilder extends StatelessWidget {
  const AppEmptyStateBuilder({
    required this.isEmpty,
    required this.child,
    super.key,
    this.emptyState,
    this.type = AppEmptyStateType.generic,
    this.title,
    this.message,
    this.action,
  });

  final bool isEmpty;
  final Widget child;
  final Widget? emptyState;
  final AppEmptyStateType type;
  final String? title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    if (isEmpty) {
      return emptyState ??
          AppEmptyState(
            type: type,
            title: title,
            message: message,
            action: action,
          );
    }
    return child;
  }
}

/// AppEmptyStateCard - Empty state in card format
class AppEmptyStateCard extends StatelessWidget {
  const AppEmptyStateCard({
    required this.type,
    super.key,
    this.title,
    this.message,
    this.action,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
  });

  final AppEmptyStateType type;
  final String? title;
  final String? message;
  final Widget? action;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: padding,
        child: AppEmptyState(
          type: type,
          title: title,
          message: message,
          action: action,
          size: AppEmptyStateSize.small,
        ),
      ),
    );
  }
}

/// AppAnimatedEmptyState - Empty state with animations
class AppAnimatedEmptyState extends StatefulWidget {
  const AppAnimatedEmptyState({
    required this.type,
    super.key,
    this.title,
    this.message,
    this.action,
    this.animationType = AppEmptyStateAnimation.fadeIn,
  });

  final AppEmptyStateType type;
  final String? title;
  final String? message;
  final Widget? action;
  final AppEmptyStateAnimation animationType;

  @override
  State<AppAnimatedEmptyState> createState() => _AppAnimatedEmptyStateState();
}

class _AppAnimatedEmptyStateState extends State<AppAnimatedEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    switch (widget.animationType) {
      case AppEmptyStateAnimation.fadeIn:
        _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeIn),
        );
        break;
      case AppEmptyStateAnimation.slideUp:
        _animation = Tween<double>(begin: 50.0, end: 0.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        );
        break;
      case AppEmptyStateAnimation.scale:
        _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
        );
        break;
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        switch (widget.animationType) {
          case AppEmptyStateAnimation.fadeIn:
            return Opacity(
              opacity: _animation.value,
              child: child,
            );
          case AppEmptyStateAnimation.slideUp:
            return Transform.translate(
              offset: Offset(0, _animation.value),
              child: child,
            );
          case AppEmptyStateAnimation.scale:
            return Transform.scale(
              scale: _animation.value,
              child: child,
            );
        }
      },
      child: AppEmptyState(
        type: widget.type,
        title: widget.title,
        message: widget.message,
        action: widget.action,
      ),
    );
  }
}

/// AppEmptyStateSliver - Empty state for slivers
class AppEmptyStateSliver extends StatelessWidget {
  const AppEmptyStateSliver({
    required this.type,
    super.key,
    this.title,
    this.message,
    this.action,
    this.height = 400,
  });

  final AppEmptyStateType type;
  final String? title;
  final String? message;
  final Widget? action;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: height,
        child: AppEmptyState(
          type: type,
          title: title,
          message: message,
          action: action,
        ),
      ),
    );
  }
}

/// AppSearchEmptyState - Specialized empty state for search
class AppSearchEmptyState extends StatelessWidget {
  const AppSearchEmptyState({
    required this.query,
    super.key,
    this.onClearSearch,
    this.suggestions = const [],
  });

  final String query;
  final VoidCallback? onClearSearch;
  final List<String> suggestions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No results for "$query"',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try adjusting your search terms or check the spelling.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onClearSearch != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                variant: AppButtonVariant.outline,
                onPressed: onClearSearch,
                child: const Text('Clear Search'),
              ),
            ],
            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Try searching for:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: suggestions.map((suggestion) {
                  return ActionChip(
                    label: Text(suggestion),
                    onPressed: () {
                      // Handle suggestion tap
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// AppListEmptyState - Empty state for lists with add action
class AppListEmptyState extends StatelessWidget {
  const AppListEmptyState({
    required this.itemName,
    super.key,
    this.onAdd,
    this.addButtonText,
    this.icon,
  });

  final String itemName;
  final VoidCallback? onAdd;
  final String? addButtonText;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: icon ?? Icons.add_circle_outline,
      title: 'No $itemName Yet',
      message: 'Get started by adding your first $itemName.',
      action: onAdd != null
          ? AppButton(
              onPressed: onAdd,
              child: Text(addButtonText ?? 'Add $itemName'),
            )
          : null,
    );
  }
}

/// Configuration class for empty states
class _EmptyStateConfig {
  const _EmptyStateConfig({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;
}

/// Enums for empty state configuration
enum AppEmptyStateType {
  generic,
  noData,
  noResults,
  noConnection,
  noNotifications,
  noMessages,
  noPosts,
  noFavorites,
  noFiles,
  maintenance,
}

enum AppEmptyStateSize {
  small,
  medium,
  large,
}

enum AppEmptyStateAnimation {
  fadeIn,
  slideUp,
  scale,
}
