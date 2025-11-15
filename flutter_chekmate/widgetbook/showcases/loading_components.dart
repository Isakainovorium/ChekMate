import 'package:flutter/material.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:widgetbook/widgetbook.dart';

/// Loading Components Showcases
///
/// Interactive showcases for all loading-related components:
/// 1. ShimmerLoading
/// 2. ShimmerSkeletons
/// 3. LottieAnimations
/// 4. AppLoadingSpinner
class LoadingComponentShowcases {
  static List<WidgetbookComponent> get showcases => [
        // ShimmerLoading
        WidgetbookComponent(
          name: 'ShimmerLoading',
          useCases: [
            WidgetbookUseCase(
              name: 'Card Shimmer',
              builder: (context) => const ShimmerCard(),
            ),
            WidgetbookUseCase(
              name: 'List Shimmer',
              builder: (context) => ListView.builder(
                itemCount: context.knobs.int.slider(
                  label: 'Items',
                  initialValue: 3,
                  min: 1,
                  max: 10,
                ),
                itemBuilder: (context, index) => const ShimmerListItem(),
              ),
            ),
            WidgetbookUseCase(
              name: 'Grid Shimmer',
              builder: (context) => GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 6,
                itemBuilder: (context, index) => const ShimmerImage(),
              ),
            ),
          ],
        ),

        // ShimmerSkeletons
        WidgetbookComponent(
          name: 'ShimmerSkeletons',
          useCases: [
            WidgetbookUseCase(
              name: 'Post Skeleton',
              builder: (context) => const PostFeedShimmer(),
            ),
            WidgetbookUseCase(
              name: 'Profile Skeleton',
              builder: (context) => const ProfileHeaderShimmer(),
            ),
            WidgetbookUseCase(
              name: 'Story Skeleton',
              builder: (context) => const StoryCircleShimmer(),
            ),
          ],
        ),

        // LottieAnimations
        WidgetbookComponent(
          name: 'LottieAnimations',
          useCases: [
            WidgetbookUseCase(
              name: 'Loading',
              builder: (context) => LoadingAnimation(
                size: context.knobs.double.slider(
                  label: 'Size',
                  initialValue: 100,
                  min: 50,
                  max: 200,
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Success',
              builder: (context) => SuccessAnimation(
                size: context.knobs.double.slider(
                  label: 'Size',
                  initialValue: 100,
                  min: 50,
                  max: 200,
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Error',
              builder: (context) => ErrorAnimation(
                size: context.knobs.double.slider(
                  label: 'Size',
                  initialValue: 100,
                  min: 50,
                  max: 200,
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Empty State',
              builder: (context) => EmptyStateAnimation(
                size: context.knobs.double.slider(
                  label: 'Size',
                  initialValue: 100,
                  min: 50,
                  max: 200,
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
      ];
}
