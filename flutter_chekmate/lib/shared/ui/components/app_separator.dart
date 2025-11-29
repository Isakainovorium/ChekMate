import 'package:flutter/material.dart';

/// AppSeparator - Visual divider with consistent styling
class AppSeparator extends StatelessWidget {
  const AppSeparator({
    super.key,
    this.direction = Axis.horizontal,
    this.thickness = 1.0,
    this.indent = 0.0,
    this.endIndent = 0.0,
    this.color,
    this.height,
    this.width,
  });

  final Axis direction;
  final double thickness;
  final double indent;
  final double endIndent;
  final Color? color;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final separatorColor =
        color ?? theme.colorScheme.outline.withOpacity(0.2);

    if (direction == Axis.horizontal) {
      return Divider(
        thickness: thickness,
        indent: indent,
        endIndent: endIndent,
        color: separatorColor,
        height: height,
      );
    } else {
      return VerticalDivider(
        thickness: thickness,
        indent: indent,
        endIndent: endIndent,
        color: separatorColor,
        width: width,
      );
    }
  }
}

/// AppSeparatorWithText - Separator with text in the middle
class AppSeparatorWithText extends StatelessWidget {
  const AppSeparatorWithText({
    required this.text,
    super.key,
    this.thickness = 1.0,
    this.color,
    this.textStyle,
    this.spacing = 16.0,
  });

  final String text;
  final double thickness;
  final Color? color;
  final TextStyle? textStyle;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final separatorColor =
        color ?? theme.colorScheme.outline.withOpacity(0.2);

    return Row(
      children: [
        Expanded(
          child: Container(
            height: thickness,
            color: separatorColor,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing),
          child: Text(
            text,
            style: textStyle ??
                theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        Expanded(
          child: Container(
            height: thickness,
            color: separatorColor,
          ),
        ),
      ],
    );
  }
}
