import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppLabel - Consistent form labels with required indicators and help text
class AppLabel extends StatelessWidget {
  const AppLabel({
    required this.text, super.key,
    this.isRequired = false,
    this.helpText,
    this.error,
    this.style,
    this.requiredStyle,
    this.helpStyle,
    this.errorStyle,
  });

  final String text;
  final bool isRequired;
  final String? helpText;
  final String? error;
  final TextStyle? style;
  final TextStyle? requiredStyle;
  final TextStyle? helpStyle;
  final TextStyle? errorStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = error != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main label with required indicator
        Row(
          children: [
            Text(
              text,
              style: style ?? theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: hasError 
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurface,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                '*',
                style: requiredStyle ?? TextStyle(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        
        // Help text
        if (helpText != null && !hasError) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            helpText!,
            style: helpStyle ?? theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        
        // Error text
        if (hasError) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            error!,
            style: errorStyle ?? theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

/// AppFieldLabel - Label specifically designed for form fields
class AppFieldLabel extends StatelessWidget {
  const AppFieldLabel({
    required this.label, super.key,
    this.isRequired = false,
    this.helpText,
    this.error,
    this.child,
    this.spacing = AppSpacing.sm,
  });

  final String label;
  final bool isRequired;
  final String? helpText;
  final String? error;
  final Widget? child;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLabel(
          text: label,
          isRequired: isRequired,
          helpText: helpText,
          error: error,
        ),
        if (child != null) ...[
          SizedBox(height: spacing),
          child!,
        ],
      ],
    );
  }
}

/// AppSectionLabel - Label for form sections and groups
class AppSectionLabel extends StatelessWidget {
  const AppSectionLabel({
    required this.title, super.key,
    this.subtitle,
    this.action,
    this.divider = true,
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (action != null) ...[
              const SizedBox(width: AppSpacing.md),
              action!,
            ],
          ],
        ),
        if (divider) ...[
          const SizedBox(height: AppSpacing.md),
          Divider(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ],
      ],
    );
  }
}
