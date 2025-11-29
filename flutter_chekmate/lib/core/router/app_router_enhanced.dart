import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/navigation/main_navigation.dart';
import 'package:flutter_chekmate/core/router/route_constants.dart';
import 'package:flutter_chekmate/features/auth/pages/two_factor_verification_page.dart';
import 'package:flutter_chekmate/features/feed/subfeatures/profile/pages/user_profile_page.dart';
import 'package:flutter_chekmate/features/feed/widgets/post_detail_modal.dart';
import 'package:flutter_chekmate/features/theme_test/theme_test_page.dart';
import 'package:flutter_chekmate/pages/auth/login_page.dart';
import 'package:flutter_chekmate/pages/auth/signup_page.dart';
import 'package:flutter_chekmate/pages/create_post/create_post_page.dart';
import 'package:flutter_chekmate/pages/explore/explore_page.dart';
import 'package:flutter_chekmate/pages/home/home_page.dart';
import 'package:flutter_chekmate/features/live/presentation/pages/live_page.dart';
import 'package:flutter_chekmate/pages/messages/chat_page.dart';
import 'package:flutter_chekmate/pages/messages/messages_page.dart';
import 'package:flutter_chekmate/pages/notifications/notifications_page.dart';
import 'package:flutter_chekmate/pages/onboarding/completion_screen.dart';
import 'package:flutter_chekmate/pages/onboarding/interests_screen.dart';
import 'package:flutter_chekmate/pages/onboarding/location_screen.dart';
import 'package:flutter_chekmate/pages/onboarding/profile_photo_screen.dart';
import 'package:flutter_chekmate/pages/onboarding/welcome_screen.dart';
import 'package:flutter_chekmate/pages/splash/splash_screen.dart';
import 'package:flutter_chekmate/pages/profile/interests_management_page.dart';
import 'package:flutter_chekmate/pages/profile/notification_schedule_settings_page.dart';
import 'package:flutter_chekmate/features/profile/pages/theme_settings_page.dart';
import 'package:flutter_chekmate/pages/profile/location_settings_page.dart';
import 'package:flutter_chekmate/pages/profile/my_profile_page.dart';
import 'package:flutter_chekmate/pages/rate_date/rate_date_page.dart';
import 'package:flutter_chekmate/pages/subscribe/subscribe_page.dart';
import 'package:flutter_chekmate/shared/ui/animations/page_transitions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Enhanced App Router with Custom Page Transitions
///
/// Features:
/// - Named routes with constants
/// - Custom page transitions (slide, fade, shared axis)
/// - Deep linking support
/// - Type-safe navigation
/// - Hero animations support
final appRouterEnhancedProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen - App entry point
      GoRoute(
        path: '/splash',
        name: 'splash',
        pageBuilder: (context, state) => _buildFadePage(
          context,
          state,
          const SplashScreen(),
        ),
      ),
      // Auth Routes - Fade transition
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        pageBuilder: (context, state) => _buildFadePage(
          context,
          state,
          const LoginPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.signup,
        name: RouteNames.signup,
        pageBuilder: (context, state) => _buildFadePage(
          context,
          state,
          const SignUpPage(),
        ),
      ),

      // Home/Feed - Default transition
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (context, state) => const MainNavigation(
          currentIndex: 0,
          child: HomePage(),
        ),
      ),

      // Messages - Slide from right
      GoRoute(
        path: RoutePaths.messages,
        name: RouteNames.messages,
        pageBuilder: (context, state) => _buildSlideRightPage(
          context,
          state,
          const MainNavigation(
            currentIndex: 1,
            child: MessagesPage(),
          ),
        ),
      ),

      // Chat - Slide up transition
      GoRoute(
        path: RoutePaths.chat,
        name: RouteNames.chat,
        pageBuilder: (context, state) {
          final conversationId =
              state.pathParameters[RouteParams.conversationId] ?? '';
          final userId = state.uri.queryParameters[QueryParams.userId] ?? '';
          final userName =
              state.uri.queryParameters[QueryParams.userName] ?? '';
          final userAvatar =
              state.uri.queryParameters[QueryParams.userAvatar] ?? '';

          return _buildSlideUpPage(
            context,
            state,
            MainNavigation(
              currentIndex: 1,
              hideNavigation: true,
              child: ChatPage(
                conversationId: conversationId,
                otherUserId: userId,
                otherUserName: userName,
                otherUserAvatar: userAvatar,
              ),
            ),
          );
        },
      ),

      // Notifications - Slide from right
      GoRoute(
        path: RoutePaths.notifications,
        name: RouteNames.notifications,
        pageBuilder: (context, state) => _buildSlideRightPage(
          context,
          state,
          const MainNavigation(
            currentIndex: 3,
            child: NotificationsPage(),
          ),
        ),
      ),

      // Profile - Shared axis transition
      GoRoute(
        path: RoutePaths.profile,
        name: RouteNames.profile,
        pageBuilder: (context, state) => _buildSharedAxisPage(
          context,
          state,
          const MainNavigation(
            currentIndex: 4,
            child: MyProfilePage(
              userAvatar: '', // Will use default avatar if empty
            ),
          ),
        ),
      ),

      // Explore - Fade through transition
      GoRoute(
        path: RoutePaths.explore,
        name: RouteNames.explore,
        pageBuilder: (context, state) => _buildFadeThroughPage(
          context,
          state,
          const MainNavigation(
            currentIndex: 0,
            child: ExplorePage(),
          ),
        ),
      ),

      // Live - Slide up transition
      GoRoute(
        path: RoutePaths.live,
        name: RouteNames.live,
        pageBuilder: (context, state) => _buildSlideUpPage(
          context,
          state,
          const MainNavigation(
            currentIndex: 0,
            child: LivePageNew(
              userAvatar: '', // Will use default avatar if empty
            ),
          ),
        ),
      ),

      // Subscribe - Shared axis transition
      GoRoute(
        path: RoutePaths.subscribe,
        name: RouteNames.subscribe,
        pageBuilder: (context, state) => _buildSharedAxisPage(
          context,
          state,
          const MainNavigation(
            currentIndex: 0,
            child: SubscribePage(),
          ),
        ),
      ),

      // Rate Date - Slide up (full screen)
      GoRoute(
        path: RoutePaths.rateDate,
        name: RouteNames.rateDate,
        pageBuilder: (context, state) => _buildSlideUpPage(
          context,
          state,
          const MainNavigation(
            currentIndex: 0,
            hideNavigation: false, // Show bottom nav for better UX
            child: RateDatePage(),
          ),
        ),
      ),

      // Create Post - Slide up (full screen)
      GoRoute(
        path: RoutePaths.createPost,
        name: RouteNames.createPost,
        pageBuilder: (context, state) => _buildSlideUpPage(
          context,
          state,
          const MainNavigation(
            currentIndex: 0,
            hideNavigation: true,
            child: CreatePostPage(),
          ),
        ),
      ),

      // Location Settings - Slide right transition (profile settings)
      GoRoute(
        path: RoutePaths.locationSettings,
        name: RouteNames.locationSettings,
        pageBuilder: (context, state) => _buildSlideRightPage(
          context,
          state,
          const MainNavigation(
            currentIndex: 4,
            hideNavigation: true,
            child: LocationSettingsPage(),
          ),
        ),
      ),

      // Interests Management - Slide right transition (profile settings)
      GoRoute(
        path: RoutePaths.interestsManagement,
        name: RouteNames.interestsManagement,
        pageBuilder: (context, state) => _buildSlideRightPage(
          context,
          state,
          const MainNavigation(
            currentIndex: 4,
            hideNavigation: true,
            child: InterestsManagementPage(),
          ),
        ),
      ),

      // User Profile - Shared axis transition (view other users' profiles)
      GoRoute(
        path: RoutePaths.userProfile,
        name: RouteNames.userProfile,
        pageBuilder: (context, state) => _buildSharedAxisPage(
          context,
          state,
          const MainNavigation(
            currentIndex: 0,
            hideNavigation: true,
            child: UserProfilePage(),
          ),
        ),
      ),

      // Post Detail - Slide up transition (full screen)
      GoRoute(
        path: RoutePaths.post,
        name: RouteNames.post,
        pageBuilder: (context, state) {
          final postId = state.pathParameters[RouteParams.postId] ?? '';
          // Using PostDetailModal as a full-screen page
          // In production, you might want to create a dedicated PostDetailPage
          return _buildSlideUpPage(
            context,
            state,
            MainNavigation(
              currentIndex: 0,
              hideNavigation: true,
              child: PostDetailModal(
                username: 'Loading...',
                avatar: '', // Will fetch from post data
                content: 'Loading post $postId...',
              ),
            ),
          );
        },
      ),

      // Onboarding Routes - Shared axis transitions for smooth flow
      GoRoute(
        path: '/onboarding/welcome',
        name: 'onboardingWelcome',
        pageBuilder: (context, state) => _buildSharedAxisPage(
          context,
          state,
          const WelcomeScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding/interests',
        name: 'onboardingInterests',
        pageBuilder: (context, state) => _buildSharedAxisPage(
          context,
          state,
          const InterestsScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding/location',
        name: 'onboardingLocation',
        pageBuilder: (context, state) => _buildSharedAxisPage(
          context,
          state,
          const LocationScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding/profile-photo',
        name: 'onboardingProfilePhoto',
        pageBuilder: (context, state) => _buildSharedAxisPage(
          context,
          state,
          const ProfilePhotoScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding/completion',
        name: 'onboardingCompletion',
        pageBuilder: (context, state) => _buildSharedAxisPage(
          context,
          state,
          const CompletionScreen(),
        ),
      ),

      // Settings Routes - Slide from right
      GoRoute(
        path: RoutePaths.notificationScheduleSettings,
        name: RouteNames.notificationScheduleSettings,
        pageBuilder: (context, state) => _buildSlideRightPage(
          context,
          state,
          const MainNavigation(
            currentIndex: 4,
            hideNavigation: true,
            child: NotificationScheduleSettingsPage(),
          ),
        ),
      ),
      GoRoute(
        path: RoutePaths.themeSettings,
        name: RouteNames.themeSettings,
        pageBuilder: (context, state) => _buildSlideRightPage(
          context,
          state,
          const MainNavigation(
            currentIndex: 4,
            hideNavigation: true,
            child: ThemeSettingsPage(),
          ),
        ),
      ),

      // Auth Routes (Additional) - Fade transition
      GoRoute(
        path: RoutePaths.twoFactorVerification,
        name: RouteNames.twoFactorVerification,
        pageBuilder: (context, state) => _buildFadePage(
          context,
          state,
          const TwoFactorVerificationPage(),
        ),
      ),

      // Theme Test - Development only
      GoRoute(
        path: RoutePaths.themeTest,
        name: RouteNames.themeTest,
        builder: (context, state) => const ThemeTestPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '404 - Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Route: ${state.uri}'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RoutePaths.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Build page with fade transition
Page<void> _buildFadePage(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

/// Build page with slide from right transition
Page<void> _buildSlideRightPage(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      final tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

/// Build page with slide up transition
Page<void> _buildSlideUpPage(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return TikTokPageTransition(
    key: state.pageKey,
    child: child,
    type: TikTokTransitionType.slideUp,
  );
}

/// Build page with shared axis transition (Material Design 3)
Page<void> _buildSharedAxisPage(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        child: child,
      );
    },
  );
}

/// Build page with fade through transition (Material Design 3)
Page<void> _buildFadeThroughPage(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeThroughTransition(
        animation: animation,
        child: child,
      );
    },
  );
}
