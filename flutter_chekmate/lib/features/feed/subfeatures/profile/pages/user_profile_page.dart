import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/feed/subfeatures/profile/widgets/profile_header_widget.dart';
import 'package:flutter_chekmate/features/feed/subfeatures/profile/widgets/profile_stats_widget.dart';
import 'package:flutter_chekmate/pages/profile/my_profile_page.dart'; // For ProfileVideo model
import 'package:flutter_chekmate/shared/ui/index.dart';

/// User Profile page - converted from UserProfile.tsx
/// Shows other users' profiles with follow/message buttons
class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _isFollowing = false;
  int _followerCount = 55000;

  void _handleFollowClick() {
    setState(() {
      _isFollowing = !_isFollowing;
      _followerCount = _isFollowing ? _followerCount + 1 : _followerCount - 1;
    });
  }

  String _formatFollowerCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ProfileHeaderWidget(
              name: 'Simone Gabrielle',
              username: '@thatgurlmone',
              bio: 'Hello, I\'m Simone Gabrielle Welcome to my profile!',
              avatar:
                  'https://images.unsplash.com/photo-1494790108755-2616b612b786',
              isFollowing: _isFollowing,
              onFollowClick: _handleFollowClick,
              onMessageClick: () {
                if (kDebugMode) {
                  debugPrint('Open messaging');
                }
              },
            ),
          ),
          SliverToBoxAdapter(
            child: ProfileStatsWidget(
              posts: 200,
              followers: _formatFollowerCount(_followerCount),
              subscribers: '5K',
              likes: '1M',
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: _buildVideoGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoGrid() {
    final videos = MockProfileVideos.videos;

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.75,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final video = videos[index];
          return _buildVideoCard(video);
        },
        childCount: videos.length,
      ),
    );
  }

  Widget _buildVideoCard(ProfileVideo video) {
    return GestureDetector(
      onTap: () {
        if (kDebugMode) {
          debugPrint('Play video: ${video.id}');
        }
      },
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(video.thumbnail),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
              // Video info
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.visibility,
                          size: 12,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          video.views,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
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
      ),
    );
  }
}
