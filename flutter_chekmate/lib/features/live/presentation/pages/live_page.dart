import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/live/domain/entities/live_stream_entity.dart';
import 'package:flutter_chekmate/features/live/presentation/pages/go_live_page.dart';
import 'package:flutter_chekmate/features/live/presentation/pages/watch_live_page.dart';
import 'package:flutter_chekmate/features/live/presentation/providers/live_providers.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Live streaming page - ChekMate Dating Experience Platform
/// Share and watch live dating experiences, stories, and community discussions
/// Uses FREE WebRTC + Firebase (no paid streaming services)
class LivePageNew extends ConsumerWidget {
  const LivePageNew({
    required this.userAvatar,
    super.key,
    this.showAppBar = true,
  });
  
  final String userAvatar;
  final bool showAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final streamsAsync = ref.watch(streamsByCategoryProvider(selectedCategory));

    final body = Column(
      children: [
        _buildGoLiveSection(context, ref),
        _buildCategoryTabs(context, ref, selectedCategory),
        Expanded(
          child: streamsAsync.when(
            data: (streams) => streams.isEmpty
                ? _buildEmptyState(context)
                : _buildLiveStreamsGrid(context, streams),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (error, _) => Center(
              child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
            ),
          ),
        ),
        _buildTrendingTopics(context),
      ],
    );

    if (showAppBar) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Live'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: body,
      );
    }

    return body;
  }

  Widget _buildGoLiveSection(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFEC4899)],
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(userAvatar),
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready to share your experience?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Go live and share your dating experiences with the community',
                  style: TextStyle(
                    color: Color(0xFFFECDD3),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          AppButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const GoLivePage(),
                ),
              );
            },
            variant: AppButtonVariant.outline,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.videocam, size: 18),
                SizedBox(width: AppSpacing.xs),
                Text('Go Live'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(BuildContext context, WidgetRef ref, LiveStreamCategory selectedCategory) {
    final categories = [
      LiveStreamCategory.all,
      LiveStreamCategory.experiences,
      LiveStreamCategory.advice,
      LiveStreamCategory.stories,
    ];

    return AppCard(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: categories.map((category) {
            final isActive = selectedCategory == category;
            return GestureDetector(
              onTap: () => ref.read(selectedCategoryProvider.notifier).state = category,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      size: 16,
                      color: isActive ? AppColors.primary : Colors.grey.shade600,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      category.label,
                      style: TextStyle(
                        color: isActive ? AppColors.primary : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(LiveStreamCategory category) {
    switch (category) {
      case LiveStreamCategory.all:
        return Icons.videocam;
      case LiveStreamCategory.experiences:
        return Icons.forum;
      case LiveStreamCategory.advice:
        return Icons.chat_bubble_outline;
      case LiveStreamCategory.stories:
        return Icons.people;
    }
  }

  Widget _buildLiveStreamsGrid(BuildContext context, List<LiveStreamEntity> streams) {
    return Column(
      children: [
        // Stats bar
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🔴 ${streams.length} live streams',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              Text(
                '👀 ${streams.fold(0, (sum, s) => sum + s.viewerCount)} total viewers',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        
        // Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.75,
            ),
            itemCount: streams.length,
            itemBuilder: (context, index) => _buildLiveStreamCard(context, streams[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveStreamCard(BuildContext context, LiveStreamEntity stream) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WatchLivePage(streamId: stream.id),
          ),
        );
      },
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      color: Colors.grey.shade800,
                      image: stream.thumbnailUrl != null
                          ? DecorationImage(
                              image: NetworkImage(stream.thumbnailUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: stream.thumbnailUrl == null
                        ? const Center(
                            child: Icon(Icons.videocam, size: 40, color: Colors.white54),
                          )
                        : null,
                  ),
                  // LIVE badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Viewer count
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.visibility,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            stream.formattedViewerCount,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Stream info
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: stream.hostAvatarUrl.isNotEmpty
                        ? NetworkImage(stream.hostAvatarUrl)
                        : null,
                    backgroundColor: AppColors.primary.withOpacity(0.3),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stream.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                stream.hostName,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (stream.isHostVerified)
                              const Padding(
                                padding: EdgeInsets.only(left: 2),
                                child: Icon(
                                  Icons.verified,
                                  size: 10,
                                  color: AppColors.primary,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off, size: 64, color: Colors.grey),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'No Live Experiences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'No one is sharing experiences live right now.\nBe the first to share your story!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const GoLivePage(),
                  ),
                );
              },
              child: const Text('Share Your Experience Live'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingTopics(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trending Experience Topics',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              '#DateExperiences',
              '#RedFlags',
              '#DateStories',
              '#DatingLessons',
              '#ChekMateRatings',
            ]
                .map(
                  (topic) => Chip(
                    label: Text(topic),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    labelStyle: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
