import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/explore/presentation/providers/explore_providers.dart';
import 'package:flutter_chekmate/features/feed/widgets/post_detail_modal.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

/// ExploreGridWidget - Instagram-style staggered grid
///
/// Displays trending content in a staggered grid layout similar to Instagram Explore.
/// Uses flutter_staggered_grid_view for dynamic grid layouts.
class ExploreGridWidget extends ConsumerWidget {
  const ExploreGridWidget({
    super.key,
    this.isPopular = false,
  });

  final bool isPopular;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = isPopular
        ? ref.watch(popularContentProvider)
        : ref.watch(trendingContentProvider);

    return contentAsync.when(
      data: (content) {
        if (content.isEmpty) {
          return AppEmptyState(
            icon: Icons.grid_view,
            title: isPopular ? 'No popular content' : 'No trending content',
            message:
                'Check back later for ${isPopular ? 'popular' : 'trending'} posts!',
          );
        }

        return MasonryGridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: content.length,
          itemBuilder: (context, index) {
            final item = content[index];

            // Create varied grid patterns like Instagram
            // Every 7th item is a large square (2x2)
            // Every 3rd item is a tall rectangle (1x2)
            // Others are regular squares (1x1)
            final isLarge = (index + 1) % 7 == 0;
            final isTall = !isLarge && (index + 1) % 3 == 0;

            return AnimatedGridItem(
              index: index,
              child: _ExploreGridItem(
                imageUrl: item.imageUrl ?? '',
                likes: item.likes,
                comments: item.comments,
                isLarge: isLarge,
                isTall: isTall,
                onTap: () {
                  // Navigate to content detail
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => PostDetailModal(
                        username: item.authorName,
                        avatar: item.authorAvatar ?? '',
                        content: item.description,
                        image: item.imageUrl,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
      loading: () => MasonryGridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 12,
        itemBuilder: (context, index) => const _ExploreGridItemSkeleton(),
      ),
      error: (error, stack) => AppEmptyState(
        icon: Icons.error_outline,
        title: 'Error loading content',
        message: error.toString(),
      ),
    );
  }
}

/// Explore Grid Item
class _ExploreGridItem extends StatelessWidget {
  const _ExploreGridItem({
    required this.imageUrl,
    required this.likes,
    required this.comments,
    required this.onTap,
    this.isLarge = false,
    this.isTall = false,
  });

  final String imageUrl;
  final int likes;
  final int comments;
  final VoidCallback onTap;
  final bool isLarge;
  final bool isTall;

  @override
  Widget build(BuildContext context) {
    // Calculate aspect ratio based on grid item type
    final aspectRatio = isLarge ? 1.0 : (isTall ? 0.5 : 1.0);

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image, color: Colors.grey),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey.shade200,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),

            // Overlay on hover/tap
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Stats overlay
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStat(Icons.favorite, likes),
                  _buildStat(Icons.comment, comments),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.white,
          shadows: const [
            Shadow(
              blurRadius: 4,
            ),
          ],
        ),
        const SizedBox(width: 4),
        Text(
          _formatCount(count),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

/// Explore Grid Item Skeleton (Loading State)
class _ExploreGridItemSkeleton extends StatelessWidget {
  const _ExploreGridItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: ShimmerLoading(
        child: Container(
          color: Colors.grey.shade200,
        ),
      ),
    );
  }
}

/// Staggered Grid Example Widget
///
/// Demonstrates different staggered grid layouts.
class StaggeredGridExampleWidget extends StatelessWidget {
  const StaggeredGridExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staggered Grid Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _buildSectionHeader('Masonry Grid (Pinterest-style)'),
          const SizedBox(height: AppSpacing.sm),
          _buildMasonryGrid(),
          const SizedBox(height: AppSpacing.lg),
          _buildSectionHeader('Quilted Grid (Instagram Explore-style)'),
          const SizedBox(height: AppSpacing.sm),
          _buildQuiltedGrid(),
          const SizedBox(height: AppSpacing.lg),
          _buildSectionHeader('Staggered Tile Grid'),
          const SizedBox(height: AppSpacing.sm),
          _buildStaggeredTileGrid(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMasonryGrid() {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 10,
      itemBuilder: (context, index) {
        // Vary heights for masonry effect
        final heights = [150.0, 200.0, 180.0, 220.0, 160.0];
        final height = heights[index % heights.length];

        return Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1 * (index + 1)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'Item ${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuiltedGrid() {
    return GridView.custom(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverQuiltedGridDelegate(
        crossAxisCount: 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        repeatPattern: QuiltedGridRepeatPattern.inverted,
        pattern: [
          const QuiltedGridTile(2, 2), // Large square
          const QuiltedGridTile(1, 1), // Small square
          const QuiltedGridTile(1, 1), // Small square
          const QuiltedGridTile(1, 2), // Wide rectangle
        ],
      ),
      childrenDelegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1 * (index + 1)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                'Item ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
        childCount: 12,
      ),
    );
  }

  Widget _buildStaggeredTileGrid() {
    return StaggeredGrid.count(
      crossAxisCount: 4,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: [
        StaggeredGridTile.count(
          crossAxisCellCount: 2,
          mainAxisCellCount: 2,
          child: _buildGridTile('Large', AppColors.primary),
        ),
        StaggeredGridTile.count(
          crossAxisCellCount: 2,
          mainAxisCellCount: 1,
          child: _buildGridTile('Wide', AppColors.secondary),
        ),
        StaggeredGridTile.count(
          crossAxisCellCount: 1,
          mainAxisCellCount: 1,
          child: _buildGridTile('Small', AppColors.accent),
        ),
        StaggeredGridTile.count(
          crossAxisCellCount: 1,
          mainAxisCellCount: 1,
          child: _buildGridTile('Small', AppColors.accent),
        ),
        StaggeredGridTile.count(
          crossAxisCellCount: 4,
          mainAxisCellCount: 2,
          child: _buildGridTile('Full Width', AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildGridTile(String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
