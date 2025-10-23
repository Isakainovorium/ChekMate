import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.elevation,
    this.borderRadius,
    this.enableShadow = true,
    super.key,
  });
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final bool enableShadow;

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: enableShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: card,
      );
    }

    return card;
  }
}

class PostCard extends StatelessWidget {
  const PostCard({
    required this.authorName,
    required this.authorAvatar,
    required this.timeAgo,
    required this.likes, required this.comments, required this.shares, this.content,
    this.imageUrl,
    this.isLiked = false,
    this.isBookmarked = false,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onBookmark,
    this.onAuthorTap,
    super.key,
  });
  final String authorName;
  final String authorAvatar;
  final String timeAgo;
  final String? content;
  final String? imageUrl;
  final int likes;
  final int comments;
  final int shares;
  final bool isLiked;
  final bool isBookmarked;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onBookmark;
  final VoidCallback? onAuthorTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author header
          InkWell(
            onTap: onAuthorTap,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(authorAvatar),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Content
          if (content != null) ...[
            const SizedBox(height: 12),
            Text(
              content!,
              style: const TextStyle(fontSize: 14),
            ),
          ],

          // Image
          if (imageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Stats
          Row(
            children: [
              Text(
                '$likes likes',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$comments comments',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$shares shares',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const Divider(height: 24),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ActionButton(
                icon: isLiked ? Icons.favorite : Icons.favorite_border,
                label: 'Like',
                color: isLiked ? AppColors.error : null,
                onTap: onLike,
              ),
              _ActionButton(
                icon: Icons.comment_outlined,
                label: 'Comment',
                onTap: onComment,
              ),
              _ActionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                onTap: onShare,
              ),
              _ActionButton(
                icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                label: 'Save',
                color: isBookmarked ? AppColors.primary : null,
                onTap: onBookmark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: color ?? AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color ?? AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// FlippablePostCard - Enhanced card with flip animation and reactions
/// Features:
/// - Flip animation to show description
/// - Vibration feedback on reactions
/// - Separate reaction bar below card
/// - Visual effects and shadows
class FlippablePostCard extends StatefulWidget {
  const FlippablePostCard({
    required this.authorName,
    required this.authorAvatar,
    required this.timeAgo,
    required this.likes, required this.comments, required this.shares, this.content,
    this.description,
    this.imageUrl,
    this.cheks = 0,
    this.isLiked = false,
    this.isChekked = false,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onChek,
    this.onAuthorTap,
    super.key,
  });
  final String authorName;
  final String authorAvatar;
  final String timeAgo;
  final String? content;
  final String? description;
  final String? imageUrl;
  final int likes;
  final int comments;
  final int shares;
  final int cheks;
  final bool isLiked;
  final bool isChekked;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onChek;
  final VoidCallback? onAuthorTap;

  @override
  State<FlippablePostCard> createState() => _FlippablePostCardState();
}

class _FlippablePostCardState extends State<FlippablePostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _showingBack = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_showingBack) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _showingBack = !_showingBack);
  }

  void _handleReaction(VoidCallback? callback) {
    // Haptic feedback for reactions
    HapticFeedback.lightImpact();
    callback?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main Card with Flip Animation
        AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            final angle = _flipAnimation.value * math.pi;
            final transform = Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle);

            return Transform(
              transform: transform,
              alignment: Alignment.center,
              child: angle >= math.pi / 2
                  ? Transform(
                      transform: Matrix4.identity()..rotateY(math.pi),
                      alignment: Alignment.center,
                      child: _buildBackSide(),
                    )
                  : _buildFrontSide(),
            );
          },
        ),

        const SizedBox(height: AppSpacing.sm),

        // Separate Reaction Bar
        _buildReactionBar(),
      ],
    );
  }

  Widget _buildFrontSide() {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          _buildAuthorHeader(),

          // Content
          if (widget.content != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.content!,
              style: const TextStyle(fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Image
          if (widget.imageUrl != null) ...[
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.sm),

          // Stats Row
          _buildStatsRow(),

          // Flip Button
          if (widget.description != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: TextButton.icon(
                onPressed: _toggleFlip,
                icon: const Icon(Icons.flip, size: 16),
                label: const Text('Read Description'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBackSide() {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      color: AppColors.primary.withAlpha(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          _buildAuthorHeader(),

          const SizedBox(height: AppSpacing.md),

          // Description Title
          const Row(
            children: [
              Icon(Icons.description, size: 20, color: AppColors.primary),
              SizedBox(width: AppSpacing.xs),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Description Content
          Text(
            widget.description ?? 'No description available.',
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),

          const SizedBox(height: AppSpacing.md),

          // Stats Row
          _buildStatsRow(),

          // Flip Back Button
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: TextButton.icon(
              onPressed: _toggleFlip,
              icon: const Icon(Icons.flip, size: 16),
              label: const Text('Back to Post'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorHeader() {
    return InkWell(
      onTap: widget.onAuthorTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(widget.authorAvatar),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.authorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  widget.timeAgo,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Text(
          '${widget.likes} likes',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          '${widget.comments} comments',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          '${widget.cheks} cheks',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildReactionBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ReactionButton(
            icon: widget.isLiked ? Icons.favorite : Icons.favorite_border,
            label: '${widget.likes}',
            color: widget.isLiked ? Colors.red : AppColors.textSecondary,
            onTap: () => _handleReaction(widget.onLike),
          ),
          _ReactionButton(
            icon: Icons.comment_outlined,
            label: '${widget.comments}',
            color: AppColors.textSecondary,
            onTap: () => _handleReaction(widget.onComment),
          ),
          _ReactionButton(
            icon: widget.isChekked
                ? Icons.check_circle
                : Icons.check_circle_outline,
            label: '${widget.cheks}',
            color:
                widget.isChekked ? AppColors.primary : AppColors.textSecondary,
            onTap: () => _handleReaction(widget.onChek),
          ),
          _ReactionButton(
            icon: Icons.share_outlined,
            label: '${widget.shares}',
            color: AppColors.textSecondary,
            onTap: () => _handleReaction(widget.onShare),
          ),
        ],
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  const _ReactionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
