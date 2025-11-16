import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _PostWidgetState extends State<PostWidget> with TickerProviderStateMixin {
  late bool _isLiked;
  late int _likeCount;
  late bool _isBookmarked;
  late AnimationController _likeAnimationController;
  late AnimationController _heartBurstController;
  late Animation<double> _likeScaleAnimation;
  late Animation<double> _likeRotationAnimation;
  late Animation<double> _heartBurstAnimation;
  late Animation<double> _heartBurstOpacity;
  bool _showHeartBurst = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likeCount = widget.post.likes;
    _isBookmarked = widget.post.isBookmarked;

    // Like button animation - scale + rotation
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _likeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.4)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_likeAnimationController);

    _likeRotationAnimation = Tween<double>(begin: 0.0, end: 0.2).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Heart burst animation (big heart that fades out)
    _heartBurstController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _heartBurstAnimation = Tween<double>(begin: 0.5, end: 2.0).animate(
      CurvedAnimation(
        parent: _heartBurstController,
        curve: Curves.easeOut,
      ),
    );

    _heartBurstOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _heartBurstController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _heartBurstController.dispose();
    super.dispose();
  }

  void _handleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount = _isLiked ? _likeCount + 1 : _likeCount - 1;
    });

    // Animate like button
    if (_isLiked) {
      // Trigger haptic feedback (web vibration API)
      _triggerHapticFeedback();

      // Button animation
      _likeAnimationController.forward(from: 0);

      // Heart burst animation
      setState(() => _showHeartBurst = true);
      _heartBurstController.forward(from: 0).then((_) {
        setState(() => _showHeartBurst = false);
      });
    }
  }

  void _triggerHapticFeedback() {
    // Use Flutter's HapticFeedback for mobile platforms
    // On web, this will silently fail (which is fine)
    try {
      HapticFeedback.lightImpact();
    } on MissingPluginException catch (e) {
      // Silently fail on unsupported platforms (web)
      if (kDebugMode) {
        debugPrint('Haptic feedback not supported: $e');
      }
    }
  }

  void _handleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    // Haptic feedback for bookmark
    if (_isBookmarked) {
      _triggerHapticFeedback();
    }
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
    // Wrap entire post in AppContextMenu for right-click actions
    return AppContextMenu(
      menuItems: [
        AppContextMenuItem(
          label: 'Share Post',
          icon: Icons.share,
          onTap: widget.onSharePressed,
        ),
        AppContextMenuItem(
          label: _isBookmarked ? 'Remove Bookmark' : 'Bookmark Post',
          icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          onTap: _handleBookmark,
        ),
        const AppContextMenuItem.divider(),
        AppContextMenuItem(
          label: 'Copy Link',
          icon: Icons.link,
          onTap: () {
            Clipboard.setData(ClipboardData(
                text: 'https://chekmate.app/post/${widget.post.id}'));
          },
        ),
        AppContextMenuItem(
          label: 'Report Post',
          icon: Icons.flag,
          onTap: () {
            // Show report dialog
          },
        ),
      ],
      child: AppCard(
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
            if (widget.post.hasImage && !widget.post.hasVideo)
              _buildPostImage(),

            // Post Actions
            _buildPostActions(),
          ],
        ),
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
                  _formatTimestamp(widget.post.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // More button - replaced with AppDropdownMenu
          AppDropdownButton<String>(
            items: [
              const AppDropdownMenuItem<String>(
                value: 'share',
                label: 'Share Post',
                leading: Icon(Icons.share, size: 18),
              ),
              AppDropdownMenuItem<String>(
                value: 'bookmark',
                label: _isBookmarked ? 'Remove Bookmark' : 'Bookmark Post',
                leading: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  size: 18,
                ),
              ),
              const AppDropdownMenuItem<String>(
                value: 'copy',
                label: 'Copy Link',
                leading: Icon(Icons.link, size: 18),
              ),
              const AppDropdownMenuItem<String>(
                value: 'report',
                label: 'Report Post',
                leading: Icon(Icons.flag, size: 18),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'share':
                  widget.onSharePressed?.call();
                  break;
                case 'bookmark':
                  _handleBookmark();
                  break;
                case 'copy':
                  Clipboard.setData(ClipboardData(
                    text: 'https://chekmate.app/post/${widget.post.id}',
                  ));
                  break;
                case 'report':
                  // Show report dialog
                  break;
              }
            },
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
        if (widget.post.caption.isNotEmpty)
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
                widget.post.caption,
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
              // Like button with enhanced animation
              Stack(
                alignment: Alignment.center,
                children: [
                  // Heart burst effect (big heart that fades out)
                  if (_showHeartBurst)
                    ScaleTransition(
                      scale: _heartBurstAnimation,
                      child: FadeTransition(
                        opacity: _heartBurstOpacity,
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ),

                  // Main like button with scale + rotation
                  AnimatedBuilder(
                    animation: _likeAnimationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _likeScaleAnimation.value,
                        child: Transform.rotate(
                          angle: _likeRotationAnimation.value,
                          child: AppButton(
                            onPressed: _handleLike,
                            variant: AppButtonVariant.text,
                            size: AppButtonSize.sm,
                            child: Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_border,
                              color:
                                  _isLiked ? Colors.red : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
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
          if (widget.post.caption.isNotEmpty &&
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
                      text: widget.post.caption.toLowerCase(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Format timestamp to relative time (e.g., "2h ago", "3d ago")
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
