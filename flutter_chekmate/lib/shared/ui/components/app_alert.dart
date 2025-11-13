import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppAlert - Alert/notification banner with consistent styling
class AppAlert extends StatelessWidget {
  const AppAlert({
    required this.message,
    super.key,
    this.title,
    this.variant = AppAlertVariant.info,
    this.showIcon = true,
    this.onClose,
    this.actions,
    this.isDismissible = false,
  });

  final String message;
  final String? title;
  final AppAlertVariant variant;
  final bool showIcon;
  final VoidCallback? onClose;
  final List<Widget>? actions;
  final bool isDismissible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(theme, variant);
    final icon = _getIcon(variant);

    Widget alert = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showIcon) ...[
            Icon(
              icon,
              color: colors.iconColor,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.textColor,
                  ),
                ),
                if (actions != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      for (int i = 0; i < actions!.length; i++) ...[
                        if (i > 0) const SizedBox(width: AppSpacing.sm),
                        actions![i],
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (onClose != null) ...[
            const SizedBox(width: AppSpacing.sm),
            InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: colors.textColor.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (isDismissible && onClose != null) {
      alert = Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onClose!(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.md),
          color: colors.borderColor,
          child: Icon(
            Icons.delete_outline,
            color: colors.textColor,
          ),
        ),
        child: alert,
      );
    }

    return alert;
  }

  _AlertColors _getColors(ThemeData theme, AppAlertVariant variant) {
    switch (variant) {
      case AppAlertVariant.info:
        return _AlertColors(
          backgroundColor:
              theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
          borderColor: theme.colorScheme.primary.withValues(alpha: 0.3),
          textColor: theme.colorScheme.onSurface,
          iconColor: theme.colorScheme.primary,
        );
      case AppAlertVariant.success:
        return _AlertColors(
          backgroundColor: Colors.green.shade50,
          borderColor: Colors.green.shade300,
          textColor: Colors.green.shade800,
          iconColor: Colors.green.shade600,
        );
      case AppAlertVariant.warning:
        return _AlertColors(
          backgroundColor: Colors.orange.shade50,
          borderColor: Colors.orange.shade300,
          textColor: Colors.orange.shade800,
          iconColor: Colors.orange.shade600,
        );
      case AppAlertVariant.error:
        return _AlertColors(
          backgroundColor:
              theme.colorScheme.errorContainer.withValues(alpha: 0.1),
          borderColor: theme.colorScheme.error.withValues(alpha: 0.3),
          textColor: theme.colorScheme.error,
          iconColor: theme.colorScheme.error,
        );
    }
  }

  IconData _getIcon(AppAlertVariant variant) {
    switch (variant) {
      case AppAlertVariant.info:
        return Icons.info_outline;
      case AppAlertVariant.success:
        return Icons.check_circle_outline;
      case AppAlertVariant.warning:
        return Icons.warning_amber_outlined;
      case AppAlertVariant.error:
        return Icons.error_outline;
    }
  }
}

/// AppSnackBar - Snackbar with consistent styling
class AppSnackBar {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show({
    required BuildContext context,
    required String message,
    AppAlertVariant variant = AppAlertVariant.info,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    bool showCloseIcon = false,
  }) {
    final theme = Theme.of(context);
    final colors = _getSnackBarColors(theme, variant);

    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: colors.textColor),
        ),
        backgroundColor: colors.backgroundColor,
        duration: duration,
        action: action,
        showCloseIcon: showCloseIcon,
        closeIconColor: colors.textColor,
      ),
    );
  }

  static _AlertColors _getSnackBarColors(
    ThemeData theme,
    AppAlertVariant variant,
  ) {
    switch (variant) {
      case AppAlertVariant.info:
        return _AlertColors(
          backgroundColor: theme.colorScheme.inverseSurface,
          borderColor: Colors.transparent,
          textColor: theme.colorScheme.onInverseSurface,
          iconColor: theme.colorScheme.onInverseSurface,
        );
      case AppAlertVariant.success:
        return _AlertColors(
          backgroundColor: Colors.green.shade600,
          borderColor: Colors.transparent,
          textColor: Colors.white,
          iconColor: Colors.white,
        );
      case AppAlertVariant.warning:
        return _AlertColors(
          backgroundColor: Colors.orange.shade600,
          borderColor: Colors.transparent,
          textColor: Colors.white,
          iconColor: Colors.white,
        );
      case AppAlertVariant.error:
        return _AlertColors(
          backgroundColor: theme.colorScheme.error,
          borderColor: Colors.transparent,
          textColor: theme.colorScheme.onError,
          iconColor: theme.colorScheme.onError,
        );
    }
  }
}

enum AppAlertVariant { info, success, warning, error }

class _AlertColors {
  const _AlertColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.iconColor,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;
}
