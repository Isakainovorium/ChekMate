import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/explore/presentation/providers/explore_providers.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// HashtagsWidget - Displays trending hashtags
class HashtagsWidget extends ConsumerWidget {
  const HashtagsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hashtagsAsync = ref.watch(trendingHashtagsProvider);

    return hashtagsAsync.when(
      data: (hashtags) {
        if (hashtags.isEmpty) {
          return const AppEmptyState(
            icon: Icons.tag,
            title: 'No trending hashtags',
            message: 'Check back later for trending hashtags!',
          );
        }

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(Icons.tag, size: 18, color: AppColors.primary),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'Trending Hashtags',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                ),
                itemCount: hashtags.length,
                itemBuilder: (context, index) {
                  final hashtag = hashtags[index];
                  return AnimatedGridItem(
                    index: index,
                    child: AppButton(
                      onPressed: () {
                        // Navigate to hashtag feed
                      },
                      variant: AppButtonVariant.outline,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            hashtag.tag,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hashtag.formattedPostCount,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => AppEmptyState(
        icon: Icons.error_outline,
        title: 'Error loading hashtags',
        message: error.toString(),
      ),
    );
  }
}
