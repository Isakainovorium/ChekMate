import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppConfirmDialog - Comprehensive confirmation dialogs
class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    required this.title,
    required this.content,
    super.key,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.type = AppConfirmType.normal,
    this.icon,
    this.showIcon = true,
  });

  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final AppConfirmType type;
  final IconData? icon;
  final bool showIcon;

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    AppConfirmType type = AppConfirmType.normal,
    IconData? icon,
    bool showIcon = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AppConfirmDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        type: type,
        icon: icon,
        showIcon: showIcon,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _getTypeConfig(type, theme);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          if (showIcon) ...[
            Icon(
              icon ?? config.icon,
              color: config.iconColor,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        content,
        style: theme.textTheme.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: config.confirmButtonColor,
            foregroundColor: config.confirmTextColor,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }

  _ConfirmTypeConfig _getTypeConfig(AppConfirmType type, ThemeData theme) {
    switch (type) {
      case AppConfirmType.destructive:
        return _ConfirmTypeConfig(
          icon: Icons.warning,
          iconColor: theme.colorScheme.error,
          confirmButtonColor: theme.colorScheme.error,
          confirmTextColor: theme.colorScheme.onError,
        );
      case AppConfirmType.warning:
        return const _ConfirmTypeConfig(
          icon: Icons.warning_amber,
          iconColor: Colors.orange,
          confirmButtonColor: Colors.orange,
          confirmTextColor: Colors.white,
        );
      case AppConfirmType.info:
        return _ConfirmTypeConfig(
          icon: Icons.info,
          iconColor: theme.colorScheme.primary,
          confirmButtonColor: theme.colorScheme.primary,
          confirmTextColor: theme.colorScheme.onPrimary,
        );
      case AppConfirmType.normal:
        return _ConfirmTypeConfig(
          icon: Icons.help_outline,
          iconColor: theme.colorScheme.primary,
          confirmButtonColor: theme.colorScheme.primary,
          confirmTextColor: theme.colorScheme.onPrimary,
        );
    }
  }
}

/// AppDeleteConfirmDialog - Specialized delete confirmation
class AppDeleteConfirmDialog extends StatelessWidget {
  const AppDeleteConfirmDialog({
    required this.itemName,
    super.key,
    this.itemType = 'item',
    this.additionalWarning,
    this.onConfirm,
    this.onCancel,
  });

  final String itemName;
  final String itemType;
  final String? additionalWarning;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  static Future<bool?> show({
    required BuildContext context,
    required String itemName,
    String itemType = 'item',
    String? additionalWarning,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AppDeleteConfirmDialog(
        itemName: itemName,
        itemType: itemType,
        additionalWarning: additionalWarning,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.delete_forever,
            color: theme.colorScheme.error,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Delete $itemType',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                const TextSpan(text: 'Are you sure you want to delete '),
                TextSpan(
                  text: '"$itemName"',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const TextSpan(text: '?'),
              ],
            ),
          ),
          if (additionalWarning != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: theme.colorScheme.onErrorContainer,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      additionalWarning!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            'This action cannot be undone.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

/// AppLogoutConfirmDialog - Specialized logout confirmation
class AppLogoutConfirmDialog extends StatelessWidget {
  const AppLogoutConfirmDialog({
    super.key,
    this.onConfirm,
    this.onCancel,
  });

  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  static Future<bool?> show({required BuildContext context}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AppLogoutConfirmDialog(
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.logout,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Sign Out',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: const Text('Are you sure you want to sign out?'),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
          child: const Text('Sign Out'),
        ),
      ],
    );
  }
}

/// AppUnsavedChangesDialog - Dialog for unsaved changes
class AppUnsavedChangesDialog extends StatelessWidget {
  const AppUnsavedChangesDialog({
    super.key,
    this.onSave,
    this.onDiscard,
    this.onCancel,
  });

  final VoidCallback? onSave;
  final VoidCallback? onDiscard;
  final VoidCallback? onCancel;

  static Future<AppUnsavedChangesAction?> show({
    required BuildContext context,
  }) {
    return showDialog<AppUnsavedChangesAction>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AppUnsavedChangesDialog(
        onSave: () => Navigator.of(context).pop(AppUnsavedChangesAction.save),
        onDiscard: () =>
            Navigator.of(context).pop(AppUnsavedChangesAction.discard),
        onCancel: () =>
            Navigator.of(context).pop(AppUnsavedChangesAction.cancel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          const Icon(
            Icons.edit_note,
            color: Colors.orange,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Unsaved Changes',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: const Text(
        'You have unsaved changes. What would you like to do?',
      ),
      actions: [
        TextButton(
          onPressed: onCancel ??
              () => Navigator.of(context).pop(AppUnsavedChangesAction.cancel),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: onDiscard ??
              () => Navigator.of(context).pop(AppUnsavedChangesAction.discard),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
          ),
          child: const Text('Discard'),
        ),
        ElevatedButton(
          onPressed: onSave ??
              () => Navigator.of(context).pop(AppUnsavedChangesAction.save),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// AppPermissionDialog - Dialog for requesting permissions
class AppPermissionDialog extends StatelessWidget {
  const AppPermissionDialog({
    required this.permissionName,
    required this.reason,
    super.key,
    this.onGrant,
    this.onDeny,
  });

  final String permissionName;
  final String reason;
  final VoidCallback? onGrant;
  final VoidCallback? onDeny;

  static Future<bool?> show({
    required BuildContext context,
    required String permissionName,
    required String reason,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AppPermissionDialog(
        permissionName: permissionName,
        reason: reason,
        onGrant: () => Navigator.of(context).pop(true),
        onDeny: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.security,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Permission Required',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This app needs access to $permissionName.',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            reason,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onDeny ?? () => Navigator.of(context).pop(false),
          child: const Text('Deny'),
        ),
        ElevatedButton(
          onPressed: onGrant ?? () => Navigator.of(context).pop(true),
          child: const Text('Allow'),
        ),
      ],
    );
  }
}

/// AppCustomConfirmDialog - Customizable confirmation dialog
class AppCustomConfirmDialog extends StatelessWidget {
  const AppCustomConfirmDialog({
    required this.title,
    required this.content,
    super.key,
    this.actions = const [],
    this.icon,
    this.iconColor,
  });

  final String title;
  final Widget content;
  final List<AppDialogAction> actions;
  final IconData? icon;
  final Color? iconColor;

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    required List<AppDialogAction> actions,
    IconData? icon,
    Color? iconColor,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AppCustomConfirmDialog(
        title: title,
        content: content,
        actions: actions,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: iconColor ?? theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      content: content,
      actions: actions.map((action) {
        if (action.isPrimary) {
          return ElevatedButton(
            onPressed: action.onPressed,
            style: action.style,
            child: Text(action.text),
          );
        } else {
          return TextButton(
            onPressed: action.onPressed,
            style: action.style,
            child: Text(action.text),
          );
        }
      }).toList(),
    );
  }
}

/// Configuration classes
class _ConfirmTypeConfig {
  const _ConfirmTypeConfig({
    required this.icon,
    required this.iconColor,
    required this.confirmButtonColor,
    required this.confirmTextColor,
  });
  final IconData icon;
  final Color iconColor;
  final Color confirmButtonColor;
  final Color confirmTextColor;
}

class AppDialogAction {
  const AppDialogAction({
    required this.text,
    this.onPressed,
    this.isPrimary = false,
    this.style,
  });
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final ButtonStyle? style;
}

/// Enums for dialog types and actions
enum AppConfirmType {
  normal,
  destructive,
  warning,
  info,
}

enum AppUnsavedChangesAction {
  save,
  discard,
  cancel,
}
