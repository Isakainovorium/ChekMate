import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/components/app_input.dart';

/// AppCommandMenu - Alternative command interface (different from command palette)
class AppCommandMenu extends StatefulWidget {
  const AppCommandMenu({
    required this.commands,
    super.key,
    this.onCommandSelected,
    this.groupByCategory = true,
    this.showShortcuts = true,
    this.showIcons = true,
    this.maxHeight = 400,
    this.searchPlaceholder = 'Search commands...',
  });

  final List<AppCommand> commands;
  final ValueChanged<AppCommand>? onCommandSelected;
  final bool groupByCategory;
  final bool showShortcuts;
  final bool showIcons;
  final double maxHeight;
  final String searchPlaceholder;

  @override
  State<AppCommandMenu> createState() => _AppCommandMenuState();
}

class _AppCommandMenuState extends State<AppCommandMenu> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<AppCommand> _filteredCommands = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _filteredCommands = widget.commands;
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCommands = widget.commands;
      } else {
        _filteredCommands = widget.commands.where((command) {
          return command.title.toLowerCase().contains(query) ||
              (command.description?.toLowerCase().contains(query) ?? false) ||
              (command.category?.toLowerCase().contains(query) ?? false) ||
              (command.keywords?.any((k) => k.toLowerCase().contains(query)) ??
                  false);
        }).toList();
      }
      _selectedIndex = 0;
    });
  }

  void _onKeyPressed(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _selectedIndex = (_selectedIndex + 1) % _filteredCommands.length;
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _selectedIndex = (_selectedIndex - 1 + _filteredCommands.length) %
              _filteredCommands.length;
        });
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_filteredCommands.isNotEmpty) {
          _selectCommand(_filteredCommands[_selectedIndex]);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.of(context).pop();
      }
    }
  }

  void _selectCommand(AppCommand command) {
    widget.onCommandSelected?.call(command);
    command.onExecute?.call();
  }

  Map<String?, List<AppCommand>> _groupCommands(List<AppCommand> commands) {
    if (!widget.groupByCategory) {
      return {null: commands};
    }

    final grouped = <String?, List<AppCommand>>{};
    for (final command in commands) {
      final category = command.category;
      grouped.putIfAbsent(category, () => []).add(command);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupedCommands = _groupCommands(_filteredCommands);

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _onKeyPressed,
      child: Container(
        constraints: BoxConstraints(maxHeight: widget.maxHeight),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search input
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppInput(
                controller: _searchController,
                hint: widget.searchPlaceholder,
                prefixIcon: const Icon(Icons.search),
                autofocus: true,
              ),
            ),

            // Commands list
            if (_filteredCommands.isNotEmpty) ...[
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _getTotalItemCount(groupedCommands),
                  itemBuilder: (context, index) {
                    return _buildItem(groupedCommands, index);
                  },
                ),
              ),
            ] else if (_searchController.text.isNotEmpty) ...[
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
                  ],
                ),
              ),
            ],

            // Footer with shortcuts
            if (widget.showShortcuts) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ShortcutHint(keys: ['↑', '↓'], description: 'Navigate'),
                    _ShortcutHint(keys: ['Enter'], description: 'Execute'),
                    _ShortcutHint(keys: ['Esc'], description: 'Close'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int _getTotalItemCount(Map<String?, List<AppCommand>> groupedCommands) {
    var count = 0;
    for (final entry in groupedCommands.entries) {
      if (widget.groupByCategory && entry.key != null) {
        count++; // Category header
      }
      count += entry.value.length; // Commands
    }
    return count;
  }

  Widget _buildItem(Map<String?, List<AppCommand>> groupedCommands, int index) {
    var currentIndex = 0;

    for (final entry in groupedCommands.entries) {
      final category = entry.key;
      final commands = entry.value;

      // Category header
      if (widget.groupByCategory && category != null) {
        if (currentIndex == index) {
          return _CategoryHeader(category: category);
        }
        currentIndex++;
      }

      // Commands
      for (final command in commands) {
        if (currentIndex == index) {
          final commandIndex = _getCommandIndex(command);
          return _CommandItem(
            command: command,
            isSelected: commandIndex == _selectedIndex,
            showIcon: widget.showIcons,
            showShortcut: widget.showShortcuts,
            onTap: () => _selectCommand(command),
          );
        }
        currentIndex++;
      }
    }

    return const SizedBox.shrink();
  }

  int _getCommandIndex(AppCommand command) {
    return _filteredCommands.indexOf(command);
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(
        category,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CommandItem extends StatelessWidget {
  const _CommandItem({
    required this.command,
    required this.isSelected,
    required this.showIcon,
    required this.showShortcut,
    required this.onTap,
  });

  final AppCommand command;
  final bool isSelected;
  final bool showIcon;
  final bool showShortcut;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
              : null,
        ),
        child: Row(
          children: [
            if (showIcon) ...[
              SizedBox(
                width: 24,
                height: 24,
                child: command.icon != null
                    ? Icon(
                        command.icon,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    command.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (command.description != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      command.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showShortcut && command.shortcut != null) ...[
              const SizedBox(width: AppSpacing.md),
              _ShortcutBadge(shortcut: command.shortcut!),
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
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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

/// AppCommandMenuButton - Button that shows command menu
class AppCommandMenuButton extends StatelessWidget {
  const AppCommandMenuButton({
    required this.commands,
    super.key,
    this.onCommandSelected,
    this.icon = Icons.more_vert,
    this.tooltip = 'Commands',
    this.groupByCategory = true,
    this.showShortcuts = true,
    this.showIcons = true,
  });

  final List<AppCommand> commands;
  final ValueChanged<AppCommand>? onCommandSelected;
  final IconData icon;
  final String tooltip;
  final bool groupByCategory;
  final bool showShortcuts;
  final bool showIcons;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppCommand>(
      icon: Icon(icon),
      tooltip: tooltip,
      itemBuilder: (context) => _buildMenuItems(),
      onSelected: (command) {
        onCommandSelected?.call(command);
        command.onExecute?.call();
      },
    );
  }

  List<PopupMenuEntry<AppCommand>> _buildMenuItems() {
    final entries = <PopupMenuEntry<AppCommand>>[];

    if (groupByCategory) {
      final grouped = <String?, List<AppCommand>>{};
      for (final command in commands) {
        grouped.putIfAbsent(command.category, () => []).add(command);
      }

      var isFirst = true;
      for (final entry in grouped.entries) {
        if (!isFirst) {
          entries.add(const PopupMenuDivider());
        }

        if (entry.key != null) {
          entries.add(
            PopupMenuItem<AppCommand>(
              enabled: false,
              child: Text(
                entry.key!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          );
        }

        for (final command in entry.value) {
          entries.add(_buildMenuItem(command));
        }

        isFirst = false;
      }
    } else {
      for (final command in commands) {
        entries.add(_buildMenuItem(command));
      }
    }

    return entries;
  }

  PopupMenuItem<AppCommand> _buildMenuItem(AppCommand command) {
    return PopupMenuItem<AppCommand>(
      value: command,
      child: Row(
        children: [
          if (showIcons) ...[
            SizedBox(
              width: 24,
              child: command.icon != null ? Icon(command.icon, size: 18) : null,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(child: Text(command.title)),
          if (showShortcuts && command.shortcut != null) ...[
            const SizedBox(width: AppSpacing.md),
            Text(
              command.shortcut!,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Data class for commands
class AppCommand {
  const AppCommand({
    required this.title,
    this.description,
    this.icon,
    this.shortcut,
    this.category,
    this.keywords,
    this.onExecute,
    this.enabled = true,
  });

  final String title;
  final String? description;
  final IconData? icon;
  final String? shortcut;
  final String? category;
  final List<String>? keywords;
  final VoidCallback? onExecute;
  final bool enabled;
}
