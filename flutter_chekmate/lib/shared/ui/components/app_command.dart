import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// AppCommand - Command palette/search interface
class AppCommand extends StatefulWidget {
  const AppCommand({
    required this.items, super.key,
    this.placeholder = 'Type a command or search...',
    this.onSelected,
    this.showShortcuts = true,
    this.maxHeight = 400,
  });

  final List<AppCommandItem> items;
  final String placeholder;
  final ValueChanged<AppCommandItem>? onSelected;
  final bool showShortcuts;
  final double maxHeight;

  static Future<AppCommandItem?> show({
    required BuildContext context,
    required List<AppCommandItem> items,
    String placeholder = 'Type a command or search...',
    bool showShortcuts = true,
  }) {
    return showDialog<AppCommandItem>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: AppCommand(
            items: items,
            placeholder: placeholder,
            showShortcuts: showShortcuts,
            onSelected: (item) => Navigator.of(context).pop(item),
          ),
        ),
      ),
    );
  }

  @override
  State<AppCommand> createState() => _AppCommandState();
}

class _AppCommandState extends State<AppCommand> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<AppCommandItem> _filteredItems = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _controller.addListener(_onSearchChanged);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _controller.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          return item.label.toLowerCase().contains(query) ||
                 (item.description?.toLowerCase().contains(query) ?? false) ||
                 (item.keywords?.any((k) => k.toLowerCase().contains(query)) ?? false);
        }).toList();
      }
      _selectedIndex = 0;
    });
  }

  void _onKeyPressed(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _selectedIndex = (_selectedIndex + 1) % _filteredItems.length;
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _selectedIndex = (_selectedIndex - 1 + _filteredItems.length) % _filteredItems.length;
        });
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_filteredItems.isNotEmpty) {
          _selectItem(_filteredItems[_selectedIndex]);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.of(context).pop();
      }
    }
  }

  void _selectItem(AppCommandItem item) {
    widget.onSelected?.call(item);
    item.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _onKeyPressed,
      child: AppCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search input
            AppInput(
              controller: _controller,
              hint: widget.placeholder,
              prefixIcon: const Icon(Icons.search),
              autofocus: true,
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            // Results
            if (_filteredItems.isNotEmpty) ...[
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: widget.maxHeight),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];
                    final isSelected = index == _selectedIndex;
                    
                    return _CommandItemTile(
                      item: item,
                      isSelected: isSelected,
                      showShortcuts: widget.showShortcuts,
                      onTap: () => _selectItem(item),
                    );
                  },
                ),
              ),
            ] else if (_controller.text.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'No commands found',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Try a different search term',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Footer
            if (widget.showShortcuts) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ShortcutHint(
                      keys: ['↑', '↓'],
                      description: 'Navigate',
                    ),
                    _ShortcutHint(
                      keys: ['Enter'],
                      description: 'Select',
                    ),
                    _ShortcutHint(
                      keys: ['Esc'],
                      description: 'Close',
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CommandItemTile extends StatelessWidget {
  const _CommandItemTile({
    required this.item,
    required this.isSelected,
    required this.showShortcuts,
    required this.onTap,
  });

  final AppCommandItem item;
  final bool isSelected;
  final bool showShortcuts;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (item.icon != null) ...[
              Icon(
                item.icon,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (item.description != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showShortcuts && item.shortcut != null) ...[
              const SizedBox(width: AppSpacing.md),
              _ShortcutBadge(shortcut: item.shortcut!),
            ],
          ],
        ),
      ),
    );
  }
}

class _ShortcutHint extends StatelessWidget {
  const _ShortcutHint({
    required this.keys,
    required this.description,
  });

  final List<String> keys;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < keys.length; i++) ...[
          if (i > 0) const SizedBox(width: 2),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              keys[i],
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        const SizedBox(width: AppSpacing.xs),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _ShortcutBadge extends StatelessWidget {
  const _ShortcutBadge({required this.shortcut});

  final String shortcut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        shortcut,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),
    );
  }
}

/// Data class for command items
class AppCommandItem {
  const AppCommandItem({
    required this.label,
    this.description,
    this.icon,
    this.shortcut,
    this.keywords,
    this.onTap,
  });

  final String label;
  final String? description;
  final IconData? icon;
  final String? shortcut;
  final List<String>? keywords;
  final VoidCallback? onTap;
}
