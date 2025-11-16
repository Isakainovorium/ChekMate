import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/explore/presentation/providers/explore_providers.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// TrendingContentWidget - Displays trending or popular content
class TrendingContentWidget extends ConsumerWidget {
  const TrendingContentWidget({
    super.key,
    this.isPopular = false,
  });

  final bool isPopular;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentProvider =
        isPopular ? popularContentProvider : trendingContentProvider;
    final contentAsync = ref.watch(contentProvider);

    return contentAsync.when(
      data: (content) {
        if (content.isEmpty) {
          return AppEmptyState(
            icon: isPopular ? Icons.favorite_border : Icons.trending_up,
            title: 'No ${isPopular ? 'popular' : 'trending'} content',
            message:
                'Check back later for ${isPopular ? 'popular' : 'trending'} posts!',
          );
        }

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      isPopular ? Icons.favorite : Icons.trending_up,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      isPopular ? 'Popular Now' : 'Trending Now',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              ...content.asMap().entries.map(
                (entry) {
                  final item = entry.value;
                  return ListTile(
                    leading: item.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.imageUrl!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image),
                                );
                              },
                            ),
                          )
                        : null,
                    title: Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.authorName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.formattedLikes,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.comment,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.formattedComments,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item.timeAgo,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: item.isTrending
                        ? const Icon(
                            Icons.trending_up,
                            color: AppColors.primary,
                          )
                        : null,
                    onTap: () {
                      // Navigate to content detail
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
      loading: () => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  AppSkeleton(width: 18, height: 18, isCircular: true),
                  SizedBox(width: AppSpacing.xs),
                  AppSkeleton(width: 120, height: 16),
                ],
              ),
            ),
            ...List.generate(
              3,
              (index) => const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    AppSkeleton(width: 60, height: 60, borderRadius: 8),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppSkeleton(width: double.infinity, height: 14),
                          SizedBox(height: 4),
                          AppSkeleton(width: 100, height: 12),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              AppSkeleton(width: 50, height: 12),
                              SizedBox(width: 12),
                              AppSkeleton(width: 50, height: 12),
                              SizedBox(width: 12),
                              AppSkeleton(width: 60, height: 12),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      error: (error, stack) => AppEmptyState(
        icon: Icons.error_outline,
        title: 'Error loading content',
        message: error.toString(),
      ),
    );
  }
}
