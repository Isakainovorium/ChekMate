import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_chekmate/features/feed/models/post_model.dart';
import 'package:flutter_chekmate/features/feed/presentation/providers/feed_providers.dart';
import 'package:flutter_chekmate/features/feed/widgets/post_widget.dart';
import 'package:flutter_chekmate/features/intelligence/presentation/providers/serendipity_feed_provider.dart';
import 'package:flutter_chekmate/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_chekmate/shared/ui/index.dart' hide AnimatedFeedCard;
import 'package:flutter_chekmate/shared/widgets/animated_feed_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Feed Type Enum
enum FeedType {
  hybrid, // Hybrid feed (60% location + 40% interests)
  following, // Global chronological feed
  nearby, // Location-based feed
  forYou, // Interest-based feed
  serendipity, // Serendipity mode (diverse content discovery)
}

/// Feed Page with Multiple Feed Types
/// Complete implementation with real Firebase data
class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({
    super.key,
    this.showAppBar = true,
    this.initialFeedType = FeedType.hybrid,
  });

  final bool showAppBar;
  final FeedType initialFeedType;

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  late FeedType _feedType;

  @override
  void initState() {
    super.initState();
    _feedType = widget.initialFeedType;
  }

  @override
  Widget build(BuildContext context) {
    // Watch the appropriate feed provider based on feed type
    final postsAsync = switch (_feedType) {
      FeedType.hybrid => ref.watch(hybridFeedProvider),
      FeedType.following => ref.watch(postsFeedProvider),
      FeedType.nearby => ref.watch(locationBasedFeedProvider),
      FeedType.forYou => ref.watch(interestBasedFeedProvider),
      FeedType.serendipity => ref.watch(serendipityFeedProvider),
    };

    final content = postsAsync.when(
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
            if (widget.showAppBar) _buildFeedIndicator(),
            Expanded(
              child: AppInfiniteScroll<PostEntity>(
                items: postsList,
                itemBuilder: (context, post, index) => AnimatedFeedCard(
                  index: index,
                  child: _PostCardWithViewTracking(
                    post: post,
                    isSerendipity: _feedType == FeedType.serendipity,
                  ),
                ),
                onLoadMore: () async {
                  // Load more posts
                },
                onRefresh: () async {
                  _refreshFeed();
                },
                hasMore: false,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              ),
            ),
          ],
        );
      },
      loading: () => const PostFeedShimmer(),
      error: (error, stack) => _buildErrorState(context, error),
    );

    // Return content directly if no AppBar needed (embedded mode)
    if (!widget.showAppBar) {
      return content;
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(_getFeedTitle()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
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
      body: content,
    );
  }

  String _getFeedTitle() {
    return switch (_feedType) {
      FeedType.hybrid => 'Hybrid Feed',
      FeedType.following => 'Following',
      FeedType.nearby => 'Nearby',
      FeedType.forYou => 'For You',
      FeedType.serendipity => 'Serendipity',
    };
  }

  IconData _getFeedIcon() {
    return switch (_feedType) {
      FeedType.hybrid => Icons.auto_awesome,
      FeedType.following => Icons.people,
      FeedType.nearby => Icons.location_on,
      FeedType.forYou => Icons.favorite,
      FeedType.serendipity => Icons.explore,
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
            const Divider(),
            // Serendipity Feed
            ListTile(
              leading: Icon(
                Icons.explore,
                color: _feedType == FeedType.serendipity
                    ? AppColors.primary
                    : Colors.grey,
              ),
              title: const Text('Serendipity'),
              subtitle: const Text('Discover diverse perspectives'),
              trailing: _feedType == FeedType.serendipity
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                Navigator.pop(context);
                setState(() => _feedType = FeedType.serendipity);
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
      case FeedType.serendipity:
        ref.invalidate(serendipityFeedProvider);
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
      FeedType.serendipity => (
          'No diverse content',
          'Explore different perspectives and experiences. Keep reading to build your serendipity profile.'
        ),
    };

    return AppEmptyState(
      type: AppEmptyStateType.noPosts,
      title: title,
      message: message,
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return AppEmptyState(
      type: AppEmptyStateType.noConnection,
      title: 'Something went wrong',
      message: 'Error: $error',
      action: AppButton(
        onPressed: _refreshFeed,
        child: const Text('Retry'),
      ),
    );
  }
}

/// Post Card with View Tracking
/// Wraps _PostCard with VisibilityDetector to track post views
class _PostCardWithViewTracking extends ConsumerStatefulWidget {
  const _PostCardWithViewTracking({
    required this.post,
    this.isSerendipity = false,
  });
  final PostEntity post;
  final bool isSerendipity;

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
    final postController = ref.read(postsControllerProvider);

    // Map PostEntity to Post model for the rich widget
    final postModel = Post(
      id: widget.post.id,
      userId: widget.post.userId,
      username: widget.post.username,
      userAvatar: widget.post.userAvatar,
      content: widget.post.content,
      images: widget.post.images,
      videoUrl: widget.post.videoUrl,
      likes: widget.post.likes,
      comments: widget.post.comments,
      shares: widget.post.shares,
      cheks: widget.post.cheks,
      timestamp: widget.post.createdAt,
      isLiked: widget.post.isLikedBy(ref.read(currentUserIdProvider) ?? ''),
      isBookmarked:
          widget.post.isBookmarkedBy(ref.read(currentUserIdProvider) ?? ''),
      isCheked: widget.post.isChekedBy(ref.read(currentUserIdProvider) ?? ''),
      location: widget.post.location,
      tags: widget.post.tags,
      // Note: likedByNames would ideally come from a denormalized field
      // or be fetched separately. For now, likedBy contains user IDs.
      // The PostWidget will gracefully fallback to showing "X likes" if empty.
      likedByNames: const [],
    );

    return VisibilityDetector(
      key: Key('post-${widget.post.id}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: Stack(
        children: [
          PostWidget(
            post: postModel,
            onChekPressed: () {
              postController.chekPost(widget.post.id);
            },
            onSharePressed: () {
              postController.sharePost(widget.post.id);
            },
            onCommentPressed: () {
              // Navigate to post details
            },
          ),
          // Serendipity badge for discovery posts
          if (widget.isSerendipity)
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: _SerendipityBadge(),
            ),
        ],
      ),
    );
  }
}

/// Serendipity discovery badge with shimmer effect
class _SerendipityBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF8B5CF6), // Purple
            Color(0xFFEC4899), // Pink
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.explore,
            size: 14,
            color: Colors.white,
          ),
          SizedBox(width: 4),
          Text(
            'Discover',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
