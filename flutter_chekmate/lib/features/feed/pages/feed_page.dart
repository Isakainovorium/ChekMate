import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_chekmate/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_chekmate/features/posts/presentation/providers/posts_providers.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Feed Type Enum
enum FeedType {
  hybrid, // Hybrid feed (60% location + 40% interests)
  following, // Global chronological feed
  nearby, // Location-based feed
  forYou, // Interest-based feed
}

/// Feed Page with Multiple Feed Types
/// Complete implementation with real Firebase data
class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  FeedType _feedType = FeedType.hybrid; // Default to hybrid feed

  @override
  Widget build(BuildContext context) {
    // Watch the appropriate feed provider based on feed type
    final postsAsync = switch (_feedType) {
      FeedType.hybrid => ref.watch(hybridFeedProvider),
      FeedType.following => ref.watch(postsFeedProvider),
      FeedType.nearby => ref.watch(locationBasedFeedProvider),
      FeedType.forYou => ref.watch(interestBasedFeedProvider),
    };

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(_getFeedTitle()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          // Feed type selector button
          IconButton(
            icon: Icon(
              _getFeedIcon(),
              color: AppColors.primary,
            ),
            onPressed: () => _showFeedTypeMenu(context),
            tooltip: 'Change Feed Type',
          ),
        ],
      ),
      body: postsAsync.when(
        data: (dynamic posts) {
          // Convert to List<PostEntity>
          final postsList = posts is List<PostEntity>
              ? posts
              : List<PostEntity>.from(posts as List);

          if (postsList.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              _buildFeedIndicator(),
              Expanded(
                child: AppInfiniteScroll<PostEntity>(
                  items: postsList,
                  itemBuilder: (context, post, index) => AnimatedFeedCard(
                    index: index,
                    child: _PostCardWithViewTracking(post: post),
                  ),
                  onLoadMore: () async {
                    // Load more posts - placeholder for now
                  },
                  onRefresh: () async {
                    // Refresh the feed based on feed type
                    _refreshFeed();
                  },
                  hasMore:
                      false, // Set to false for now, can be made dynamic later
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: AppLoadingSpinner()),
        error: (error, stack) => AppEmptyState(
          type: AppEmptyStateType.noConnection,
          title: 'Something went wrong',
          message: 'Error: $error',
          action: AppButton(
            onPressed: _refreshFeed,
            child: const Text('Retry'),
          ),
        ),
      ),
    );
  }

  String _getFeedTitle() {
    return switch (_feedType) {
      FeedType.hybrid => 'Hybrid Feed',
      FeedType.following => 'Following',
      FeedType.nearby => 'Nearby',
      FeedType.forYou => 'For You',
    };
  }

  IconData _getFeedIcon() {
    return switch (_feedType) {
      FeedType.hybrid => Icons.auto_awesome,
      FeedType.following => Icons.people,
      FeedType.nearby => Icons.location_on,
      FeedType.forYou => Icons.favorite,
    };
  }

  void _showFeedTypeMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hybrid Feed (Recommended)
            ListTile(
              leading: Icon(
                Icons.auto_awesome,
                color: _feedType == FeedType.hybrid
                    ? AppColors.primary
                    : Colors.grey,
              ),
              title: const Text('Hybrid Feed'),
              subtitle:
                  const Text('Best of nearby and interests (Recommended)'),
              trailing: _feedType == FeedType.hybrid
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                Navigator.pop(context);
                setState(() => _feedType = FeedType.hybrid);
              },
            ),
            const Divider(),
            // Following Feed
            ListTile(
              leading: Icon(
                Icons.people,
                color: _feedType == FeedType.following
                    ? AppColors.primary
                    : Colors.grey,
              ),
              title: const Text('Following'),
              subtitle: const Text('Posts from people you follow'),
              trailing: _feedType == FeedType.following
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                Navigator.pop(context);
                setState(() => _feedType = FeedType.following);
              },
            ),
            const Divider(),
            // Nearby Feed
            ListTile(
              leading: Icon(
                Icons.location_on,
                color: _feedType == FeedType.nearby
                    ? AppColors.primary
                    : Colors.grey,
              ),
              title: const Text('Nearby'),
              subtitle: const Text('Posts from your area'),
              trailing: _feedType == FeedType.nearby
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                Navigator.pop(context);
                setState(() => _feedType = FeedType.nearby);
              },
            ),
            const Divider(),
            // For You Feed
            ListTile(
              leading: Icon(
                Icons.favorite,
                color: _feedType == FeedType.forYou
                    ? AppColors.primary
                    : Colors.grey,
              ),
              title: const Text('For You'),
              subtitle: const Text('Posts matching your interests'),
              trailing: _feedType == FeedType.forYou
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                Navigator.pop(context);
                setState(() => _feedType = FeedType.forYou);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _refreshFeed() {
    switch (_feedType) {
      case FeedType.hybrid:
        ref.invalidate(hybridFeedProvider);
      case FeedType.following:
        ref.invalidate(postsFeedProvider);
      case FeedType.nearby:
        ref.invalidate(locationBasedFeedProvider);
      case FeedType.forYou:
        ref.invalidate(interestBasedFeedProvider);
    }
  }

  Widget _buildFeedIndicator() {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            _getFeedIcon(),
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            _getFeedTitle(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final (title, message) = switch (_feedType) {
      FeedType.hybrid => (
          'No posts available',
          'No posts found nearby or matching your interests. Try adjusting your location or interests.'
        ),
      FeedType.following => (
          'No posts yet',
          'Follow people to see their posts here'
        ),
      FeedType.nearby => (
          'No nearby posts',
          'No posts found in your area. Try increasing your search radius in settings.'
        ),
      FeedType.forYou => (
          'No matching posts',
          'No posts found matching your interests. Try adding more interests in your profile.'
        ),
    };

    return AppEmptyState(
      type: AppEmptyStateType.noPosts,
      title: title,
      message: message,
    );
  }
}

/// Post Card with View Tracking
/// Wraps _PostCard with VisibilityDetector to track post views
class _PostCardWithViewTracking extends ConsumerStatefulWidget {
  const _PostCardWithViewTracking({required this.post});
  final PostEntity post;

  @override
  ConsumerState<_PostCardWithViewTracking> createState() =>
      _PostCardWithViewTrackingState();
}

class _PostCardWithViewTrackingState
    extends ConsumerState<_PostCardWithViewTracking> {
  Timer? _viewTimer;
  bool _hasTrackedView = false;

  @override
  void dispose() {
    _viewTimer?.cancel();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    // Only track if post is 50%+ visible
    if (info.visibleFraction >= 0.5 && !_hasTrackedView) {
      // Start timer to track view after 2 seconds
      _viewTimer?.cancel();
      _viewTimer = Timer(const Duration(seconds: 2), () {
        _trackView();
      });
    } else if (info.visibleFraction < 0.5) {
      // Cancel timer if post scrolled out of view before 2 seconds
      _viewTimer?.cancel();
    }
  }

  Future<void> _trackView() async {
    if (_hasTrackedView) return;

    final currentUserId = ref.read(currentUserIdProvider);
    if (currentUserId == null) return;

    // Don't track if user is viewing their own post
    if (widget.post.userId == currentUserId) return;

    // Don't track if user already viewed this post
    if (widget.post.viewedBy.contains(currentUserId)) return;

    try {
      final trackPostViewUseCase = ref.read(trackPostViewUseCaseProvider);
      await trackPostViewUseCase(
        postId: widget.post.id,
        userId: currentUserId,
      );
      _hasTrackedView = true;
    } on Exception catch (e) {
      // Silently fail - don't disrupt user experience
      debugPrint('Failed to track post view: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('post-${widget.post.id}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: _PostCard(post: widget.post),
    );
  }
}

/// Post Card Widget with Riverpod
class _PostCard extends ConsumerWidget {
  const _PostCard({required this.post});
  final PostEntity post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postController = ref.read(postsControllerProvider.notifier);
    final hasLikedAsync = ref.watch(hasLikedPostProvider(post.id));

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                AppAvatar(
                  imageUrl: post.userAvatar,
                  name: post.username,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatTimestamp(post.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz),
                ),
              ],
            ),
          ),
          // Post content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              post.content,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Post actions
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Like button
                hasLikedAsync.when(
                  data: (hasLiked) => _ActionButton(
                    icon: hasLiked ? Icons.favorite : Icons.favorite_border,
                    label: '${post.likes}',
                    color: hasLiked ? Colors.red : Colors.grey.shade600,
                    onTap: () => postController.toggleLike(post.id),
                  ),
                  loading: () => _ActionButton(
                    icon: Icons.favorite_border,
                    label: '${post.likes}',
                    color: Colors.grey.shade600,
                    onTap: () {},
                  ),
                  error: (_, __) => _ActionButton(
                    icon: Icons.favorite_border,
                    label: '${post.likes}',
                    color: Colors.grey.shade600,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: '${post.comments}',
                  color: Colors.grey.shade600,
                  onTap: () {},
                ),
                const SizedBox(width: AppSpacing.lg),
                _ActionButton(
                  icon: Icons.share_outlined,
                  label: '${post.shares}',
                  color: Colors.grey.shade600,
                  onTap: () => postController.sharePost(post.id),
                ),
                const Spacer(),
                // Chek button - ChekMate's unique interaction
                AppButton(
                  onPressed: () {
                    postController.chekPost(post.id);
                  },
                  size: AppButtonSize.sm,
                  leadingIcon: const Icon(Icons.check_circle_outline, size: 16),
                  child: Text('${post.cheks}'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    // Add proper timestamp formatting
    return 'Just now';
  }
}

/// Action Button Widget with Animation
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
