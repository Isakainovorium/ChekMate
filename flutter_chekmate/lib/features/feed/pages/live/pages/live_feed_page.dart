import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/widgets/app_avatar.dart';
import 'package:flutter_chekmate/shared/widgets/app_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Live Feed Page - Live streams and go live button
/// Matches Figma design exactly
class LiveFeedPage extends ConsumerWidget {
  const LiveFeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.live_tv, color: Colors.red, size: 28),
            SizedBox(width: AppSpacing.xs),
            Text(
              'Live',
              style: TextStyle(
                color: AppColors.navyBlue,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Go Live Button
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            color: AppColors.surface,
            child: AppButton(
              text: 'Go Live',
              onPressed: () {
                _showGoLiveDialog(context);
              },
              size: ButtonSize.large,
              isFullWidth: true,
            ),
          ),

          const Divider(height: 1),

          // Live Streams Grid
          Expanded(
            child: _buildLiveStreamsGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStreamsGrid() {
    // Mock data for demonstration
    final liveStreams = List.generate(
      10,
      (index) => {
        'id': 'stream_$index',
        'userName': 'User ${index + 1}',
        'userAvatar': 'https://i.pravatar.cc/150?img=${index + 1}',
        'thumbnail': 'https://picsum.photos/400/300?random=$index',
        'title': 'Live Stream ${index + 1}',
        'viewers': (index + 1) * 123,
      },
    );

    if (liveStreams.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.live_tv_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'No live streams',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Be the first to go live!',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.75,
      ),
      itemCount: liveStreams.length,
      itemBuilder: (context, index) {
        final stream = liveStreams[index];
        return _LiveStreamCard(
          userName: stream['userName'] as String,
          userAvatar: stream['userAvatar'] as String,
          thumbnail: stream['thumbnail'] as String,
          title: stream['title'] as String,
          viewers: stream['viewers'] as int,
          onTap: () {
            // Navigate to live stream
          },
        );
      },
    );
  }

  void _showGoLiveDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Go Live'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Stream Title',
                hintText: 'Enter a title for your stream',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'What will you be streaming?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          AppButton(
            text: 'Start Stream',
            onPressed: () {
              Navigator.pop(context);
              // Start live stream
            },
          ),
        ],
      ),
    );
  }
}

class _LiveStreamCard extends StatelessWidget {
  const _LiveStreamCard({
    required this.userName,
    required this.userAvatar,
    required this.thumbnail,
    required this.title,
    required this.viewers,
    this.onTap,
  });
  final String userName;
  final String userAvatar;
  final String thumbnail;
  final String title;
  final int viewers;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with LIVE badge
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      thumbnail,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // LIVE badge
                  const Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: AppBadge(
                      text: 'LIVE',
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      icon: Icons.circle,
                    ),
                  ),

                  // Viewers count
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(153),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.visibility,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatViewers(viewers),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: NetworkImage(userAvatar),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
    );
  }

  String _formatViewers(int viewers) {
    if (viewers >= 1000000) {
      return '${(viewers / 1000000).toStringAsFixed(1)}M';
    } else if (viewers >= 1000) {
      return '${(viewers / 1000).toStringAsFixed(1)}K';
    }
    return viewers.toString();
  }
}
