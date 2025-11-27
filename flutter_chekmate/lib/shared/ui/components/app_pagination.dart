import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppPagination - Pagination controls with consistent styling
class AppPagination extends StatelessWidget {
  const AppPagination({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    super.key,
    this.itemsPerPage,
    this.totalItems,
    this.showPageNumbers = true,
    this.showFirstLast = true,
    this.maxVisiblePages = 5,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final int? itemsPerPage;
  final int? totalItems;
  final bool showPageNumbers;
  final bool showFirstLast;
  final int maxVisiblePages;

  List<int> _getVisiblePages() {
    if (totalPages <= maxVisiblePages) {
      return List.generate(totalPages, (i) => i + 1);
    }

    final half = maxVisiblePages ~/ 2;
    var start = currentPage - half;
    var end = currentPage + half;

    if (start < 1) {
      start = 1;
      end = maxVisiblePages;
    } else if (end > totalPages) {
      end = totalPages;
      start = totalPages - maxVisiblePages + 1;
    }

    return List.generate(end - start + 1, (i) => start + i);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visiblePages = _getVisiblePages();

    return Column(
      children: [
        // Page info
        if (itemsPerPage != null && totalItems != null) ...[
          Text(
            _buildPageInfo(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],

        // Pagination controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // First page
            if (showFirstLast && currentPage > 1) ...[
              _PaginationButton(
                icon: Icons.first_page,
                onPressed: () => onPageChanged(1),
                tooltip: 'First page',
              ),
              const SizedBox(width: AppSpacing.xs),
            ],

            // Previous page
            _PaginationButton(
              icon: Icons.chevron_left,
              onPressed:
                  currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
              tooltip: 'Previous page',
            ),

            const SizedBox(width: AppSpacing.sm),

            // Page numbers
            if (showPageNumbers) ...[
              // Show ellipsis before if needed
              if (visiblePages.first > 1) ...[
                _PaginationButton(
                  text: '1',
                  onPressed: () => onPageChanged(1),
                ),
                if (visiblePages.first > 2) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Text('...', style: theme.textTheme.bodyMedium),
                ],
                const SizedBox(width: AppSpacing.xs),
              ],

              // Visible page numbers
              ...visiblePages.map(
                (page) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: _PaginationButton(
                    text: page.toString(),
                    onPressed:
                        page != currentPage ? () => onPageChanged(page) : null,
                    isSelected: page == currentPage,
                  ),
                ),
              ),

              // Show ellipsis after if needed
              if (visiblePages.last < totalPages) ...[
                const SizedBox(width: AppSpacing.xs),
                if (visiblePages.last < totalPages - 1) ...[
                  Text('...', style: theme.textTheme.bodyMedium),
                  const SizedBox(width: AppSpacing.xs),
                ],
                _PaginationButton(
                  text: totalPages.toString(),
                  onPressed: () => onPageChanged(totalPages),
                ),
              ],
            ] else ...[
              // Simple page indicator
              Text(
                '$currentPage / $totalPages',
                style: theme.textTheme.bodyMedium,
              ),
            ],

            const SizedBox(width: AppSpacing.sm),

            // Next page
            _PaginationButton(
              icon: Icons.chevron_right,
              onPressed: currentPage < totalPages
                  ? () => onPageChanged(currentPage + 1)
                  : null,
              tooltip: 'Next page',
            ),

            // Last page
            if (showFirstLast && currentPage < totalPages) ...[
              const SizedBox(width: AppSpacing.xs),
              _PaginationButton(
                icon: Icons.last_page,
                onPressed: () => onPageChanged(totalPages),
                tooltip: 'Last page',
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _buildPageInfo() {
    final startItem = (currentPage - 1) * itemsPerPage! + 1;
    final endItem = (currentPage * itemsPerPage!).clamp(0, totalItems!);
    return 'Showing $startItem-$endItem of $totalItems items';
  }
}

class _PaginationButton extends StatelessWidget {
  const _PaginationButton({
    this.text,
    this.icon,
    this.onPressed,
    this.isSelected = false,
    this.tooltip,
  });

  final String? text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isSelected;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget button = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary
            : onPressed != null
                ? Colors.transparent
                : theme.colorScheme.surfaceContainerHighest
                    .withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: icon != null
                ? Icon(
                    icon,
                    size: 18,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : onPressed != null
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface
                                .withOpacity(0.5),
                  )
                : Text(
                    text!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : onPressed != null
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface
                                  .withOpacity(0.5),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
