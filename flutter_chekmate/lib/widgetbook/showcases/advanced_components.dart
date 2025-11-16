import 'package:flutter/material.dart';
import 'package:flutter_chekmate/shared/ui/index.dart' hide AppCommand;
import 'package:flutter_chekmate/shared/ui/components/app_command_menu.dart';
import 'package:widgetbook/widgetbook.dart';

/// Advanced Components Showcases
///
/// Interactive showcases for all advanced components:
/// 1. AppFileUpload
/// 2. AppImageViewer
/// 3. AppVideoPlayer
/// 4. AppInfiniteScroll
/// 5. AppVirtualizedList
/// 6. AppForm
/// 7. AppConfirmDialog
/// 8. AppEmptyState
/// 9. AppErrorBoundary
/// 10. AppNotificationBanner
/// 11. AppLoadingSpinner
/// 12. AppSparkline
/// 13. AppCommandMenu
class AdvancedComponentShowcases {
  static List<WidgetbookComponent> get showcases => [
        // AppFileUpload
        WidgetbookComponent(
          name: 'AppFileUpload',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => SizedBox(
                height: 200,
                child: AppFileUpload(
                  placeholder: context.knobs.string(
                    label: 'Placeholder',
                    initialValue: 'Drag and drop files here',
                  ),
                  onFilesSelected: (files) {},
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Multiple Files',
              builder: (context) => SizedBox(
                height: 200,
                child: AppFileUpload(
                  allowMultiple: true,
                  maxFiles: 5,
                  onFilesSelected: (files) {},
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'With Restrictions',
              builder: (context) => SizedBox(
                height: 200,
                child: AppFileUpload(
                  acceptedTypes: const ['jpg', 'png', 'pdf'],
                  maxFileSize: 5 * 1024 * 1024, // 5MB
                  onFilesSelected: (files) {},
                ),
              ),
            ),
          ],
        ),

        // AppImageViewer
        WidgetbookComponent(
          name: 'AppImageViewer',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => SizedBox(
                height: 300,
                child: AppImageViewer(
                  imageUrl: context.knobs.string(
                    label: 'Image URL',
                    initialValue: 'https://picsum.photos/400/300',
                  ),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'With Zoom',
              builder: (context) => const SizedBox(
                height: 300,
                child: AppImageViewer(
                  imageUrl: 'https://picsum.photos/400/300',
                  allowZoom: true,
                ),
              ),
            ),
          ],
        ),

        // AppVideoPlayer
        WidgetbookComponent(
          name: 'AppVideoPlayer',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => SizedBox(
                height: 300,
                child: AppVideoPlayer(
                  videoUrl: context.knobs.string(
                    label: 'Video URL',
                    initialValue: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
                  ),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'With Controls',
              builder: (context) => const SizedBox(
                height: 300,
                child: AppVideoPlayer(
                  videoUrl: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
                  showControls: true,
                  autoPlay: false,
                ),
              ),
            ),
          ],
        ),

        // AppInfiniteScroll
        WidgetbookComponent(
          name: 'AppInfiniteScroll',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => SizedBox(
                height: 400,
                child: AppInfiniteScroll<String>(
                  items: List.generate(
                    20,
                    (index) => 'Item ${index + 1}',
                  ),
                  itemBuilder: (context, item, index) => ListTile(
                    title: Text(item),
                  ),
                  onLoadMore: () async {},
                  hasMore: true,
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'With Loading',
              builder: (context) => SizedBox(
                height: 400,
                child: AppInfiniteScroll<String>(
                  items: List.generate(10, (index) => 'Item ${index + 1}'),
                  itemBuilder: (context, item, index) => ListTile(
                    title: Text(item),
                  ),
                  onLoadMore: () async {},
                  hasMore: true,
                  isLoading: true,
                ),
              ),
            ),
          ],
        ),

        // AppVirtualizedList
        WidgetbookComponent(
          name: 'AppVirtualizedList',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => SizedBox(
                height: 400,
                child: AppVirtualizedList<String>(
                  items: List.generate(
                    1000,
                    (index) => 'Item ${index + 1}',
                  ),
                  itemBuilder: (context, item, index) => ListTile(
                    title: Text(item),
                  ),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'With Separator',
              builder: (context) => SizedBox(
                height: 400,
                child: AppVirtualizedList<String>(
                  items: List.generate(100, (index) => 'Item ${index + 1}'),
                  itemBuilder: (context, item, index) => ListTile(
                    title: Text(item),
                  ),
                  separatorBuilder: (context, index) => const Divider(),
                ),
              ),
            ),
          ],
        ),

        // AppForm
        WidgetbookComponent(
          name: 'AppForm',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => AppForm(
                onSubmit: (formData) {},
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppInput(
                      label: 'Name',
                      hint: 'Enter name',
                    ),
                    const SizedBox(height: 16),
                    const AppInput(
                      label: 'Email',
                      hint: 'Enter email',
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      onPressed: () {},
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'With Validation',
              builder: (context) => AppForm(
                onSubmit: (formData) {},
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppInput(
                      label: 'Required Field',
                      hint: 'This field is required',
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      onPressed: () {},
                      child: const Text('Validate & Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // AppConfirmDialog
        WidgetbookComponent(
          name: 'AppConfirmDialog',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => Center(
                child: AppButton(
                  onPressed: () {
                    AppConfirmDialog.show(
                      context: context,
                      title: 'Confirm Action',
                      content: 'Are you sure you want to proceed?',
                    );
                  },
                  child: const Text('Show Confirm Dialog'),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Destructive',
              builder: (context) => Center(
                child: AppButton(
                  onPressed: () {
                    AppConfirmDialog.show(
                      context: context,
                      title: 'Delete Item',
                      content: 'This action cannot be undone.',
                      type: AppConfirmType.destructive,
                    );
                  },
                  child: const Text('Show Destructive Dialog'),
                ),
              ),
            ),
          ],
        ),

        // AppEmptyState
        WidgetbookComponent(
          name: 'AppEmptyState',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => AppEmptyState(
                title: context.knobs.string(
                  label: 'Title',
                  initialValue: 'No items found',
                ),
                message: context.knobs.string(
                  label: 'Message',
                  initialValue: 'Try adjusting your filters',
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'With Action',
              builder: (context) => AppEmptyState(
                title: 'No Results',
                message: 'Start by creating your first item',
                action: AppButton(
                  onPressed: () {},
                  child: const Text('Create Item'),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Types',
              builder: (context) => AppEmptyState(
                type: context.knobs.object.dropdown<AppEmptyStateType>(
                  label: 'Type',
                  options: [
                    AppEmptyStateType.noResults,
                    AppEmptyStateType.noConnection,
                    AppEmptyStateType.noData,
                  ],
                  labelBuilder: (type) => type.toString().split('.').last,
                ),
              ),
            ),
          ],
        ),

        // AppErrorBoundary
        WidgetbookComponent(
          name: 'AppErrorBoundary',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => const AppErrorBoundary(
                child: Text('Normal content'),
              ),
            ),
            WidgetbookUseCase(
              name: 'With Fallback',
              builder: (context) => AppErrorBoundary(
                errorBuilder: (context, error, stackTrace) => const Text('Error occurred'),
                child: const Text('Content that might error'),
              ),
            ),
          ],
        ),

        // AppNotificationBanner
        WidgetbookComponent(
          name: 'AppNotificationBanner',
          useCases: [
            WidgetbookUseCase(
              name: 'Success',
              builder: (context) => Center(
                child: AppButton(
                  onPressed: () {
                    AppNotificationBanner.show(
                      context: context,
                      message: 'Operation completed successfully',
                      type: AppNotificationBannerType.success,
                    );
                  },
                  child: const Text('Show Success Banner'),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Error',
              builder: (context) => Center(
                child: AppButton(
                  onPressed: () {
                    AppNotificationBanner.show(
                      context: context,
                      message: 'An error occurred',
                      type: AppNotificationBannerType.error,
                    );
                  },
                  child: const Text('Show Error Banner'),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Info',
              builder: (context) => Center(
                child: AppButton(
                  onPressed: () {
                    AppNotificationBanner.show(
                      context: context,
                      message: 'Here is some information',
                      type: AppNotificationBannerType.info,
                    );
                  },
                  child: const Text('Show Info Banner'),
                ),
              ),
            ),
          ],
        ),

        // AppLoadingSpinner
        WidgetbookComponent(
          name: 'AppLoadingSpinner',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => AppLoadingSpinner(
                size: AppLoadingSize.values[context.knobs.int.slider(
                  label: 'Size',
                  initialValue: 1,
                  max: 3,
                )],
              ),
            ),
            WidgetbookUseCase(
              name: 'With Message',
              builder: (context) => AppLoadingSpinner(
                message: context.knobs.string(
                  label: 'Message',
                  initialValue: 'Loading...',
                ),
              ),
            ),
          ],
        ),

        // AppSparkline
        WidgetbookComponent(
          name: 'AppSparkline',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => SizedBox(
                height: 100,
                child: AppSparkline(
                  data: List.generate(
                    20,
                    (index) => (index * 10.0) % 100,
                  ),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'With Color',
              builder: (context) => SizedBox(
                height: 100,
                child: AppSparkline(
                  data: List.generate(15, (index) => index * 5.0),
                  lineColor: Colors.blue,
                ),
              ),
            ),
          ],
        ),

        // AppCommandMenu
        WidgetbookComponent(
          name: 'AppCommandMenu',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => Center(
                child: AppButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => Dialog(
                        backgroundColor: Colors.transparent,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: AppCommandMenu(
                            commands: const [
                              AppCommand(
                                title: 'New File',
                                icon: Icons.insert_drive_file,
                              ),
                              AppCommand(
                                title: 'New Folder',
                                icon: Icons.folder,
                              ),
                              AppCommand(
                                title: 'Settings',
                                icon: Icons.settings,
                              ),
                            ],
                            onCommandSelected: (command) {
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Show Command Menu'),
                ),
              ),
            ),
          ],
        ),
      ];
}

