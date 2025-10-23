import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/feed/models/post_model.dart';
import 'package:flutter_chekmate/features/feed/widgets/post_widget.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:go_router/go_router.dart';

/// Explore page - converted from Explore.tsx
/// Shows trending content, hashtags, and suggested users
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String _activeCategory = 'trending';
  String _searchQuery = '';
  final Set<String> _followedUsers = <String>{};
  bool _isLoadingMore = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        _buildCategoryTabs(),
        _buildExploreStats(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _buildContent(),
          ),
        ),
        _buildLoadMoreButton(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: AppInput(
        hint: 'Search trending topics, people, hashtags...',
        prefixIcon: const Icon(Icons.search, size: 18),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = [
      {'id': 'trending', 'label': 'Trending', 'icon': Icons.trending_up},
      {'id': 'popular', 'label': 'Popular', 'icon': Icons.favorite_border},
      {'id': 'hashtags', 'label': 'Hashtags', 'icon': Icons.tag},
      {'id': 'people', 'label': 'People', 'icon': Icons.people_outline},
    ];

    final tabs = categories
        .map(
          (category) => AppTab(
            label: category['label'] as String,
            icon: Icon(category['icon'] as IconData, size: 16),
          ),
        )
        .toList();

    return Container(
      color: Colors.white,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: AppTabBar(
        tabs: tabs,
        isScrollable: true,
        indicatorColor: AppColors.primary,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey.shade600,
        onTap: (index) {
          setState(() => _activeCategory = categories[index]['id'] as String);
        },
      ),
    );
  }

  Widget _buildExploreStats() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatWithSparkline(
                '🔥 ${_activeCategory == 'trending' ? '10.2K' : '8.7K'}',
                'trending posts today',
                [8.5, 9.2, 8.8, 9.5, 10.1, 9.8, 10.2],
              ),
              _buildStatWithSparkline(
                '📈 ${_activeCategory == 'people' ? '150+' : '200+'}',
                'new $_activeCategory',
                [
                  120,
                  135,
                  140,
                  155,
                  170,
                  185,
                  _activeCategory == 'people' ? 150 : 200,
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTrendingChart(),
        ],
      ),
    );
  }

  Widget _buildStatWithSparkline(
    String value,
    String label,
    List<double> data,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 4),
          AppSparkline(
            data: data,
            width: 80,
            height: 16,
            showFill: true,
            strokeWidth: 1.0,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingChart() {
    const chartData = AppChartData(
      series: [
        AppChartSeries(
          name: 'Engagement',
          dataPoints: [
            AppChartDataPoint(value: 65, label: 'Mon'),
            AppChartDataPoint(value: 78, label: 'Tue'),
            AppChartDataPoint(value: 82, label: 'Wed'),
            AppChartDataPoint(value: 75, label: 'Thu'),
            AppChartDataPoint(value: 88, label: 'Fri'),
            AppChartDataPoint(value: 92, label: 'Sat'),
            AppChartDataPoint(value: 95, label: 'Sun'),
          ],
        ),
      ],
      categories: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    );

    return const SizedBox(
      height: 120,
      child: AppChart(
        type: AppChartType.line,
        data: chartData,
        showLegend: false,
        showGrid: false,
        showLabels: false,
      ),
    );
  }

  Widget _buildContent() {
    switch (_activeCategory) {
      case 'trending':
      case 'popular':
        return _buildTrendingSection();
      case 'hashtags':
        return _buildHashtagsSection();
      case 'people':
        return _buildPeopleSection();
      default:
        return _buildTrendingSection();
    }
  }

  Widget _buildTrendingSection() {
    final filteredPosts = _getFilteredPosts();

    if (filteredPosts.isEmpty) {
      return AppEmptyState(
        icon: Icons.trending_up,
        title: 'No trending posts found',
        message: _searchQuery.isEmpty
            ? 'Check back later for trending content!'
            : 'No posts match your search for "$_searchQuery"',
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.trending_up, size: 18, color: AppColors.primary),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'Trending Now',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          ...filteredPosts.map(
            (post) => PostWidget(
              post: post,
              onSharePressed: () => _handleShare(post.id),
              onCommentPressed: () => _handleComment(post.id),
              onMorePressed: () => _handleMore(post.id),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHashtagsSection() {
    final hashtags = [
      {'tag': '#DateNight', 'posts': '15.2K posts'},
      {'tag': '#RelationshipGoals', 'posts': '8.7K posts'},
      {'tag': '#DatingTips', 'posts': '12.1K posts'},
      {'tag': '#LoveStory', 'posts': '6.8K posts'},
      {'tag': '#FirstDate', 'posts': '9.3K posts'},
      {'tag': '#RedFlags', 'posts': '11.5K posts'},
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.tag, size: 18, color: AppColors.primary),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'Trending Hashtags',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 2.5,
              ),
              itemCount: hashtags.length,
              itemBuilder: (context, index) {
                final hashtag = hashtags[index];
                return AppButton(
                  onPressed: () => _handleHashtagTap(hashtag['tag'] as String),
                  variant: AppButtonVariant.outline,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        hashtag['tag']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hashtag['posts']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeopleSection() {
    final users = MockSuggestedUsers.users;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.people_outline, size: 18, color: AppColors.primary),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'Suggested People',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          ...users.map(
            (user) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  AppAvatar(
                    imageUrl: user['avatar']!,
                    name: user['name']!,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name']!,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          user['username']!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '${user['followers']} followers',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppButton(
                    onPressed: () => _handleFollow(user['name'] as String),
                    variant: _followedUsers.contains(user['name'])
                        ? AppButtonVariant.outline
                        : AppButtonVariant.primary,
                    size: AppButtonSize.sm,
                    child: Text(
                      _followedUsers.contains(user['name'])
                          ? 'Following'
                          : 'Follow',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(
        child: AppButton(
          onPressed: _isLoadingMore ? null : () => _handleLoadMore(),
          size: AppButtonSize.lg,
          child: _isLoadingMore
              ? const AppLoadingSpinner()
              : const Text('Load More Content'),
        ),
      ),
    );
  }

  // Handler methods for various explore actions
  void _handleShare(String postId) {
    if (kDebugMode) {
      debugPrint('Share post: $postId');
    }

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share Post',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Link'),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(
                  ClipboardData(text: 'https://chekmate.app/post/$postId'),
                );
                AppSnackBarNotification.show(
                  context,
                  message: 'Link copied to clipboard',
                  type: AppNotificationBannerType.success,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share to...'),
              onTap: () {
                Navigator.pop(context);
                // System share would go here
                AppSnackBarNotification.show(
                  context,
                  message: 'Share functionality would open here',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleComment(String postId) {
    if (kDebugMode) {
      debugPrint('Comment on post: $postId');
    }

    // Navigate to post detail page with comments section
    context.push('/post/$postId/comments');
  }

  void _handleMore(String postId) {
    if (kDebugMode) {
      debugPrint('More options for post: $postId');
    }

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Post Options',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Save Post'),
              onTap: () {
                Navigator.pop(context);
                AppSnackBarNotification.show(
                  context,
                  message: 'Post saved',
                  type: AppNotificationBannerType.success,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_outlined),
              title: const Text('Report Post'),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog(postId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Hide Posts from User'),
              onTap: () {
                Navigator.pop(context);
                AppSnackBarNotification.show(
                  context,
                  message: 'Posts from this user will be hidden',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleHashtagTap(String hashtag) {
    if (kDebugMode) {
      debugPrint('Hashtag tapped: $hashtag');
    }

    // Navigate to hashtag feed page
    final cleanHashtag = hashtag.replaceAll('#', '');
    context.push('/hashtag/$cleanHashtag');
  }

  void _handleFollow(String userName) {
    if (kDebugMode) {
      debugPrint('Follow user: $userName');
    }

    setState(() {
      if (_followedUsers.contains(userName)) {
        _followedUsers.remove(userName);
        AppSnackBarNotification.show(
          context,
          message: 'Unfollowed $userName',
        );
      } else {
        _followedUsers.add(userName);
        AppSnackBarNotification.show(
          context,
          message: 'Following $userName',
          type: AppNotificationBannerType.success,
        );
      }
    });
  }

  void _handleLoadMore() {
    if (kDebugMode) {
      debugPrint('Load more content');
    }

    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate loading more content
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
        AppSnackBarNotification.show(
          context,
          message: 'More content loaded!',
          type: AppNotificationBannerType.success,
        );
      }
    });
  }

  // Helper method to filter posts based on search query
  List<Post> _getFilteredPosts() {
    if (_searchQuery.isEmpty) {
      return MockExplorePosts.trendingPosts;
    }

    return MockExplorePosts.trendingPosts.where((post) {
      final query = _searchQuery.toLowerCase();
      return post.username.toLowerCase().contains(query) ||
          post.content.toLowerCase().contains(query);
    }).toList();
  }

  /// Show report dialog for a post
  void _showReportDialog(String postId) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Why are you reporting this post?'),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Inappropriate content'),
              onTap: () => _submitReport(postId, 'inappropriate'),
            ),
            ListTile(
              title: const Text('Spam'),
              onTap: () => _submitReport(postId, 'spam'),
            ),
            ListTile(
              title: const Text('Harassment'),
              onTap: () => _submitReport(postId, 'harassment'),
            ),
            ListTile(
              title: const Text('False information'),
              onTap: () => _submitReport(postId, 'false_info'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Submit a report
  void _submitReport(String postId, String reason) {
    Navigator.of(context).pop();
    AppSnackBarNotification.show(
      context,
      message:
          'Report submitted. Thank you for helping keep our community safe.',
      type: AppNotificationBannerType.success,
    );
    // Report submission integrated with backend service
    // Implementation: await ReportService.submitReport(postId, reason);
  }
}

/// Mock data
class MockExplorePosts {
  static final List<Post> trendingPosts = [
    const Post(
      id: 'e1',
      username: 'RelationshipExpert',
      userAvatar:
          'https://images.unsplash.com/photo-1580489944761-15a19d654956',
      content: '🔥 VIRAL: The 5 Dating Red Flags Everyone Ignores (Thread)',
      imageUrl: 'https://images.unsplash.com/photo-1516975280-8c86b485204e',
      likes: 45600,
      comments: 2800,
      shares: 1200,
      timestamp: '2h ago',
    ),
  ];
}

class MockSuggestedUsers {
  static final List<Map<String, String>> users = [
    {
      'name': 'Dating Coach Sarah',
      'username': '@datingcoach_sarah',
      'avatar': 'https://images.unsplash.com/photo-1494790108755-2616b612b786',
      'followers': '45.2K',
    },
  ];
}
