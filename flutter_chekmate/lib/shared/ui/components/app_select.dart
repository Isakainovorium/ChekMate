import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppSelect - Dropdown selection with consistent styling
class AppSelect<T> extends StatelessWidget {
  const AppSelect({
    required this.items, required this.onChanged, super.key,
    this.value,
    this.hint,
    this.label,
    this.isExpanded = true,
    this.enabled = true,
  });

  final List<AppSelectItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final T? value;
  final String? hint;
  final String? label;
  final bool isExpanded;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items.map((item) => DropdownMenuItem<T>(
            value: item.value,
            child: Row(
              children: [
                if (item.leading != null) ...[
                  item.leading!,
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(child: Text(item.label)),
                if (item.trailing != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  item.trailing!,
                ],
              ],
            ),
          ),).toList(),
          onChanged: enabled ? onChanged : null,
          isExpanded: isExpanded,
          hint: hint != null ? Text(hint!) : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
        ),
      ],
    );
  }
}

/// Item for AppSelect dropdown
class AppSelectItem<T> {
  const AppSelectItem({
    required this.value,
    required this.label,
    this.leading,
    this.trailing,
  });

  final T value;
  final String label;
  final Widget? leading;
  final Widget? trailing;
}
