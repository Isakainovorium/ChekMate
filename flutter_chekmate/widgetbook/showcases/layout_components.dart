import 'package:flutter/material.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:widgetbook/widgetbook.dart';

/// Layout Components Showcases
///
/// Interactive showcases for all layout-related components:
/// 1. AppCard
/// 2. AppSheet
/// 3. AppTabs
/// 4. AppAccordion
/// 5. AppCarousel
/// 6. AppBreadcrumb
/// 7. AppPagination
/// 8. AppMenubar
/// 9. AppSeparator
class LayoutComponentShowcases {
  static List<WidgetbookComponent> get showcases => [
        // AppCard
        WidgetbookComponent(
          name: 'AppCard',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    context.knobs.string(
                      label: 'Content',
                      initialValue: 'Card content goes here',
                    ),
                  ),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'With Custom Padding',
              builder: (context) => const AppCard(
                child: Text('Card with custom padding'),
              ),
            ),
            WidgetbookUseCase(
              name: 'With Elevation',
              builder: (context) => const AppCard(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Card with higher elevation'),
                ),
              ),
            ),
          ],
        ),

        // AppTabs
        WidgetbookComponent(
          name: 'AppTabs',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => const AppTabs(
                tabs: [
                  AppTab(label: 'Tab 1'),
                  AppTab(label: 'Tab 2'),
                  AppTab(label: 'Tab 3'),
                ],
                children: [
                  Center(child: Text('Content 1')),
                  Center(child: Text('Content 2')),
                  Center(child: Text('Content 3')),
                ],
              ),
            ),
            WidgetbookUseCase(
              name: 'With Icons',
              builder: (context) => const AppTabs(
                tabs: [
                  AppTab(label: 'Home', icon: Icon(Icons.home)),
                  AppTab(label: 'Profile', icon: Icon(Icons.person)),
                  AppTab(label: 'Settings', icon: Icon(Icons.settings)),
                ],
                children: [
                  Center(child: Text('Home Content')),
                  Center(child: Text('Profile Content')),
                  Center(child: Text('Settings Content')),
                ],
              ),
            ),
          ],
        ),

        // AppAccordion
        WidgetbookComponent(
          name: 'AppAccordion',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => const AppAccordion(
                items: [
                  AppAccordionItem(
                    title: 'Section 1',
                    content: Text('Content for section 1'),
                  ),
                  AppAccordionItem(
                    title: 'Section 2',
                    content: Text('Content for section 2'),
                  ),
                  AppAccordionItem(
                    title: 'Section 3',
                    content: Text('Content for section 3'),
                  ),
                ],
              ),
            ),
            WidgetbookUseCase(
              name: 'Initially Expanded',
              builder: (context) => const AppAccordion(
                initialExpandedIndexes: {0},
                items: [
                  AppAccordionItem(
                    title: 'Expanded Section',
                    content: Text('This section is expanded by default'),
                  ),
                  AppAccordionItem(
                    title: 'Collapsed Section',
                    content: Text('This section is collapsed'),
                  ),
                ],
              ),
            ),
          ],
        ),

        // AppCarousel
        WidgetbookComponent(
          name: 'AppCarousel',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => AppCarousel(
                items: List.generate(
                  5,
                  (index) => Container(
                    color: Colors.primaries[index % Colors.primaries.length],
                    child: Center(
                      child: Text(
                        'Slide ${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Auto Play',
              builder: (context) => AppCarousel(
                items: List.generate(
                  5,
                  (index) => Container(
                    color: Colors.primaries[index % Colors.primaries.length],
                    child: Center(
                      child: Text(
                        'Auto Slide ${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                ),
                autoPlay: true,
              ),
            ),
          ],
        ),

        // AppBreadcrumb
        WidgetbookComponent(
          name: 'AppBreadcrumb',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => AppBreadcrumb(
                items: [
                  AppBreadcrumbItem(
                    label: 'Home',
                    onTap: () {},
                  ),
                  AppBreadcrumbItem(
                    label: 'Products',
                    onTap: () {},
                  ),
                  AppBreadcrumbItem(
                    label: 'Electronics',
                    onTap: () {},
                  ),
                  const AppBreadcrumbItem(
                    label: 'Phones',
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
          ],
        ),

        // AppSeparator
        WidgetbookComponent(
          name: 'AppSeparator',
          useCases: [
            WidgetbookUseCase(
              name: 'Horizontal',
              builder: (context) => Column(
                children: [
                  const Text('Above separator'),
                  AppSeparator(
                    direction: context.knobs.object.dropdown(
                      label: 'Direction',
                      options: [
                        Axis.horizontal,
                        Axis.vertical,
                      ],
                      initialOption: Axis.horizontal,
                    ),
                  ),
                  const Text('Below separator'),
                ],
              ),
            ),
            WidgetbookUseCase(
              name: 'With Text',
              builder: (context) => const Column(
                children: [
                  Text('Above separator'),
                  AppSeparatorWithText(
                    text: 'OR',
                  ),
                  Text('Below separator'),
                ],
              ),
            ),
          ],
        ),

        // AppSheet
        WidgetbookComponent(
          name: 'AppSheet',
          useCases: [
            WidgetbookUseCase(
              name: 'Bottom Sheet',
              builder: (context) => Center(
                child: AppButton(
                  onPressed: () {
                    AppSheet.show<void>(
                      context: context,
                      title: const Text('Bottom Sheet'),
                      content: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Sheet content goes here'),
                      ),
                    );
                  },
                  child: const Text('Show Bottom Sheet'),
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
              builder: (context) => AppMenubar(
                menus: [
                  AppMenubarItem(
                    label: 'File',
                    items: [
                      AppMenubarDropdownItem(label: 'New', onTap: () {}),
                      AppMenubarDropdownItem(label: 'Open', onTap: () {}),
                      AppMenubarDropdownItem(label: 'Save', onTap: () {}),
                    ],
                  ),
                  AppMenubarItem(
                    label: 'Edit',
                    items: [
                      AppMenubarDropdownItem(label: 'Cut', onTap: () {}),
                      AppMenubarDropdownItem(label: 'Copy', onTap: () {}),
                      AppMenubarDropdownItem(label: 'Paste', onTap: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ];
}
