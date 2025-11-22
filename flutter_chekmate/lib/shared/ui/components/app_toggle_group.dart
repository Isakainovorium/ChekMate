import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppToggleGroup - Multi-option toggle button groups
class AppToggleGroup<T> extends StatefulWidget {
  const AppToggleGroup({
    required this.options,
    super.key,
    this.selectedValues = const {},
    this.onSelectionChanged,
    this.allowMultiple = false,
    this.allowEmpty = true,
    this.direction = Axis.horizontal,
    this.spacing = 4.0,
    this.enabled = true,
  });

  final List<AppToggleOption<T>> options;
  final Set<T> selectedValues;
  final ValueChanged<Set<T>>? onSelectionChanged;
  final bool allowMultiple;
  final bool allowEmpty;
  final Axis direction;
  final double spacing;
  final bool enabled;

  @override
  State<AppToggleGroup<T>> createState() => _AppToggleGroupState<T>();
}

class _AppToggleGroupState<T> extends State<AppToggleGroup<T>> {
  late Set<T> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = Set.from(widget.selectedValues);
  }

  @override
  void didUpdateWidget(AppToggleGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValues != oldWidget.selectedValues) {
      _selectedValues = Set.from(widget.selectedValues);
    }
  }

  void _onToggle(T value) {
    if (!widget.enabled) return;

    setState(() {
      if (_selectedValues.contains(value)) {
        // Deselecting
        if (widget.allowEmpty || _selectedValues.length > 1) {
          _selectedValues.remove(value);
        }
      } else {
        // Selecting
        if (widget.allowMultiple) {
          _selectedValues.add(value);
        } else {
          _selectedValues = {value};
        }
      }
    });

    widget.onSelectionChanged?.call(_selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    final children = widget.options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      final isSelected = _selectedValues.contains(option.toARGB32());
      final isFirst = index == 0;
      final isLast = index == widget.options.length - 1;

      return _ToggleButton<T>(
        option: option,
        isSelected: isSelected,
        onTap: () => _onToggle(option.toARGB32()),
        enabled: widget.enabled && option.enabled,
        isFirst: isFirst,
        isLast: isLast,
        direction: widget.direction,
      );
    }).toList();

    if (widget.direction == Axis.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: _addSpacing(children, widget.spacing, Axis.horizontal),
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: _addSpacing(children, widget.spacing, Axis.vertical),
      );
    }
  }

  List<Widget> _addSpacing(
    List<Widget> children,
    double spacing,
    Axis direction,
  ) {
    if (children.isEmpty || spacing == 0) return children;

    final spacedChildren = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(
          direction == Axis.horizontal
              ? SizedBox(width: spacing)
              : SizedBox(height: spacing),
        );
      }
    }
    return spacedChildren;
  }
}

class _ToggleButton<T> extends StatelessWidget {
  const _ToggleButton({
    required this.option,
    required this.isSelected,
    required this.onTap,
    required this.enabled,
    required this.isFirst,
    required this.isLast,
    required this.direction,
  });

  final AppToggleOption<T> option;
  final bool isSelected;
  final VoidCallback onTap;
  final bool enabled;
  final bool isFirst;
  final bool isLast;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    BorderRadius borderRadius;
    if (direction == Axis.horizontal) {
      borderRadius = BorderRadius.horizontal(
        left: isFirst ? const Radius.circular(8) : Radius.zero,
        right: isLast ? const Radius.circular(8) : Radius.zero,
      );
    } else {
      borderRadius = BorderRadius.vertical(
        top: isFirst ? const Radius.circular(8) : Radius.zero,
        bottom: isLast ? const Radius.circular(8) : Radius.zero,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: borderRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surface,
            borderRadius: borderRadius,
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (option.icon != null) ...[
                Icon(
                  option.icon,
                  size: 18,
                  color: enabled
                      ? (isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurface)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                if (option.label != null) const SizedBox(width: AppSpacing.xs),
              ],
              if (option.label != null)
                Text(
                  option.label!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: enabled
                        ? (isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// AppSegmentedControl - iOS-style segmented control
class AppSegmentedControl<T> extends StatefulWidget {
  const AppSegmentedControl({
    required this.options,
    super.key,
    this.selectedValue,
    this.onSelectionChanged,
    this.enabled = true,
  });

  final List<AppToggleOption<T>> options;
  final T? selectedValue;
  final ValueChanged<T>? onSelectionChanged;
  final bool enabled;

  @override
  State<AppSegmentedControl<T>> createState() => _AppSegmentedControlState<T>();
}

class _AppSegmentedControlState<T> extends State<AppSegmentedControl<T>> {
  T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
  }

  @override
  void didUpdateWidget(AppSegmentedControl<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue) {
      _selectedValue = widget.selectedValue;
    }
  }

  void _onSelectionChanged(T value) {
    if (!widget.enabled) return;

    setState(() {
      _selectedValue = value;
    });
    widget.onSelectionChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: widget.options.asMap().entries.map((entry) {
            final option = entry.value;
            final isSelected = _selectedValue == option.value;

            return Flexible(
              child: GestureDetector(
                onTap: widget.enabled && option.enabled
                    ? () => _onSelectionChanged(option.toARGB32())
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (option.icon != null) ...[
                        Icon(
                          option.icon,
                          size: 18,
                          color: widget.enabled && option.enabled
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                        ),
                        if (option.label != null)
                          const SizedBox(width: AppSpacing.xs),
                      ],
                      if (option.label != null)
                        Text(
                          option.label!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: widget.enabled && option.enabled
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// AppToggleChips - Toggle buttons as chips
class AppToggleChips<T> extends StatefulWidget {
  const AppToggleChips({
    required this.options,
    super.key,
    this.selectedValues = const {},
    this.onSelectionChanged,
    this.allowMultiple = true,
    this.spacing = AppSpacing.sm,
    this.runSpacing = AppSpacing.sm,
    this.enabled = true,
  });

  final List<AppToggleOption<T>> options;
  final Set<T> selectedValues;
  final ValueChanged<Set<T>>? onSelectionChanged;
  final bool allowMultiple;
  final double spacing;
  final double runSpacing;
  final bool enabled;

  @override
  State<AppToggleChips<T>> createState() => _AppToggleChipsState<T>();
}

class _AppToggleChipsState<T> extends State<AppToggleChips<T>> {
  late Set<T> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = Set.from(widget.selectedValues);
  }

  @override
  void didUpdateWidget(AppToggleChips<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValues != oldWidget.selectedValues) {
      _selectedValues = Set.from(widget.selectedValues);
    }
  }

  void _onToggle(T value) {
    if (!widget.enabled) return;

    setState(() {
      if (_selectedValues.contains(value)) {
        _selectedValues.remove(value);
      } else {
        if (widget.allowMultiple) {
          _selectedValues.add(value);
        } else {
          _selectedValues = {value};
        }
      }
    });

    widget.onSelectionChanged?.call(_selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: widget.spacing,
      runSpacing: widget.runSpacing,
      children: widget.options.map((option) {
        final isSelected = _selectedValues.contains(option.toARGB32());

        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (option.icon != null) ...[
                Icon(option.icon, size: 16),
                if (option.label != null) const SizedBox(width: AppSpacing.xs),
              ],
              if (option.label != null) Text(option.label!),
            ],
          ),
          selected: isSelected,
          onSelected: widget.enabled && option.enabled
              ? (_) => _onToggle(option.toARGB32())
              : null,
        );
      }).toList(),
    );
  }
}

/// Data class for toggle options
class AppToggleOption<T> {
  const AppToggleOption({
    required this.value,
    this.label,
    this.icon,
    this.enabled = true,
  });

  final T value;
  final String? label;
  final IconData? icon;
  final bool enabled;
}
