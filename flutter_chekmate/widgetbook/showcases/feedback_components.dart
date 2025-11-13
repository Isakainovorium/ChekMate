import 'package:flutter/material.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:widgetbook/widgetbook.dart';

/// Feedback Components Showcases
///
/// Interactive showcases for all feedback-related components:
/// 1. AppAlert
/// 2. AppBadge
/// 3. AppProgress
/// 4. AppSkeleton
/// 5. AppTooltip
/// 6. AppAvatar
/// 7. AppPopover
/// 8. AppHoverCard
class FeedbackComponentShowcases {
  static List<WidgetbookComponent> get showcases => [
        // AppAlert
        WidgetbookComponent(
          name: 'AppAlert',
          useCases: [
            WidgetbookUseCase(
              name: 'Info',
              builder: (context) => const AppAlert(
                title: 'Information',
                message: 'This is an informational alert',
              ),
            ),
            WidgetbookUseCase(
              name: 'Success',
              builder: (context) => const AppAlert(
                variant: AppAlertVariant.success,
                title: 'Success',
                message: 'Operation completed successfully',
              ),
            ),
            WidgetbookUseCase(
              name: 'Warning',
              builder: (context) => const AppAlert(
                variant: AppAlertVariant.warning,
                title: 'Warning',
                message: 'Please review this warning',
              ),
            ),
            WidgetbookUseCase(
              name: 'Error',
              builder: (context) => const AppAlert(
                variant: AppAlertVariant.error,
                title: 'Error',
                message: 'An error occurred',
              ),
            ),
          ],
        ),

        // AppBadge
        WidgetbookComponent(
          name: 'AppBadge',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => AppBadge(
                label: context.knobs.string(
                  label: 'Label',
                  initialValue: 'New',
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Variants',
              builder: (context) => const Wrap(
                spacing: 8,
                children: [
                  AppBadge(label: 'Primary'),
                  AppBadge(
                      label: 'Secondary', variant: AppBadgeVariant.secondary,),
                  AppBadge(label: 'Success', variant: AppBadgeVariant.success),
                  AppBadge(label: 'Warning', variant: AppBadgeVariant.warning),
                  AppBadge(label: 'Error', variant: AppBadgeVariant.error),
                  AppBadge(label: 'Outline', variant: AppBadgeVariant.outline),
                  AppBadge(label: 'Neutral', variant: AppBadgeVariant.neutral),
                ],
              ),
            ),
          ],
        ),

        // AppProgress
        WidgetbookComponent(
          name: 'AppProgress',
          useCases: [
            WidgetbookUseCase(
              name: 'Linear',
              builder: (context) => AppProgress(
                value: context.knobs.double.slider(
                  label: 'Progress',
                  initialValue: 0.5,
                  max: 1,
                ),
                label: 'Loading...',
                showPercentage: true,
              ),
            ),
            WidgetbookUseCase(
              name: 'With Label',
              builder: (context) => AppProgress(
                value: context.knobs.double.slider(
                  label: 'Progress',
                  initialValue: 0.7,
                  max: 1,
                ),
                label: 'Uploading files',
                showPercentage: true,
              ),
            ),
          ],
        ),

        // AppSkeleton
        WidgetbookComponent(
          name: 'AppSkeleton',
          useCases: [
            WidgetbookUseCase(
              name: 'Basic',
              builder: (context) => AppSkeleton(
                width: context.knobs.double.slider(
                  label: 'Width',
                  initialValue: 200,
                  min: 50,
                  max: 400,
                ),
                height: context.knobs.double.slider(
                  label: 'Height',
                  initialValue: 16,
                  min: 8,
                  max: 100,
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Circular',
              builder: (context) => AppSkeleton(
                width: context.knobs.double.slider(
                  label: 'Size',
                  initialValue: 50,
                  min: 20,
                  max: 100,
                ),
                height: context.knobs.double.slider(
                  label: 'Size',
                  initialValue: 50,
                  min: 20,
                  max: 100,
                ),
                isCircular: true,
              ),
            ),
            WidgetbookUseCase(
              name: 'Card',
              builder: (context) => const AppSkeletonCard(
                width: 300,
              ),
            ),
            WidgetbookUseCase(
              name: 'List',
              builder: (context) => const AppSkeletonList(
                
              ),
            ),
          ],
        ),

        // AppTooltip
        WidgetbookComponent(
          name: 'AppTooltip',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => AppTooltip(
                message: context.knobs.string(
                  label: 'Message',
                  initialValue: 'This is a tooltip',
                ),
                child: const Icon(Icons.info),
              ),
            ),
          ],
        ),

        // AppAvatar
        WidgetbookComponent(
          name: 'AppAvatar',
          useCases: [
            WidgetbookUseCase(
              name: 'With Name',
              builder: (context) => AppAvatar(
                name: context.knobs.string(
                  label: 'Name',
                  initialValue: 'John Doe',
                ),
                size: AppAvatarSize.large,
              ),
            ),
            WidgetbookUseCase(
              name: 'With Image',
              builder: (context) => const AppAvatar(
                imageUrl: 'https://i.pravatar.cc/150?img=1',
                name: 'Jane Smith',
              ),
            ),
            WidgetbookUseCase(
              name: 'Sizes',
              builder: (context) => const Wrap(
                spacing: 16,
                children: [
                  AppAvatar(name: 'Small', size: AppAvatarSize.small),
                  AppAvatar(name: 'Medium'),
                  AppAvatar(name: 'Large', size: AppAvatarSize.large),
                  AppAvatar(name: 'XL', size: AppAvatarSize.extraLarge),
                ],
              ),
            ),
          ],
        ),

        // AppPopover
        WidgetbookComponent(
          name: 'AppPopover',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => Center(
                child: AppPopoverButton(
                  popoverChild: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Popover content'),
                  ),
                  child: AppButton(
                    onPressed: () {},
                    child: const Text('Show Popover'),
                  ),
                ),
              ),
            ),
          ],
        ),

        // AppHoverCard
        WidgetbookComponent(
          name: 'AppHoverCard',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => const Center(
                child: AppHoverCard(
                  hoverContent: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Hover Card Title'),
                        SizedBox(height: 8),
                        Text('Additional information appears on hover'),
                      ],
                    ),
                  ),
                  child: Text('Hover over me'),
                ),
              ),
            ),
          ],
        ),
      ];
}
