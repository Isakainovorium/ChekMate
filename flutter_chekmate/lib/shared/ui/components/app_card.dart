import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppCard - standard surface with consistent padding and shape
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
    this.child,
    this.elevation = 0.5,
  });

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Widget? child;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: elevation,
      margin: margin,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: padding,
        child: DefaultTextStyle.merge(
          style: theme.textTheme.bodyMedium!,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
