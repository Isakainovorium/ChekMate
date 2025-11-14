import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppDropdownMenu - Context menu with consistent styling
class AppDropdownMenu extends StatelessWidget {
  const AppDropdownMenu({
    required this.items, super.key,
    this.width,
    this.maxHeight,
  });

  final List<AppDropdownMenuItem<dynamic>> items;
  final double? width;
  final double? maxHeight;

  static Future<T?> show<T>({
    required BuildContext context,
    required RelativeRect position,
    required List<AppDropdownMenuItem<T>> items,
    double? width,
    double? maxHeight,
  }) {
    return showMenu<T>(
      context: context,
      position: position,
      items: items.map((item) => PopupMenuItem<T>(
        value: item.value,
        enabled: item.enabled,
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
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  static Future<T?> showFromWidget<T>({
    required BuildContext context,
    required List<AppDropdownMenuItem<T>> items,
    double? width,
    double? maxHeight,
    Offset offset = Offset.zero,
  }) {
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    
    return show<T>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx + offset.dx,
        position.dy + size.height + offset.dy,
        position.dx + size.width + offset.dx,
        position.dy + size.height + 200 + offset.dy,
      ),
      items: items,
      width: width,
      maxHeight: maxHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    // This widget is mainly used for static display
    // The actual dropdown is shown via the static methods
    return Container();
  }
}

/// AppDropdownButton - Button that shows dropdown menu on tap
class AppDropdownButton<T> extends StatelessWidget {
  const AppDropdownButton({
    required this.child, required this.items, super.key,
    this.onSelected,
    this.offset = Offset.zero,
  });

  final Widget child;
  final List<AppDropdownMenuItem<T>> items;
  final ValueChanged<T>? onSelected;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () async {
          final result = await AppDropdownMenu.showFromWidget<T>(
            context: context,
            items: items,
            offset: offset,
          );
          if (result != null) {
            onSelected?.call(result);
          }
        },
        child: child,
      ),
    );
  }
}

/// Data class for dropdown menu items
class AppDropdownMenuItem<T> {
  const AppDropdownMenuItem({
    required this.value,
    required this.label,
    this.leading,
    this.trailing,
    this.enabled = true,
  });

  final T value;
  final String label;
  final Widget? leading;
  final Widget? trailing;
  final bool enabled;
}
