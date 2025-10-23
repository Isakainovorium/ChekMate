import 'package:flutter/material.dart';
import 'package:flutter_chekmate/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_chekmate/shared/services/share_service.dart';

/// SharePostButton - Presentation Layer Widget
///
/// A button that allows users to share a post using the native share sheet.
/// Supports sharing text, images, and videos.
///
/// Features:
/// - Share post content with text
/// - Share post images
/// - Share post URL
/// - Track share count
/// - Show share result feedback
///
/// Clean Architecture: Presentation Layer
class SharePostButton extends StatefulWidget {
  const SharePostButton({
    required this.post,
    required this.onShare,
    super.key,
    this.iconSize = 20,
    this.showCount = true,
    this.color,
  });

  final PostEntity post;
  final VoidCallback onShare;
  final double iconSize;
  final bool showCount;
  final Color? color;

  @override
  State<SharePostButton> createState() => _SharePostButtonState();
}

class _SharePostButtonState extends State<SharePostButton> {
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.iconTheme.color ?? Colors.grey;

    return InkWell(
      onTap: _isSharing ? null : _handleShare,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isSharing)
              SizedBox(
                width: widget.iconSize,
                height: widget.iconSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            else
              Icon(
                Icons.share_outlined,
                size: widget.iconSize,
                color: color,
              ),
            if (widget.showCount && widget.post.shares > 0) ...[
              const SizedBox(width: 4),
              Text(
                _formatCount(widget.post.shares),
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleShare() async {
    setState(() {
      _isSharing = true;
    });

    try {
      // Build share content
      final shareText = _buildShareText();
      final shareUrl = _buildShareUrl();

      // Get share position for iPad
      final box = context.findRenderObject() as RenderBox?;
      final sharePositionOrigin =
          box != null ? box.localToGlobal(Offset.zero) & box.size : null;

      // Share the post
      await ShareService.shareText(
        text: '$shareText\n\n$shareUrl',
        subject: 'Check out this post on ChekMate!',
        sharePositionOrigin: sharePositionOrigin,
      );

      // Increment share count
      widget.onShare();
    } on Exception catch (e) {
      // Show error feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share post: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  String _buildShareText() {
    final buffer = StringBuffer();

    // Add username
    buffer.write('Check out @${widget.post.username}\'s post');

    // Add verified badge if verified
    if (widget.post.isVerified) {
      buffer.write(' ✓');
    }

    buffer.write('!\n\n');

    // Add content (truncate if too long)
    if (widget.post.content.isNotEmpty) {
      final content = widget.post.content.length > 200
          ? '${widget.post.content.substring(0, 200)}...'
          : widget.post.content;
      buffer.write(content);
      buffer.write('\n\n');
    }

    // Add stats
    buffer.write('❤️ ${widget.post.likes} likes');
    if (widget.post.comments > 0) {
      buffer.write(' • 💬 ${widget.post.comments} comments');
    }

    return buffer.toString();
  }

  String _buildShareUrl() {
    // Use ChekMate deep link URL scheme for sharing posts
    // This URL will open the app if installed, or redirect to web version
    return 'https://chekmate.app/post/${widget.post.id}';
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }
}

/// SharePostIconButton - Simplified Icon-Only Version
///
/// A simpler version of SharePostButton that only shows an icon.
class SharePostIconButton extends StatelessWidget {
  const SharePostIconButton({
    required this.post,
    required this.onShare,
    super.key,
    this.iconSize = 24,
    this.color,
  });

  final PostEntity post;
  final VoidCallback onShare;
  final double iconSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SharePostButton(
      post: post,
      onShare: onShare,
      iconSize: iconSize,
      showCount: false,
      color: color,
    );
  }
}
