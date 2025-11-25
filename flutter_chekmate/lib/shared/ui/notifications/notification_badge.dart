import 'package:flutter/material.dart';

/// Notification Badge Widget
///
/// A small circular badge that displays notification counts.
/// Shows the count as text, with "99+" for counts over 99.
/// Hidden when count is 0.
class NotificationBadge extends StatelessWidget {
  const NotificationBadge({
    required this.count,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    super.key,
  });

  final int count;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final EdgeInsets padding;

  String get _displayText {
    if (count <= 0) return '';
    if (count > 99) return '99+';
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show badge for zero count
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: padding,
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Center(
        child: Text(
          _displayText,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
