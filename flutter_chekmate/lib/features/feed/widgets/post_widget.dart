import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/feed/models/post_model.dart';
import 'package:flutter_chekmate/features/feed/widgets/video_post_widget.dart';
import 'package:flutter_chekmate/features/posts/presentation/widgets/multi_photo_carousel.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// Main feed post widget - converted from Post.tsx
///
/// Features:
/// - User avatar and username
/// - Post content and image
/// - Like, comment, share, bookmark buttons
/// - Like animation
/// - Number formatting (1.2k, etc.)
class PostWidget extends StatefulWidget {
  const PostWidget({
    required this.post,
    super.key,
    this.onSharePressed,
    this.onCommentPressed,
    this.onMorePressed,
  });
  final Post post;
  final VoidCallback? onSharePressed;
  final VoidCallback? onCommentPressed;
  final VoidCallback? onMorePressed;

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget>
    with SingleTickerProviderStateMixin {
  late bool _isLiked;
  late int _likeCount;
  late bool _isBookmarked;
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likeCount = widget.post.likes;
    _isBookmarked = widget.post.isBookmarked;

    // Like animation setup with physics-based spring animation
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _likeAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.elasticOut, // Physics-based spring animation
      ),
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _handleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount = _isLiked ? _likeCount + 1 : _likeCount - 1;
    });

    // Animate like button
    if (_isLiked) {
      _likeAnimationController.forward().then((_) {
        _likeAnimationController.reverse();
      });
    }
  }

  void _handleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
  }

  String _formatNumber(int num) {
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}k';
    }
    return num.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          _buildPostHeader(),

          // Post Content
          if (widget.post.content.isNotEmpty) _buildPostContent(),

          // Post Video (if has video)
          if (widget.post.hasVideo) _buildPostVideo(),

          // Post Image (if has image and no video)
          if (widget.post.hasImage && !widget.post.hasVideo) _buildPostImage(),

          // Post Actions
          _buildPostActions(),
        ],
      ),
    );
  }

  Widget _buildPostHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Avatar
          AppAvatar(
            imageUrl: widget.post.userAvatar,
            name: widget.post.username,
          ),
          const SizedBox(width: AppSpacing.sm),

          // Username and timestamp
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.username,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.post.timestamp,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // More button
          AppButton(
            onPressed: widget.onMorePressed,
            variant: AppButtonVariant.text,
            size: AppButtonSize.sm,
            child: Icon(Icons.more_horiz, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
      ).copyWith(bottom: AppSpacing.sm),
      child: Text(
        widget.post.content,
        style: const TextStyle(
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildPostVideo() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
      ).copyWith(bottom: AppSpacing.sm),
      child: VideoPostWidget(
        videoUrl: widget.post.videoUrl!,
        thumbnailUrl: widget.post.thumbnailUrl,
      ),
    );
  }

  Widget _buildPostImage() {
    // Get all image URLs (supports both single and multiple images)
    final imageUrls = widget.post.allImageUrls;

    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    // Use MultiPhotoCarousel for multiple images or single image
    return Stack(
      children: [
        // Multi-photo carousel (square aspect ratio like Instagram)
        MultiPhotoCarousel(
          imageUrls: imageUrls,
        ),

        // Caption overlay (if exists)
        if (widget.post.caption != null && widget.post.caption!.isNotEmpty)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                widget.post.caption!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPostActions() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action buttons row
          Row(
            children: [
              // Like button
              ScaleTransition(
                scale: _likeAnimation,
                child: AppButton(
                  onPressed: _handleLike,
                  variant: AppButtonVariant.text,
                  size: AppButtonSize.sm,
                  child: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : Colors.grey.shade700,
                  ),
                ),
              ),
              Text(
                _formatNumber(_likeCount),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: AppSpacing.md),

              // Comment button
              AppButton(
                onPressed: widget.onCommentPressed,
                variant: AppButtonVariant.text,
                size: AppButtonSize.sm,
                child: Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                _formatNumber(widget.post.comments),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: AppSpacing.md),

              // Share button
              AppButton(
                onPressed: widget.onSharePressed,
                variant: AppButtonVariant.text,
                size: AppButtonSize.sm,
                child: Icon(
                  Icons.share_outlined,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                _formatNumber(widget.post.shares),
                style: const TextStyle(fontSize: 14),
              ),

              const Spacer(),

              // Bookmark button
              AppButton(
                onPressed: _handleBookmark,
                variant: AppButtonVariant.text,
                size: AppButtonSize.sm,
                child: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color:
                      _isBookmarked ? AppColors.primary : Colors.grey.shade700,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xs),

          // Liked by text
          Text(
            'Simone Gabrielle and ${_formatNumber(_likeCount - 1)} others liked this post',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),

          // Caption preview (if exists and not shown in image)
          if (widget.post.caption != null &&
              widget.post.caption!.isNotEmpty &&
              widget.post.imageUrl == null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  children: [
                    TextSpan(
                      text: '${widget.post.username} ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: widget.post.caption!.toLowerCase(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
