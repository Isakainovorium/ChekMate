import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/providers/providers.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_chekmate/features/posts/presentation/providers/posts_providers.dart';
import 'package:flutter_chekmate/features/profile/domain/entities/voice_prompt_entity.dart';
import 'package:flutter_chekmate/features/profile/presentation/widgets/voice_prompt_player.dart';
import 'package:flutter_chekmate/features/profile/widgets/profile_video_player.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Profile Page - User profile with edit/share
/// Matches Figma design exactly
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key, this.userId});

  final String? userId; // If null, show current user's profile

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const List<Tab> _tabs = [
    Tab(icon: Icon(Icons.grid_on), text: 'Posts'),
    Tab(icon: Icon(Icons.favorite_border), text: 'Liked'),
    Tab(icon: Icon(Icons.bookmark_border), text: 'Saved'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final isOwnProfile =
        widget.userId == null || widget.userId == currentUserId;

    final userProvider = isOwnProfile
        ? currentUserProvider
        : userProfileProvider(widget.userId ?? '');

    final userAsync = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User not found'));
          }

          return CustomScrollView(
            slivers: [
              // App Bar with Cover Photo
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.surface,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Cover Photo
                      if (user.coverPhoto.isNotEmpty)
                        Image.network(
                          user.coverPhoto,
                          fit: BoxFit.cover,
                        )
                      else
                        Container(color: AppColors.surfaceVariant),

                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withAlpha(128),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  if (isOwnProfile)
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        context.go('/settings');
                      },
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {},
                    ),
                ],
              ),

              // Profile Content
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Profile Header
                    Transform.translate(
                      offset: const Offset(0, -40),
                      child: Column(
                        children: [
                          // Avatar
                          AppAvatar(
                            imageUrl:
                                user.avatar.isNotEmpty ? user.avatar : null,
                            name: user.username,
                            size: AppAvatarSize.extraLarge,
                            showBorder: true,
                            borderColor: AppColors.surface,
                            borderWidth: 4,
                          ),

                          const SizedBox(height: AppSpacing.sm),

                          // Name and Username
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                user.displayName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (user.isVerified) ...[
                                const SizedBox(width: AppSpacing.xs),
                                const Icon(
                                  Icons.verified,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ],
                            ],
                          ),

                          Text(
                            '@${user.username}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),

                          if (user.bio.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                              ),
                              child: Text(
                                user.bio,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],

                          const SizedBox(height: AppSpacing.md),

                          // Stats Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _StatItem(
                                label: 'Posts',
                                value: user.posts.toString(),
                              ),
                              _StatItem(
                                label: 'Followers',
                                value: user.followers.toString(),
                              ),
                              _StatItem(
                                label: 'Following',
                                value: user.following.toString(),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // Action Buttons
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            child: isOwnProfile
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: AppButton(
                                          variant: AppButtonVariant.outline,
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/edit-profile',
                                            );
                                          },
                                          child: const Text('Edit Profile'),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: AppButton(
                                          variant: AppButtonVariant.outline,
                                          onPressed: () {},
                                          child: const Text('Share Profile'),
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: AppButton(
                                          onPressed: () {
                                            final userController = ref
                                                .read(userControllerProvider);
                                            userController
                                                .toggleFollow(user.uid);
                                          },
                                          child: const Text('Follow'),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: AppButton(
                                          variant: AppButtonVariant.outline,
                                          onPressed: () {
                                            // Navigate to chat
                                          },
                                          child: const Text('Message'),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),

                          // Video Intro Section
                          if ((user as dynamic).videoIntroUrl != null &&
                              ((user as dynamic).videoIntroUrl as String)
                                  .isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xl),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Video Intro',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  ProfileVideoPlayer(
                                    videoUrl: (user as dynamic).videoIntroUrl
                                        as String,
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Voice Prompts Section
                          if ((user as dynamic).voicePrompts != null &&
                              ((user as dynamic).voicePrompts as List)
                                  .isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xl),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Voice Prompts',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  ...((user as dynamic).voicePrompts
                                          as List<VoicePromptEntity>)
                                      .map(
                                    (VoicePromptEntity prompt) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: AppSpacing.md,
                                      ),
                                      child: VoicePromptPlayer(
                                        voicePrompt: prompt,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Tabs
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.primary,
                      tabs: _tabs,
                    ),
                  ],
                ),
              ),

              // Tab Content
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPostsGrid(user.uid),
                    _buildLikedGrid(user.uid),
                    _buildSavedGrid(user.uid),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildPostsGrid(String userId) {
    final postsAsync = ref.watch(userPostsProvider(userId));

    return postsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'No posts yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(2),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index] as PostEntity;
            return InkWell(
              onTap: () {
                // View post
              },
              child: post.hasImages
                  ? Image.network(
                      post.images.first,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppColors.surfaceVariant,
                      child: const Center(
                        child: Icon(
                          Icons.article,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildLikedGrid(String userId) {
    return const Center(child: Text('Liked posts'));
  }

  Widget _buildSavedGrid(String userId) {
    return const Center(child: Text('Saved posts'));
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
  });
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
