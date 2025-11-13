import 'package:flutter/material.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:widgetbook/widgetbook.dart';

/// Data Display Components Showcases
///
/// Interactive showcases for all data display components:
/// 1. AppTable
/// 2. AppDropdownMenu
/// 3. AppContextMenu
/// 4. AppCommand
/// 5. AppDialog
/// 6. AppChart
class DataDisplayComponentShowcases {
  static List<WidgetbookComponent> get showcases => [
        // AppTable
        WidgetbookComponent(
          name: 'AppTable',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => const AppTable<int>(
                columns: [
                  AppTableColumn(label: 'Name'),
                  AppTableColumn(label: 'Email'),
                  AppTableColumn(label: 'Role'),
                ],
                rows: [
                  AppTableRow(
                    data: 1,
                    cells: [
                      AppTableCell(child: Text('John Doe')),
                      AppTableCell(child: Text('john@example.com')),
                      AppTableCell(child: Text('Admin')),
                    ],
                  ),
                  AppTableRow(
                    data: 2,
                    cells: [
                      AppTableCell(child: Text('Jane Smith')),
                      AppTableCell(child: Text('jane@example.com')),
                      AppTableCell(child: Text('User')),
                    ],
                  ),
                  AppTableRow(
                    data: 3,
                    cells: [
                      AppTableCell(child: Text('Bob Johnson')),
                      AppTableCell(child: Text('bob@example.com')),
                      AppTableCell(child: Text('User')),
                    ],
                  ),
                ],
              ),
            ),
            WidgetbookUseCase(
              name: 'Sortable',
              builder: (context) => AppTable<int>(
                columns: const [
                  AppTableColumn(label: 'Name', sortable: true),
                  AppTableColumn(label: 'Age', sortable: true, numeric: true),
                  AppTableColumn(label: 'City', sortable: true),
                ],
                rows: const [
                  AppTableRow(
                    data: 1,
                    cells: [
                      AppTableCell(child: Text('Alice')),
                      AppTableCell(child: Text('25')),
                      AppTableCell(child: Text('New York')),
                    ],
                  ),
                  AppTableRow(
                    data: 2,
                    cells: [
                      AppTableCell(child: Text('Bob')),
                      AppTableCell(child: Text('30')),
                      AppTableCell(child: Text('Los Angeles')),
                    ],
                  ),
                  AppTableRow(
                    data: 3,
                    cells: [
                      AppTableCell(child: Text('Charlie')),
                      AppTableCell(child: Text('35')),
                      AppTableCell(child: Text('Chicago')),
                    ],
                  ),
                ],
                onSort: (columnIndex, ascending) {},
              ),
            ),
          ],
        ),

        // AppDropdownButton (AppDropdownMenu is for static methods only)
        WidgetbookComponent(
          name: 'AppDropdownButton',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => AppDropdownButton<String>(
                items: const [
                  AppDropdownMenuItem(
                    value: 'profile',
                    label: 'Profile',
                    leading: Icon(Icons.person),
                  ),
                  AppDropdownMenuItem(
                    value: 'settings',
                    label: 'Settings',
                    leading: Icon(Icons.settings),
                  ),
                  AppDropdownMenuItem(
                    value: 'logout',
                    label: 'Logout',
                    leading: Icon(Icons.logout),
                  ),
                ],
                onSelected: (value) {},
                child: const Icon(Icons.more_vert),
              ),
            ),
          ],
        ),

        // AppContextMenu
        WidgetbookComponent(
          name: 'AppContextMenu',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => Center(
                child: AppContextMenu(
                  menuItems: const [
                    AppContextMenuItem(
                      label: 'Copy',
                      icon: Icons.copy,
                    ),
                    AppContextMenuItem(
                      label: 'Paste',
                      icon: Icons.paste,
                    ),
                    AppContextMenuItem(
                      label: 'Delete',
                      icon: Icons.delete,
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    color: Colors.grey,
                    child: const Text('Right-click me'),
                  ),
                ),
              ),
            ),
          ],
        ),

        // AppCommand
        WidgetbookComponent(
          name: 'AppCommand',
          useCases: [
            WidgetbookUseCase(
              name: 'Command Palette',
              builder: (context) => Center(
                child: AppButton(
                  onPressed: () {
                    AppCommand.show(
                      context: context,
                      items: const [
                        AppCommandItem(
                          label: 'New File',
                          icon: Icons.insert_drive_file,
                        ),
                        AppCommandItem(
                          label: 'New Folder',
                          icon: Icons.folder,
                        ),
                        AppCommandItem(
                          label: 'Settings',
                          icon: Icons.settings,
                        ),
                      ],
                    );
                  },
                  child: const Text('Open Command Palette'),
                ),
              ),
            ),
          ],
        ),

        // AppDialog
        WidgetbookComponent(
          name: 'AppDialog',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => Center(
                child: AppButton(
                  onPressed: () {
                    AppDialog.show<void>(
                      context: context,
                      title: const Text('Dialog Title'),
                      content: const Text('Dialog content goes here'),
                      actions: [
                        AppButton(
                          onPressed: () => Navigator.pop(context),
                          variant: AppButtonVariant.text,
                          child: const Text('Cancel'),
                        ),
                        AppButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Confirm'),
                        ),
                      ],
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Confirm Dialog',
              builder: (context) => Center(
                child: AppButton(
                  onPressed: () {
                    AppConfirmDialog.show(
                      context: context,
                      title: 'Delete Item',
                      content: 'Are you sure you want to delete this item?',
                      confirmText: 'Delete',
                      type: AppConfirmType.destructive,
                    );
                  },
                  child: const Text('Show Confirm Dialog'),
                ),
              ),
            ),
          ],
        ),

        // AppChart
        WidgetbookComponent(
          name: 'AppChart',
          useCases: [
            WidgetbookUseCase(
              name: 'Line Chart',
              builder: (context) => const AppChart(
                type: AppChartType.line,
                data: AppChartData(
                  series: [
                    AppChartSeries(
                      name: 'Weekly Data',
                      dataPoints: [
                        AppChartDataPoint(value: 10, label: 'Mon'),
                        AppChartDataPoint(value: 20, label: 'Tue'),
                        AppChartDataPoint(value: 15, label: 'Wed'),
                        AppChartDataPoint(value: 30, label: 'Thu'),
                        AppChartDataPoint(value: 25, label: 'Fri'),
                        AppChartDataPoint(value: 40, label: 'Sat'),
                        AppChartDataPoint(value: 35, label: 'Sun'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Bar Chart',
              builder: (context) => const AppChart(
                type: AppChartType.bar,
                data: AppChartData(
                  series: [
                    AppChartSeries(
                      name: 'Monthly Data',
                      dataPoints: [
                        AppChartDataPoint(value: 10, label: 'Jan'),
                        AppChartDataPoint(value: 20, label: 'Feb'),
                        AppChartDataPoint(value: 15, label: 'Mar'),
                        AppChartDataPoint(value: 30, label: 'Apr'),
                        AppChartDataPoint(value: 25, label: 'May'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ];
}
