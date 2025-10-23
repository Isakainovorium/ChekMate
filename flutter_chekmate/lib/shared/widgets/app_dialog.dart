import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

class AppDialog {
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) {
    return AppConfirmDialog.show(
      context: context,
      title: title,
      content: message,
      confirmText: confirmText,
      cancelText: cancelText,
      type: isDestructive ? AppConfirmType.destructive : AppConfirmType.normal,
    );
  }

  static Future<void> showInfoDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          AppButton(
            onPressed: () => Navigator.of(context).pop(),
            size: AppButtonSize.sm,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  static Future<String?> showInputDialog({
    required BuildContext context,
    required String title,
    String? hint,
    String? initialValue,
    String confirmText = 'Submit',
    String cancelText = 'Cancel',
  }) {
    final controller = TextEditingController(text: initialValue);

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          autofocus: true,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(cancelText),
          ),
          AppButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            size: AppButtonSize.sm,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}

class AppBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }

  static Future<T?> showOptions<T>({
    required BuildContext context,
    required String title,
    required List<BottomSheetOption<T>> options,
  }) {
    return show<T>(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 1),
          ...options.map(
            (option) => ListTile(
              leading: option.icon != null
                  ? Icon(
                      option.icon,
                      color: option.isDestructive ? AppColors.error : null,
                    )
                  : null,
              title: Text(
                option.label,
                style: TextStyle(
                  color: option.isDestructive ? AppColors.error : null,
                ),
              ),
              onTap: () => Navigator.of(context).pop(option.value),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomSheetOption<T> {
  const BottomSheetOption({
    required this.label,
    required this.value,
    this.icon,
    this.isDestructive = false,
  });
  final String label;
  final T value;
  final IconData? icon;
  final bool isDestructive;
}
