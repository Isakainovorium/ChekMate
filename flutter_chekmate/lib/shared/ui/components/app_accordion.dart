import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppAccordion - Expandable content sections
class AppAccordion extends StatefulWidget {
  const AppAccordion({
    required this.items,
    super.key,
    this.allowMultiple = false,
    this.initialExpandedIndexes = const {},
  });

  final List<AppAccordionItem> items;
  final bool allowMultiple;
  final Set<int> initialExpandedIndexes;

  @override
  State<AppAccordion> createState() => _AppAccordionState();
}

class _AppAccordionState extends State<AppAccordion> {
  late Set<int> _expandedIndexes;

  @override
  void initState() {
    super.initState();
    _expandedIndexes = Set.from(widget.initialExpandedIndexes);
  }

  void _toggleExpansion(int index) {
    setState(() {
      if (_expandedIndexes.contains(index)) {
        _expandedIndexes.remove(index);
      } else {
        if (!widget.allowMultiple) {
          _expandedIndexes.clear();
        }
        _expandedIndexes.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isExpanded = _expandedIndexes.contains(index);

        return _AccordionTile(
          item: item,
          isExpanded: isExpanded,
          onToggle: () => _toggleExpansion(index),
          isFirst: index == 0,
          isLast: index == widget.items.length - 1,
        );
      }).toList(),
    );
  }
}

class _AccordionTile extends StatelessWidget {
  const _AccordionTile({
    required this.item,
    required this.isExpanded,
    required this.onToggle,
    required this.isFirst,
    required this.isLast,
  });

  final AppAccordionItem item;
  final bool isExpanded;
  final VoidCallback onToggle;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: isFirst
              ? BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                )
              : BorderSide.none,
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
          left: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
          right: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        borderRadius: BorderRadius.only(
          topLeft: isFirst ? const Radius.circular(8) : Radius.zero,
          topRight: isFirst ? const Radius.circular(8) : Radius.zero,
          bottomLeft: isLast ? const Radius.circular(8) : Radius.zero,
          bottomRight: isLast ? const Radius.circular(8) : Radius.zero,
        ),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.only(
              topLeft: isFirst ? const Radius.circular(8) : Radius.zero,
              topRight: isFirst ? const Radius.circular(8) : Radius.zero,
              bottomLeft: !isExpanded && isLast
                  ? const Radius.circular(8)
                  : Radius.zero,
              bottomRight: !isExpanded && isLast
                  ? const Radius.circular(8)
                  : Radius.zero,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isExpanded
                    ? theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.5)
                    : null,
              ),
              child: Row(
                children: [
                  if (item.leading != null) ...[
                    item.leading!,
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (item.subtitle != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            item.subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.only(
                  bottomLeft: isLast ? const Radius.circular(8) : Radius.zero,
                  bottomRight: isLast ? const Radius.circular(8) : Radius.zero,
                ),
              ),
              child: item.content,
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

/// AppSimpleAccordion - Single expandable section
class AppSimpleAccordion extends StatefulWidget {
  const AppSimpleAccordion({
    required this.title,
    required this.content,
    super.key,
    this.subtitle,
    this.leading,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
  });

  final String title;
  final Widget content;
  final String? subtitle;
  final Widget? leading;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;

  @override
  State<AppSimpleAccordion> createState() => _AppSimpleAccordionState();
}

class _AppSimpleAccordionState extends State<AppSimpleAccordion> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return _AccordionTile(
      item: AppAccordionItem(
        title: widget.title,
        content: widget.content,
        subtitle: widget.subtitle,
        leading: widget.leading,
      ),
      isExpanded: _isExpanded,
      onToggle: _toggleExpansion,
      isFirst: true,
      isLast: true,
    );
  }
}

/// Data class for accordion items
class AppAccordionItem {
  const AppAccordionItem({
    required this.title,
    required this.content,
    this.subtitle,
    this.leading,
  });

  final String title;
  final Widget content;
  final String? subtitle;
  final Widget? leading;
}
