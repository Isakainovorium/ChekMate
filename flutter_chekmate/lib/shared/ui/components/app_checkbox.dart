import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppCheckbox - Checkbox with consistent styling and label
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    required this.value, required this.onChanged, super.key,
    this.label,
    this.subtitle,
    this.enabled = true,
    this.tristate = false,
  });

  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final String? subtitle;
  final bool enabled;
  final bool tristate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (label == null && subtitle == null) {
      return Checkbox(
        value: value,
        onChanged: enabled ? onChanged : null,
        tristate: tristate,
      );
    }

    return InkWell(
      onTap: enabled ? () => onChanged?.call(!(value ?? false)) : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: enabled ? onChanged : null,
              tristate: tristate,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (label != null)
                    Text(
                      label!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: enabled 
                          ? theme.colorScheme.onSurface 
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: enabled 
                          ? theme.colorScheme.onSurfaceVariant 
                          : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// AppCheckboxGroup - Group of checkboxes with shared state
class AppCheckboxGroup<T> extends StatelessWidget {
  const AppCheckboxGroup({
    required this.items, required this.selectedValues, required this.onChanged, super.key,
    this.title,
    this.enabled = true,
  });

  final List<AppCheckboxItem<T>> items;
  final Set<T> selectedValues;
  final ValueChanged<Set<T>> onChanged;
  final String? title;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        ...items.map((item) => AppCheckbox(
          value: selectedValues.contains(item.value),
          onChanged: enabled ? (checked) {
            final newSet = Set<T>.from(selectedValues);
            if (checked == true) {
              newSet.add(item.value);
            } else {
              newSet.remove(item.value);
            }
            onChanged(newSet);
          } : null,
          label: item.label,
          subtitle: item.subtitle,
          enabled: enabled && item.enabled,
        ),),
      ],
    );
  }
}

/// Data class for checkbox items
class AppCheckboxItem<T> {
  const AppCheckboxItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.enabled = true,
  });

  final T value;
  final String label;
  final String? subtitle;
  final bool enabled;
}
