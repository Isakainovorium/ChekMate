import 'package:flutter/material.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:widgetbook/widgetbook.dart';

/// Navigation Components Showcases
///
/// Interactive showcases for all navigation-related components:
/// 1. AppBreadcrumb
/// 2. AppMenubar
/// 3. AppPagination
/// 4. AppLabel
/// 5. AppToggleGroup
class NavigationComponentShowcases {
  static List<WidgetbookComponent> get showcases => [
        // AppBreadcrumb
        WidgetbookComponent(
          name: 'AppBreadcrumb',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => const AppBreadcrumb(
                items: [
                  AppBreadcrumbItem(label: 'Home', onTap: null),
                  AppBreadcrumbItem(label: 'Category', onTap: null),
                  AppBreadcrumbItem(label: 'Item', onTap: null),
                ],
              ),
            ),
            WidgetbookUseCase(
              name: 'With Icons',
              builder: (context) => const AppBreadcrumb(
                items: [
                  AppBreadcrumbItem(
                    label: 'Home',
                    icon: Icons.home,
                    onTap: null,
                  ),
                  AppBreadcrumbItem(
                    label: 'Settings',
                    icon: Icons.settings,
                    onTap: null,
                  ),
                  AppBreadcrumbItem(
                    label: 'Profile',
                    icon: Icons.person,
                    onTap: null,
                  ),
                ],
              ),
            ),
            WidgetbookUseCase(
              name: 'Long Path',
              builder: (context) => AppBreadcrumb(
                maxItems: context.knobs.int.slider(
                  label: 'Max Items',
                  initialValue: 5,
                  min: 3,
                  max: 8,
                ),
                items: List.generate(
                  8,
                  (index) => AppBreadcrumbItem(
                    label: 'Level ${index + 1}',
                    onTap: null,
                  ),
                ),
              ),
            ),
          ],
        ),

        // AppMenubar
        WidgetbookComponent(
          name: 'AppMenubar',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => const AppMenubar(
                menus: [
                  AppMenubarItem(
                    label: 'File',
                    items: [
                      AppMenubarDropdownItem(label: 'New'),
                      AppMenubarDropdownItem(label: 'Open'),
                      AppMenubarDropdownItem(label: 'Save'),
                    ],
                  ),
                  AppMenubarItem(
                    label: 'Edit',
                    items: [
                      AppMenubarDropdownItem(label: 'Cut'),
                      AppMenubarDropdownItem(label: 'Copy'),
                      AppMenubarDropdownItem(label: 'Paste'),
                    ],
                  ),
                  AppMenubarItem(
                    label: 'View',
                    items: [],
                  ),
                  AppMenubarItem(
                    label: 'Help',
                    items: [],
                  ),
                ],
              ),
            ),
            WidgetbookUseCase(
              name: 'With Icons',
              builder: (context) => const AppMenubar(
                menus: [
                  AppMenubarItem(
                    label: 'Home',
                    items: [
                      AppMenubarDropdownItem(label: 'Home', icon: Icons.home),
                    ],
                  ),
                  AppMenubarItem(
                    label: 'Search',
                    items: [
                      AppMenubarDropdownItem(label: 'Search', icon: Icons.search),
                    ],
                  ),
                  AppMenubarItem(
                    label: 'Profile',
                    items: [
                      AppMenubarDropdownItem(label: 'Profile', icon: Icons.person),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        // AppPagination
        WidgetbookComponent(
          name: 'AppPagination',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => AppPagination(
                currentPage: context.knobs.int.slider(
                  label: 'Current Page',
                  initialValue: 1,
                  min: 1,
                  max: 10,
                ),
                totalPages: 10,
                onPageChanged: (page) {},
              ),
            ),
            WidgetbookUseCase(
              name: 'Many Pages',
              builder: (context) => AppPagination(
                currentPage: 5,
                totalPages: 20,
                maxVisiblePages: context.knobs.int.slider(
                  label: 'Max Visible',
                  initialValue: 5,
                  min: 3,
                  max: 10,
                ),
                onPageChanged: (page) {},
              ),
            ),
            WidgetbookUseCase(
              name: 'With Item Count',
              builder: (context) => AppPagination(
                currentPage: 2,
                totalPages: 5,
                totalItems: 50,
                itemsPerPage: 10,
                onPageChanged: (page) {},
              ),
            ),
          ],
        ),

        // AppLabel
        WidgetbookComponent(
          name: 'AppLabel',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => AppLabel(
                text: context.knobs.string(
                  label: 'Label',
                  initialValue: 'Field Label',
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Required',
              builder: (context) => const AppLabel(
                text: 'Email Address',
                isRequired: true,
              ),
            ),
            WidgetbookUseCase(
              name: 'With Helper Text',
              builder: (context) => const AppLabel(
                text: 'Password',
                helpText: 'Must be at least 8 characters',
              ),
            ),
            WidgetbookUseCase(
              name: 'With Error',
              builder: (context) => const AppLabel(
                text: 'Email',
                error: 'Invalid email address',
              ),
            ),
          ],
        ),

        // AppToggleGroup
        WidgetbookComponent(
          name: 'AppToggleGroup',
          useCases: [
            WidgetbookUseCase(
              name: 'Single Selection',
              builder: (context) => AppToggleGroup<String>(
                allowMultiple: false,
                options: const [
                  AppToggleOption(value: 'option1', label: 'Option 1'),
                  AppToggleOption(value: 'option2', label: 'Option 2'),
                  AppToggleOption(value: 'option3', label: 'Option 3'),
                ],
                onSelectionChanged: (values) {},
              ),
            ),
            WidgetbookUseCase(
              name: 'Multiple Selection',
              builder: (context) => AppToggleGroup<String>(
                allowMultiple: true,
                options: const [
                  AppToggleOption(value: 'red', label: 'Red'),
                  AppToggleOption(value: 'green', label: 'Green'),
                  AppToggleOption(value: 'blue', label: 'Blue'),
                ],
                onSelectionChanged: (values) {},
              ),
            ),
            WidgetbookUseCase(
              name: 'Vertical',
              builder: (context) => AppToggleGroup<String>(
                direction: Axis.vertical,
                options: const [
                  AppToggleOption(value: 'small', label: 'Small'),
                  AppToggleOption(value: 'medium', label: 'Medium'),
                  AppToggleOption(value: 'large', label: 'Large'),
                ],
                onSelectionChanged: (values) {},
              ),
            ),
            WidgetbookUseCase(
              name: 'With Icons',
              builder: (context) => AppToggleGroup<String>(
                options: const [
                  AppToggleOption(
                    value: 'like',
                    label: 'Like',
                    icon: Icons.thumb_up,
                  ),
                  AppToggleOption(
                    value: 'comment',
                    label: 'Comment',
                    icon: Icons.comment,
                  ),
                  AppToggleOption(
                    value: 'share',
                    label: 'Share',
                    icon: Icons.share,
                  ),
                ],
                onSelectionChanged: (values) {},
              ),
            ),
          ],
        ),
      ];
}

