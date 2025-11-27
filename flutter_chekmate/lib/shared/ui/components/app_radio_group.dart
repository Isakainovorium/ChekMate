import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppRadioGroup - Radio button group with consistent styling
class AppRadioGroup<T> extends StatelessWidget {
  const AppRadioGroup({
    required this.items,
    required this.value,
    required this.onChanged,
    super.key,
    this.title,
    this.enabled = true,
    this.direction = Axis.vertical,
  });

  final List<AppRadioItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? title;
  final bool enabled;
  final Axis direction;

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
        if (direction == Axis.vertical)
          Column(
            children: items
                .map(
                  (item) => _RadioTile<T>(
                    item: item,
                    groupValue: value,
                    onChanged: enabled ? onChanged : null,
                  ),
                )
                .toList(),
          )
        else
          Wrap(
            spacing: AppSpacing.md,
            children: items
                .map(
                  (item) => _RadioTile<T>(
                    item: item,
                    groupValue: value,
                    onChanged: enabled ? onChanged : null,
                    isCompact: true,
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _RadioTile<T> extends StatelessWidget {
  const _RadioTile({
    required this.item,
    required this.groupValue,
    required this.onChanged,
    this.isCompact = false,
  });

  final AppRadioItem<T> item;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isCompact) {
      return InkWell(
        onTap: item.enabled && onChanged != null
            ? () => onChanged!(item.value)
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ignore: deprecated_member_use
              Radio<T>.adaptive(
                value: item.value,
                // ignore: deprecated_member_use
                groupValue: groupValue,
                // ignore: deprecated_member_use
                onChanged: item.enabled ? onChanged : null,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                item.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: item.enabled
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: item.enabled && onChanged != null
          ? () => onChanged!(item.value)
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            // ignore: deprecated_member_use
            Radio<T>.adaptive(
              value: item.value,
              // ignore: deprecated_member_use
              groupValue: groupValue,
              // ignore: deprecated_member_use
              onChanged: item.enabled ? onChanged : null,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: item.enabled
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: item.enabled
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.6),
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

/// Data class for radio button items
class AppRadioItem<T> {
  const AppRadioItem({
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
