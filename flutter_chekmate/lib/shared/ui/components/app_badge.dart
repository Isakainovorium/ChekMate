import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppBadge - Status indicator with consistent styling
class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.label, super.key,
    this.variant = AppBadgeVariant.primary,
    this.size = AppBadgeSize.medium,
    this.icon,
    this.onTap,
  });

  final String label;
  final AppBadgeVariant variant;
  final AppBadgeSize size;
  final IconData? icon;
  final VoidCallback? onTap;

  EdgeInsets get _padding => switch (size) {
    AppBadgeSize.small => const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs, 
        vertical: 2,
      ),
    AppBadgeSize.medium => const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm, 
        vertical: AppSpacing.xs,
      ),
    AppBadgeSize.large => const EdgeInsets.symmetric(
        horizontal: AppSpacing.md, 
        vertical: AppSpacing.sm,
      ),
  };

  double get _fontSize => switch (size) {
    AppBadgeSize.small => 11,
    AppBadgeSize.medium => 12,
    AppBadgeSize.large => 14,
  };

  double get _iconSize => switch (size) {
    AppBadgeSize.small => 12,
    AppBadgeSize.medium => 14,
    AppBadgeSize.large => 16,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(theme, variant);
    
    Widget badge = Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: variant == AppBadgeVariant.outline
            ? Border.all(color: colors.borderColor ?? Colors.transparent)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: _iconSize,
              color: colors.foregroundColor,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: _fontSize,
              fontWeight: FontWeight.w500,
              color: colors.foregroundColor,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      badge = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: badge,
      );
    }

    return badge;
  }

  _BadgeColors _getColors(ThemeData theme, AppBadgeVariant variant) {
    switch (variant) {
      case AppBadgeVariant.primary:
        return _BadgeColors(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
        );
      case AppBadgeVariant.secondary:
        return _BadgeColors(
          backgroundColor: theme.colorScheme.secondaryContainer,
          foregroundColor: theme.colorScheme.onSecondaryContainer,
        );
      case AppBadgeVariant.success:
        return _BadgeColors(
          backgroundColor: Colors.green.shade100,
          foregroundColor: Colors.green.shade800,
        );
      case AppBadgeVariant.warning:
        return _BadgeColors(
          backgroundColor: Colors.orange.shade100,
          foregroundColor: Colors.orange.shade800,
        );
      case AppBadgeVariant.error:
        return _BadgeColors(
          backgroundColor: theme.colorScheme.errorContainer,
          foregroundColor: theme.colorScheme.onErrorContainer,
        );
      case AppBadgeVariant.outline:
        return _BadgeColors(
          backgroundColor: Colors.transparent,
          foregroundColor: theme.colorScheme.onSurface,
          borderColor: theme.colorScheme.outline,
        );
      case AppBadgeVariant.neutral:
        return _BadgeColors(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          foregroundColor: theme.colorScheme.onSurfaceVariant,
        );
    }
  }
}

/// AppNotificationBadge - Small circular badge for notifications
class AppNotificationBadge extends StatelessWidget {
  const AppNotificationBadge({
    required this.child, super.key,
    this.count = 0,
    this.showZero = false,
    this.maxCount = 99,
    this.offset = const Offset(8, -8),
  });

  final Widget child;
  final int count;
  final bool showZero;
  final int maxCount;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shouldShow = count > 0 || (count == 0 && showZero);
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (shouldShow)
          Positioned(
            right: offset.dx,
            top: offset.dy,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.surface,
                ),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                count > maxCount ? '$maxCount+' : count.toString(),
                style: TextStyle(
                  color: theme.colorScheme.onError,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

enum AppBadgeVariant {
  primary,
  secondary,
  success,
  warning,
  error,
  outline,
  neutral,
}

enum AppBadgeSize { small, medium, large }

class _BadgeColors {
  const _BadgeColors({
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
}
