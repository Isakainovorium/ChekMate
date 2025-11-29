import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppSlider - Slider with consistent styling and labels
class AppSlider extends StatelessWidget {
  const AppSlider({
    required this.value,
    required this.onChanged,
    super.key,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.showValue = false,
    this.valueFormatter,
    this.enabled = true,
    this.activeColor,
    this.inactiveColor,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final bool showValue;
  final String Function(double)? valueFormatter;
  final bool enabled;
  final Color? activeColor;
  final Color? inactiveColor;

  String _formatValue(double value) {
    if (valueFormatter != null) {
      return valueFormatter!(value);
    }
    if (divisions != null) {
      return value.round().toString();
    }
    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || showValue) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Text(
                  label!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: enabled
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              if (showValue)
                Text(
                  _formatValue(value),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: enabled
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: activeColor ?? theme.colorScheme.primary,
            inactiveTrackColor:
                inactiveColor ?? theme.colorScheme.surfaceContainerHighest,
            thumbColor: activeColor ?? theme.colorScheme.primary,
            overlayColor: (activeColor ?? theme.colorScheme.primary)
                .withOpacity(0.12),
            valueIndicatorColor: activeColor ?? theme.colorScheme.primary,
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: enabled ? onChanged : null,
          ),
        ),
        if (divisions != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatValue(min),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                _formatValue(max),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// AppRangeSlider - Range slider for selecting a range of values
class AppRangeSlider extends StatelessWidget {
  const AppRangeSlider({
    required this.values,
    required this.onChanged,
    super.key,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.showValues = false,
    this.valueFormatter,
    this.enabled = true,
    this.activeColor,
    this.inactiveColor,
  });

  final RangeValues values;
  final ValueChanged<RangeValues>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final bool showValues;
  final String Function(double)? valueFormatter;
  final bool enabled;
  final Color? activeColor;
  final Color? inactiveColor;

  String _formatValue(double value) {
    if (valueFormatter != null) {
      return valueFormatter!(value);
    }
    if (divisions != null) {
      return value.round().toString();
    }
    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || showValues) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Text(
                  label!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: enabled
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              if (showValues)
                Text(
                  '${_formatValue(values.start)} - ${_formatValue(values.end)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: enabled
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: activeColor ?? theme.colorScheme.primary,
            inactiveTrackColor:
                inactiveColor ?? theme.colorScheme.surfaceContainerHighest,
            thumbColor: activeColor ?? theme.colorScheme.primary,
            overlayColor: (activeColor ?? theme.colorScheme.primary)
                .withOpacity(0.12),
            valueIndicatorColor: activeColor ?? theme.colorScheme.primary,
          ),
          child: RangeSlider(
            values: RangeValues(
              values.start.clamp(min, max),
              values.end.clamp(min, max),
            ),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: enabled ? onChanged : null,
          ),
        ),
        if (divisions != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatValue(min),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                _formatValue(max),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
