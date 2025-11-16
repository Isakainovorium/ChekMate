import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chekmate/core/navigation/nav_state.dart';
import 'package:flutter_chekmate/core/providers/gamification_provider.dart';
import 'package:flutter_chekmate/core/providers/navigation_providers.dart';
import 'package:flutter_chekmate/core/services/keyboard_shortcuts_service.dart';
import 'package:flutter_chekmate/core/theme/app_breakpoints.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/feed/data/mock_data.dart';
import 'package:flutter_chekmate/features/feed/models/post_model.dart';
import 'package:flutter_chekmate/features/feed/pages/messaging/pages/navigation/widgets/header_widget.dart';
import 'package:flutter_chekmate/features/feed/pages/messaging/pages/navigation/widgets/nav_tabs_widget.dart';
import 'package:flutter_chekmate/features/feed/widgets/post_widget.dart';
import 'package:flutter_chekmate/features/stories/models/story_model.dart';
import 'package:flutter_chekmate/features/stories/widgets/stories_widget.dart';
import 'package:flutter_chekmate/pages/explore/explore_page.dart';
import 'package:flutter_chekmate/pages/live/live_page.dart';
import 'package:flutter_chekmate/shared/ui/animations/widget_animations.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Main home page - converted from App.tsx
///
/// Features:
/// - Header with search
/// - Navigation tabs
/// - Stories row
/// - Feed with posts
/// - Bottom navigation
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();
  late PageController _pageController;
  final List<Post> _posts = [];
  final List<StoryUser> _stories = MockStories.stories;

  // Infinite scroll state
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  static const int _postsPerPage = 10;

  // Tab navigation
  final List<String> _tabs = [
    'For you',
    'Following',
    'Explore',
    'Live',
    'Rate Date',
    'Subscribe',
  ];
  // Tab index tracking (currently unused but reserved for future tab state management)
  // ignore: unused_field
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _pageController = PageController();
    _loadInitialPosts();
    _updateLoginStreak();
  }

  Future<void> _updateLoginStreak() async {
    // Update login streak when user opens the app
    final gamificationService = ref.read(gamificationServiceProvider);
    await gamificationService.updateLoginStreak();

    // Refresh the streak provider
    ref.invalidate(loginStreakProvider);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Load more when 80% scrolled
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoadingMore && _hasMore) {
        _loadMorePosts();
      }
    }
  }

  Future<void> _loadInitialPosts() async {
    setState(() {
      _posts.clear();
      _posts.addAll(MockPosts.posts.take(_postsPerPage).toList());
      _currentPage = 1;
      _hasMore = MockPosts.posts.length > _postsPerPage;
    });
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    // Simulate API call delay
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final startIndex = _currentPage * _postsPerPage;
    final endIndex = startIndex + _postsPerPage;
    final newPosts =
        MockPosts.posts.skip(startIndex).take(_postsPerPage).toList();

    if (mounted) {
      setState(() {
        _posts.addAll(newPosts);
        _currentPage++;
        _hasMore = endIndex < MockPosts.posts.length;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    // Simulate API call
    await Future<void>.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _posts.clear();
        _posts.addAll(MockPosts.posts.take(_postsPerPage).toList());
        _currentPage = 1;
        _hasMore = MockPosts.posts.length > _postsPerPage;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feed refreshed!'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  void _handleTabChange(String tab) {
    if (tab == 'Rate Date') {
      // Navigate to full-screen Rate Date route (bottom nav hidden there)
      context.go('/rate-date');
      return;
    }

    final index = _tabs.indexOf(tab);
    if (index != -1) {
      setState(() => _currentTabIndex = index);

      // Smooth page transition with custom curve
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic, // Smoother than easeInOut
      );

      // Haptic feedback on tab change
      try {
        HapticFeedback.selectionClick();
      } on MissingPluginException {
        // Silently fail on web
      }
    }
    ref.read(navStateProvider.notifier).setActiveTab(tab);
  }

  void _handlePageChange(int index) {
    setState(() => _currentTabIndex = index);
    ref.read(navStateProvider.notifier).setActiveTab(_tabs[index]);
  }

  // Bottom navigation is provided by the MainNavigation shell.

  void _handleStoryTap(StoryUser storyUser) {
    _openStoryViewer(storyUser);
  }

  void _handleSearch(String query) {
    // Navigate to search page with query
    context.push('/search?q=${Uri.encodeComponent(query)}');
    if (kDebugMode) {
      debugPrint('Search query: $query');
    }
  }

  Future<void> _openStoryViewer(StoryUser storyUser) async {
    // Hide bottom nav while viewing stories
    ref.read(navStateProvider.notifier).setViewingStories(true);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(),
          child: SafeArea(
            child: Center(
              child: Text(
                'Story Viewer for ${storyUser.username}\n(Tap anywhere to close)',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        );
      },
    );
    // Restore bottom nav when closed
    if (mounted) {
      ref.read(navStateProvider.notifier).setViewingStories(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = ref.watch(navStateProvider);
    final topNavTab = ref.watch(topNavTabProvider);

    // Automatically switch tabs when top navigation changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      String targetTab;
      switch (topNavTab) {
        case TopNavTab.forYou:
          targetTab = 'For you';
          break;
        case TopNavTab.following:
          targetTab = 'Following';
          break;
        case TopNavTab.explore:
          targetTab = 'Explore';
          break;
        case TopNavTab.live:
          targetTab = 'Live';
          break;
        case TopNavTab.subscribe:
          targetTab = 'Subscribe';
          break;
      }

      if (nav.activeTab != targetTab) {
        _handleTabChange(targetTab);
      }
    });
    return KeyboardShortcuts(
      shortcuts: {
        ChekMateShortcuts.refresh: () => _handleRefresh(),
        ChekMateShortcuts.help: _showKeyboardHelp,
        ChekMateShortcuts.scrollDown: _scrollDown,
        ChekMateShortcuts.scrollUp: _scrollUp,
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Column(
          children: [
            // Header
            HeaderWidget(
              scrollController: _scrollController,
              onSearch: _handleSearch,
            ),

            // Navigation Tabs
            NavTabsWidget(
              activeTab: nav.activeTab,
              onTabChanged: _handleTabChange,
            ),

            // Gamification Stats (Streak & Points)
            const GamificationStatsWidget(),

            // Swipeable Content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _handlePageChange,
                physics: const BouncingScrollPhysics(), // iOS-style bounce
                children: [
                  _buildForYouFeed(),
                  _buildFollowingFeed(),
                  _buildExplorePage(),
                  _buildLivePage(),
                  _buildRateDatePage(),
                  _buildSubscribePage(),
                ],
              ),
            ),
          ],
        ),
        // Bottom navigation handled by MainNavigation shell
      ),
    );
  }

  void _showKeyboardHelp() {
    showDialog<void>(
      context: context,
      builder: (context) => const KeyboardShortcutsHelp(),
    );
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.offset + 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollUp() {
    _scrollController.animateTo(
      _scrollController.offset - 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Widget _buildForYouFeed() {
    return ResponsiveLayout(
      child: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.primary,
        child: ListView.builder(
          controller: _scrollController,
          physics:
              const AlwaysScrollableScrollPhysics(), // Required for RefreshIndicator
          itemCount: _hasMore
              ? _posts.length + 2
              : _posts.length + 1, // +1 for stories, +1 for loading
          itemBuilder: (context, index) {
            if (index == 0) {
              // Stories row with slide-in animation
              return StoriesWidget(
                stories: _stories,
                onStoryTap: _handleStoryTap,
              ).fadeInSlideRight(
                duration: const Duration(milliseconds: 600),
              );
            }

            // Loading indicator at end
            if (index == _posts.length + 1) {
              return _buildLoadingIndicator();
            }

            // Posts with staggered fade-in animation
            final post = _posts[index - 1];
            return PostWidget(
              key: ValueKey(post.id),
              post: post,
              onSharePressed: () {
                _showShareModal(post);
              },
              onCommentPressed: () {
                _showComments(post.id);
              },
              onMorePressed: () {
                _showPostOptions(post);
              },
            ).staggeredFadeIn(
              index: index - 1,
              staggerDelay: const Duration(milliseconds: 80),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: PostSkeleton(),
    );
  }

  Widget _buildFollowingFeed() {
    return ResponsiveLayout(
      child: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.primary,
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _hasMore ? _posts.length + 2 : _posts.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return StoriesWidget(
                stories: _stories,
                onStoryTap: _handleStoryTap,
              ).fadeInSlideRight(
                duration: const Duration(milliseconds: 600),
              );
            }

            // Loading indicator at end
            if (index == _posts.length + 1) {
              return _buildLoadingIndicator();
            }

            final post = _posts[index - 1];
            return PostWidget(
              key: ValueKey(post.id),
              post: post,
              onSharePressed: () => _showShareModal(post),
              onCommentPressed: () => _showComments(post.id),
              onMorePressed: () => _showPostOptions(post),
            ).staggeredFadeIn(
              index: index - 1,
              staggerDelay: const Duration(milliseconds: 80),
            );
          },
        ),
      ),
    );
  }

  Widget _buildExplorePage() {
    // Use the actual ExplorePage widget without AppBar (HomePage has its own header)
    return const ExplorePage(showAppBar: false);
  }

  Widget _buildLivePage() {
    // Use a default avatar - LivePage doesn't require user data to function
    const userAvatar = 'https://via.placeholder.com/150';

    // Use the actual LivePage widget without AppBar (HomePage has its own header)
    return const LivePage(userAvatar: userAvatar, showAppBar: false);
  }

  Widget _buildRateDatePage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Rate Your Date',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share your dating experiences',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribePage() {
    // SubscribePage has its own Scaffold, so we need to extract just the content
    // For now, show a simple message directing users to the standalone route
    // In the future, we could refactor SubscribePage to have a separate content widget
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Icon(
            Icons.workspace_premium_outlined,
            size: 80,
            color: Colors.orange.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            'ChekMate Premium',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Unlock exclusive features and benefits',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.go('/subscribe'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade500,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 48,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'View Plans',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 48),
          _buildFeatureItem(
            Icons.verified,
            'Verified Badge',
            'Stand out with a verified profile',
          ),
          const SizedBox(height: 20),
          _buildFeatureItem(
            Icons.visibility_off,
            'Incognito Mode',
            'Browse profiles privately',
          ),
          const SizedBox(height: 20),
          _buildFeatureItem(
            Icons.favorite,
            'Unlimited Likes',
            'Like as many profiles as you want',
          ),
          const SizedBox(height: 20),
          _buildFeatureItem(
            Icons.star,
            'Priority Support',
            'Get help when you need it',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.orange.shade500,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Post interaction methods
  void _showShareModal(Post post) {
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
              onTap: () async {
                Navigator.pop(context);
                await _copyPostLink(post);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share to...'),
              onTap: () async {
                Navigator.pop(context);
                await _sharePost(post);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showComments(String postId) {
    // Navigate to comments page
    context.push('/post/$postId/comments');
    if (kDebugMode) {
      debugPrint('Opening comments for post: $postId');
    }
  }

  void _showPostOptions(Post post) {
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
              onTap: () async {
                Navigator.pop(context);
                await _savePost(post);
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_outlined),
              title: const Text('Report Post'),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog(post);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Hide Posts from User'),
              onTap: () {
                Navigator.pop(context);
                _showHideUserDialog(post);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Post interaction features implementation

  /// Copy post link to clipboard
  Future<void> _copyPostLink(Post post) async {
    try {
      final postUrl = 'https://chekmate.app/post/${post.id}';
      await Clipboard.setData(ClipboardData(text: postUrl));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Link copied to clipboard'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to copy link: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to copy link'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Share post using system share sheet
  Future<void> _sharePost(Post post) async {
    try {
      final postUrl = 'https://chekmate.app/post/${post.id}';
      final shareText =
          'Check out this post by ${post.username}: ${post.content}\n\n$postUrl';

      // For now, copy to clipboard as a fallback
      // In a real app, you would use share_plus package
      await Clipboard.setData(ClipboardData(text: shareText));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Share content copied to clipboard'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to share post: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to share post'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Save post to user's saved posts
  Future<void> _savePost(Post post) async {
    try {
      // Simulate API call
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // In a real app, you would call your backend service
      // await PostService.savePost(post.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post by ${post.username} saved'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save post: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show report dialog with different report reasons
  void _showReportDialog(Post post) {
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
              leading: const Icon(Icons.report),
              title: const Text('Spam'),
              onTap: () => _submitReport(post.id, 'spam', 'This post is spam'),
            ),
            ListTile(
              leading: const Icon(Icons.warning),
              title: const Text('Inappropriate content'),
              onTap: () => _submitReport(
                post.id,
                'inappropriate',
                'This post contains inappropriate content',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.copyright),
              title: const Text('Copyright violation'),
              onTap: () => _submitReport(
                post.id,
                'copyright',
                'This post violates copyright',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.more_horiz),
              title: const Text('Other'),
              onTap: () => _submitReport(post.id, 'other', 'Other reason'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Submit report to backend
  Future<void> _submitReport(
    String postId,
    String reason,
    String description,
  ) async {
    Navigator.pop(context); // Close report dialog

    try {
      // Simulate API call
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // In a real app, you would call your backend service
      // await PostService.reportPost(postId, reason, description);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Post reported. Thank you for helping keep our community safe.',
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to report post: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to report post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show confirmation dialog for hiding posts from user
  void _showHideUserDialog(Post post) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hide posts from this user?'),
        content: Text(
          'You won\'t see posts from ${post.username} anymore. You can undo this in your settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _hideUserPosts(post),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Hide'),
          ),
        ],
      ),
    );
  }

  /// Hide all posts from the specified user
  Future<void> _hideUserPosts(Post post) async {
    Navigator.pop(context); // Close confirmation dialog

    try {
      // Simulate API call
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // In a real app, you would call your backend service
      // await UserService.blockUser(post.userAvatar);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Posts from ${post.username} are now hidden'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // In a real app, implement undo functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Undo functionality would be implemented here'),
                  ),
                );
              },
            ),
          ),
        );
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to hide user posts: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to hide posts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
