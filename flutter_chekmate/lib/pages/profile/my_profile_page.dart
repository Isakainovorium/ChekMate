import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/router/route_constants.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/feed/subfeatures/profile/widgets/profile_stats_widget.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:go_router/go_router.dart';

/// My Profile page - converted from MyProfile.tsx
/// Shows current user's profile with edit capabilities
class MyProfilePage extends StatefulWidget {
  const MyProfilePage({
    required this.userAvatar,
    super.key,
    this.username = 'ChekMate_User',
    this.bio =
        'Living my best life and looking for someone to share adventures with! 🌟',
  });
  final String userAvatar;
  final String username;
  final String bio;

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  late String _currentUsername;
  late String _currentBio;

  @override
  void initState() {
    super.initState();
    _currentUsername = widget.username;
    _currentBio = widget.bio;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // Parallax Cover Photo with SliverAppBar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover Photo with parallax effect
                  Image.network(
                    'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=800',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Gradient overlay for better text visibility
                  Container(
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
                ],
              ),
            ),
            actions: [
              AppButton(
                onPressed: () => debugPrint('Notifications'),
                variant: AppButtonVariant.text,
                size: AppButtonSize.sm,
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              AppButton(
                onPressed: () => debugPrint('Share'),
                variant: AppButtonVariant.text,
                size: AppButtonSize.sm,
                child: const Icon(
                  Icons.share_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(child: _buildHeader()),
          const SliverToBoxAdapter(
            child: ProfileStatsWidget(
              posts: 89,
              followers: 1200,
              following: 567,
            ),
          ),
          SliverToBoxAdapter(child: _buildEditProfileButton()),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: _buildVideoGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Transform.translate(
      offset: const Offset(0, -40),
      child: AppCard(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            // Profile info and avatar
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Simone Gabrielle',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@$_currentUsername',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _currentBio,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                // Profile picture with gradient border
                GestureDetector(
                  onTap: () => debugPrint('Change profile picture'),
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFFEBD59), Color(0xFFDF912F)],
                      ),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: AppAvatar(
                        imageUrl: widget.userAvatar,
                        name: 'Simone Gabrielle',
                        size: AppAvatarSize.extraLarge,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditProfileButton() {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              onPressed: () => debugPrint('Edit profile'),
              variant: AppButtonVariant.outline,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Edit Profile'),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppButton(
            onPressed: () => _showSettingsMenu(context),
            variant: AppButtonVariant.outline,
            size: AppButtonSize.sm,
            child: const Icon(Icons.settings_outlined, size: 18),
          ),
        ],
      ),
    );
  }

  void _showSettingsMenu(BuildContext context) {
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
            // Interests Management
            ListTile(
              leading: const Icon(Icons.favorite, color: AppColors.primary),
              title: const Text('Manage Interests'),
              subtitle: const Text(
                'Update topics to discover relevant experience stories',
              ),
              onTap: () {
                Navigator.pop(context);
                context.goNamed(RouteNames.interestsManagement);
              },
            ),
            const Divider(),
            // Location Settings
            ListTile(
              leading: const Icon(Icons.location_on, color: AppColors.primary),
              title: const Text('Location Settings'),
              subtitle: const Text(
                'Discover local experience stories from your community',
              ),
              onTap: () {
                Navigator.pop(context);
                context.goNamed(RouteNames.locationSettings);
              },
            ),
            const Divider(),
            // Account Settings
            ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: const Text('Account Settings'),
              subtitle: const Text('Privacy, security, and preferences'),
              onTap: () {
                Navigator.pop(context);
                debugPrint('Account Settings');
              },
            ),
            const Divider(),
            // Help & Support
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support'),
              subtitle: const Text('FAQs and contact support'),
              onTap: () {
                Navigator.pop(context);
                debugPrint('Help & Support');
              },
            ),
          ],
        ),
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
      onTap: () => debugPrint('Play video: ${video.id}'),
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
              // Checkmark if checked
              if (video.isChecked)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mock data
class ProfileVideo {
  ProfileVideo({
    required this.id,
    required this.thumbnail,
    required this.title,
    required this.views,
    required this.isChecked,
  });
  final String id;
  final String thumbnail;
  final String title;
  final String views;
  final bool isChecked;
}

class MockProfileVideos {
  static final List<ProfileVideo> videos = [
    ProfileVideo(
      id: '1',
      thumbnail: 'https://images.unsplash.com/photo-1552011571-db69d3a55457',
      title: 'Why Doja Dior Scammed: A thread',
      views: '1.1M',
      isChecked: true,
    ),
    ProfileVideo(
      id: '2',
      thumbnail: 'https://images.unsplash.com/photo-1758522482313-18d6c563dc5a',
      title: 'Part One- Who TF Did I Marry??',
      views: '3.1M',
      isChecked: true,
    ),
    ProfileVideo(
      id: '3',
      thumbnail: 'https://images.unsplash.com/photo-1758611975583-fddf609226a0',
      title: 'Came home early and caught my girl cheating',
      views: '2.1M',
      isChecked: false,
    ),
    ProfileVideo(
      id: '4',
      thumbnail: 'https://images.unsplash.com/photo-1669627961229-987550948857',
      title: 'Wife Caught Her Husband On A 300 Dollar Date',
      views: '4.2M',
      isChecked: false,
    ),
  ];
}
