import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chekmate/core/navigation/nav_state.dart';
import 'package:flutter_chekmate/core/providers/gamification_provider.dart';
import 'package:flutter_chekmate/core/providers/navigation_providers.dart';
import 'package:flutter_chekmate/core/services/keyboard_shortcuts_service.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/core/theme/app_theme.dart';
import 'package:flutter_chekmate/features/feed/pages/feed_page.dart';
import 'package:flutter_chekmate/features/feed/pages/messaging/pages/navigation/widgets/header_widget.dart';
import 'package:flutter_chekmate/features/feed/pages/messaging/pages/navigation/widgets/nav_tabs_widget.dart';
import 'package:flutter_chekmate/pages/explore/explore_page.dart';
import 'package:flutter_chekmate/features/live/presentation/pages/live_page.dart';
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

  // Tab navigation - Sprint 2 Task 2.4.2: Local index for PageController sync
  // Primary navigation state is managed by topNavTabProvider in nav_state.dart
  final List<String> _tabs = [
    'For you',
    'Rate Date',
    'Live',
    'Following',
    'Explore',
    'Subscribe',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
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

  void _handleTabChange(String tab) {
    if (tab == 'Rate Date') {
      // Navigate to full-screen Rate Date route (bottom nav hidden there)
      context.go('/rate-date');
      return;
    }

    final index = _tabs.indexOf(tab);
    if (index != -1) {
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
    ref.read(navStateProvider.notifier).setActiveTab(_tabs[index]);
  }

  // Bottom navigation is provided by the MainNavigation shell.

  void _handleSearch(String query) {
    // Navigate to search page with query
    context.push('/search?q=${Uri.encodeComponent(query)}');
    if (kDebugMode) {
      debugPrint('Search query: $query');
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
        ChekMateShortcuts.refresh: () {}, // Refresh handled by FeedPage
        ChekMateShortcuts.help: _showKeyboardHelp,
        ChekMateShortcuts.scrollDown: _scrollDown,
        ChekMateShortcuts.scrollUp: _scrollUp,
      },
      child: Scaffold(
        // Sprint 2 - Task 2.1.2: Use theme-aware background
        backgroundColor: Theme.of(context).surfaceBackground,
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
    // Use FeedPage with real Firebase data
    return const FeedPage(
      showAppBar: false,
      initialFeedType: FeedType.forYou,
    );
  }

  Widget _buildFollowingFeed() {
    // Use FeedPage with real Firebase data
    return const FeedPage(
      showAppBar: false,
      initialFeedType: FeedType.following,
    );
  }

  Widget _buildExplorePage() {
    // Use the actual ExplorePage widget without AppBar (HomePage has its own header)
    return const ExplorePage(showAppBar: false);
  }

  Widget _buildLivePage() {
    // LivePageNew - Firebase-backed live streaming with WebRTC
    // userAvatar will be fetched from auth state in production
    return const LivePageNew(
      userAvatar: '', // Empty string triggers default avatar
      showAppBar: false,
    );
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
          // Premium subscribe button with scale effect
          PremiumScaleButton(
            onPressed: () => context.go('/subscribe'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF5A623), Color(0xFFFF8C00)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF5A623).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Text(
                'View Plans',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
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

  // Post interactions are now handled internally by FeedPage
}
