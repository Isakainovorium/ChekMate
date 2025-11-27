import 'package:flutter/material.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:widgetbook/widgetbook.dart';

/// Layout Components Showcases
///
/// Interactive showcases for all layout-related components:
/// 1. AppCard
/// 2. AppTabs
/// 3. AppAccordion
/// 4. AppDrawer
/// 5. AppSheet
/// 6. AppBottomSheet
/// 7. AppCarousel
/// 8. AppAspectRatio
/// 9. AppResizable
/// 10. AppScrollArea
/// 11. AppSeparator
class LayoutComponentShowcases {
  static List<WidgetbookComponent> get showcases => [
        // AppCard
        WidgetbookComponent(
          name: 'AppCard',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => AppCard(
                child: Text(
                  context.knobs.string(
                    label: 'Content',
                    initialValue: 'Card content goes here',
                  ),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'With Padding',
              builder: (context) => const AppCard(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Title', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Card with custom padding'),
                  ],
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'With Elevation',
              builder: (context) => AppCard(
                elevation: context.knobs.double.slider(
                  label: 'Elevation',
                  initialValue: 2.0,
                  min: 0.0,
                  max: 8.0,
                ),
                child: const Text('Card with elevation'),
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
              builder: (context) => const SizedBox(
                height: 400,
                child: AppTabs(
                  tabs: [
                    AppTab(label: 'Tab 1'),
                    AppTab(label: 'Tab 2'),
                    AppTab(label: 'Tab 3'),
                  ],
                  children: [
                    Center(child: Text('Tab 1 Content')),
                    Center(child: Text('Tab 2 Content')),
                    Center(child: Text('Tab 3 Content')),
                  ],
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'With Icons',
              builder: (context) => const SizedBox(
                height: 400,
                child: AppTabs(
                  tabs: [
                    AppTab(label: 'Home', icon: Icon(Icons.home)),
                    AppTab(label: 'Search', icon: Icon(Icons.search)),
                    AppTab(label: 'Profile', icon: Icon(Icons.person)),
                  ],
                  children: [
                    Center(child: Text('Home Content')),
                    Center(child: Text('Search Content')),
                    Center(child: Text('Profile Content')),
                  ],
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Scrollable',
              builder: (context) => SizedBox(
                height: 400,
                child: AppTabs(
                  isScrollable: true,
                  tabs: List.generate(
                    8,
                    (index) => AppTab(label: 'Tab ${index + 1}'),
                  ),
                  children: List.generate(
                    8,
                    (index) => Center(child: Text('Tab ${index + 1} Content')),
                  ),
                ),
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
              name: 'Allow Multiple',
              builder: (context) => const AppAccordion(
                allowMultiple: true,
                items: [
                  AppAccordionItem(
                    title: 'FAQ 1',
                    content: Text('Answer to FAQ 1'),
                  ),
                  AppAccordionItem(
                    title: 'FAQ 2',
                    content: Text('Answer to FAQ 2'),
                  ),
                  AppAccordionItem(
                    title: 'FAQ 3',
                    content: Text('Answer to FAQ 3'),
                  ),
                ],
              ),
            ),
            WidgetbookUseCase(
              name: 'With Icons',
              builder: (context) => const AppAccordion(
                items: [
                  AppAccordionItem(
                    title: 'Settings',
                    leading: Icon(Icons.settings),
                    content: Text('Settings content'),
                  ),
                  AppAccordionItem(
                    title: 'Privacy',
                    leading: Icon(Icons.privacy_tip),
                    content: Text('Privacy content'),
                  ),
                ],
              ),
            ),
          ],
        ),

        // AppDrawer
        WidgetbookComponent(
          name: 'AppDrawer',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => Scaffold(
                drawer: AppDrawer(
                  items: const [
                    AppDrawerItem(
                      title: 'Home',
                      icon: Icons.home,
                    ),
                    AppDrawerItem(
                      title: 'Profile',
                      icon: Icons.person,
                    ),
                    AppDrawerItem(
                      title: 'Settings',
                      icon: Icons.settings,
                    ),
                  ],
                  onItemTap: (index) {},
                ),
                appBar: AppBar(title: const Text('Drawer Example')),
                body: const Center(child: Text('Swipe from left to open drawer')),
              ),
            ),
            WidgetbookUseCase(
              name: 'With Header',
              builder: (context) => Scaffold(
                drawer: AppDrawer(
                  header: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue,
                    child: const Text(
                      'Header',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  items: const [
                    AppDrawerItem(title: 'Item 1', icon: Icons.star),
                    AppDrawerItem(title: 'Item 2', icon: Icons.favorite),
                  ],
                  onItemTap: (index) {},
                ),
                appBar: AppBar(title: const Text('Drawer with Header')),
                body: const Center(child: Text('Open drawer to see header')),
              ),
            ),
          ],
        ),

        // AppSheet
        WidgetbookComponent(
          name: 'AppSheet',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => Center(
                child: AppButton(
                  onPressed: () {
                    AppSheet.show(
                      context: context,
                      content: const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Sheet content'),
                      ),
                    );
                  },
                  child: const Text('Show Sheet'),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'With Title',
              builder: (context) => Center(
                child: AppButton(
                  onPressed: () {
                    AppSheet.show(
                      context: context,
                      title: const Text('Sheet Title'),
                      content: const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Sheet with title'),
                      ),
                    );
                  },
                  child: const Text('Show Sheet with Title'),
                ),
              ),
            ),
          ],
        ),

        // AppBottomSheet
        WidgetbookComponent(
          name: 'AppBottomSheet',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => Center(
                child: AppButton(
                  onPressed: () {
                    AppBottomSheet.show(
                      context: context,
                      content: const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Bottom sheet content'),
                      ),
                    );
                  },
                  child: const Text('Show Bottom Sheet'),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Modal',
              builder: (context) => Center(
                child: AppButton(
                  onPressed: () {
                    AppBottomSheet.show(
                      context: context,
                      content: const Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Modal bottom sheet'),
                            SizedBox(height: 16),
                            Text('This is a modal bottom sheet'),
                          ],
                        ),
                      ),
                    );
                  },
                  child: const Text('Show Modal Bottom Sheet'),
                ),
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
              builder: (context) => SizedBox(
                height: 200,
                child: AppCarousel(
                  items: List.generate(
                    5,
                    (index) => Container(
                      color: Colors.blue.withOpacity(0.3),
                      child: Center(child: Text('Item ${index + 1}')),
                    ),
                  ),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'With Indicators',
              builder: (context) => SizedBox(
                height: 200,
                child: AppCarousel(
                  showIndicators: true,
                  items: List.generate(
                    3,
                    (index) => Container(
                      color: Colors.green.withOpacity(0.3),
                      child: Center(child: Text('Slide ${index + 1}')),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // AppAspectRatio
        WidgetbookComponent(
          name: 'AppAspectRatio',
          useCases: [
            WidgetbookUseCase(
              name: '16:9',
              builder: (context) => AppAspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.blue,
                  child: const Center(child: Text('16:9 Aspect Ratio')),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: '1:1',
              builder: (context) => AppAspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  color: Colors.green,
                  child: const Center(child: Text('1:1 Square')),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: '4:3',
              builder: (context) => AppAspectRatio(
                aspectRatio: 4 / 3,
                child: Container(
                  color: Colors.orange,
                  child: const Center(child: Text('4:3 Aspect Ratio')),
                ),
              ),
            ),
          ],
        ),

        // AppResizable
        WidgetbookComponent(
          name: 'AppResizable',
          useCases: [
            WidgetbookUseCase(
              name: 'Horizontal',
              builder: (context) => SizedBox(
                height: 300,
                child: AppResizable(
                  direction: Axis.horizontal,
                  children: [
                    Container(
                      color: Colors.blue.withOpacity(0.3),
                      child: const Center(child: Text('Left Panel')),
                    ),
                    Container(
                      color: Colors.green.withOpacity(0.3),
                      child: const Center(child: Text('Right Panel')),
                    ),
                  ],
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Vertical',
              builder: (context) => SizedBox(
                height: 300,
                child: AppResizable(
                  direction: Axis.vertical,
                  children: [
                    Container(
                      color: Colors.blue.withOpacity(0.3),
                      child: const Center(child: Text('Top Panel')),
                    ),
                    Container(
                      color: Colors.green.withOpacity(0.3),
                      child: const Center(child: Text('Bottom Panel')),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // AppScrollArea
        WidgetbookComponent(
          name: 'AppScrollArea',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => SizedBox(
                height: 200,
                child: AppScrollArea(
                  child: Column(
                    children: List.generate(
                      20,
                      (index) => ListTile(
                        title: Text('Item ${index + 1}'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'With Padding',
              builder: (context) => SizedBox(
                height: 200,
                child: AppScrollArea(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: List.generate(
                      15,
                      (index) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('Item ${index + 1}'),
                      ),
                    ),
                  ),
                ),
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
              builder: (context) => const Column(
                children: [
                  Text('Item 1'),
                  AppSeparator(),
                  Text('Item 2'),
                  AppSeparator(),
                  Text('Item 3'),
                ],
              ),
            ),
            WidgetbookUseCase(
              name: 'Vertical',
              builder: (context) => const Row(
                children: [
                  Text('Left'),
                  AppSeparator(direction: Axis.vertical),
                  Text('Middle'),
                  AppSeparator(direction: Axis.vertical),
                  Text('Right'),
                ],
              ),
            ),
            WidgetbookUseCase(
              name: 'With Spacing',
              builder: (context) => Column(
                children: [
                  const Text('Item 1'),
                  AppSeparator(
                    height: context.knobs.double.slider(
                      label: 'Spacing',
                      initialValue: 16,
                      min: 0,
                      max: 48,
                    ),
                  ),
                  const Text('Item 2'),
                ],
              ),
            ),
          ],
        ),
      ];
}

