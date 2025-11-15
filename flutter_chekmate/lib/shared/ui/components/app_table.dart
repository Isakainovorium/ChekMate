import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppTable - Data table with consistent styling and features
class AppTable<T> extends StatelessWidget {
  const AppTable({
    required this.columns,
    required this.rows,
    super.key,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
    this.showCheckboxColumn = false,
    this.selectedRows = const {},
    this.onSelectChanged,
    this.onSelectAll,
    this.horizontalMargin = 24.0,
    this.columnSpacing = 56.0,
  });

  final List<AppTableColumn> columns;
  final List<AppTableRow<T>> rows;
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, bool ascending)? onSort;
  final bool showCheckboxColumn;
  final Set<T> selectedRows;
  final ValueChanged<T>? onSelectChanged;
  final ValueChanged<bool>? onSelectAll;
  final double horizontalMargin;
  final double columnSpacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns.asMap().entries.map((entry) {
          final column = entry.value;

          return DataColumn(
            label: Text(
              column.label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            tooltip: column.tooltip,
            numeric: column.numeric,
            onSort: column.sortable && onSort != null
                ? (columnIndex, ascending) => onSort!(columnIndex, ascending)
                : null,
          );
        }).toList(),
        rows: rows.map((row) {
          final isSelected = selectedRows.contains(row.data);

          return DataRow(
            selected: isSelected,
            onSelectChanged: showCheckboxColumn && onSelectChanged != null
                ? (_) => onSelectChanged!(row.data)
                : null,
            cells: row.cells
                .map(
                  (cell) => DataCell(
                    cell.child,
                    showEditIcon: cell.showEditIcon,
                    onTap: cell.onTap,
                    onLongPress: cell.onLongPress,
                    onDoubleTap: cell.onDoubleTap,
                  ),
                )
                .toList(),
          );
        }).toList(),
        sortColumnIndex: sortColumnIndex,
        sortAscending: sortAscending,
        showCheckboxColumn: showCheckboxColumn,
        horizontalMargin: horizontalMargin,
        columnSpacing: columnSpacing,
        headingRowColor: WidgetStatePropertyAll(
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        ),
        dataRowMinHeight: 48,
        dataRowMaxHeight: 64,
      ),
    );
  }
}

/// AppSimpleTable - Simplified table for basic data display
class AppSimpleTable extends StatelessWidget {
  const AppSimpleTable({
    required this.headers,
    required this.rows,
    super.key,
    this.headerStyle,
    this.cellStyle,
    this.showBorders = true,
  });

  final List<String> headers;
  final List<List<String>> rows;
  final TextStyle? headerStyle;
  final TextStyle? cellStyle;
  final bool showBorders;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: showBorders
          ? BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Table(
        border: showBorders
            ? TableBorder.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              )
            : null,
        children: [
          // Header row
          TableRow(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
            ),
            children: headers
                .map(
                  (header) => Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      header,
                      style: headerStyle ??
                          theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                )
                .toList(),
          ),

          // Data rows
          ...rows.map(
            (row) => TableRow(
              children: row
                  .map(
                    (cell) => Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        cell,
                        style: cellStyle ?? theme.textTheme.bodyMedium,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Data classes for table structure
class AppTableColumn {
  const AppTableColumn({
    required this.label,
    this.tooltip,
    this.numeric = false,
    this.sortable = false,
  });

  final String label;
  final String? tooltip;
  final bool numeric;
  final bool sortable;
}

class AppTableRow<T> {
  const AppTableRow({
    required this.data,
    required this.cells,
  });

  final T data;
  final List<AppTableCell> cells;
}

class AppTableCell {
  const AppTableCell({
    required this.child,
    this.showEditIcon = false,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
  });

  final Widget child;
  final bool showEditIcon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
}
