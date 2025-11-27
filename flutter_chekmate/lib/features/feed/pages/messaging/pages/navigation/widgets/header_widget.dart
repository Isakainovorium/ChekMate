import 'package:flutter/material.dart';

/// Header Widget
/// Displays a header with title and optional actions
class HeaderWidget extends StatelessWidget {
  const HeaderWidget({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.scrollController,
    this.onSearch,
  });

  final String? title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final ScrollController? scrollController;
  final ValueChanged<String>? onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
