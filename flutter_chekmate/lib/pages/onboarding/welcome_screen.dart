import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Welcome Screen - First step of onboarding flow
/// Shows app logo, tagline, and Get Started button
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  void _handleGetStarted(BuildContext context) {
    context.go('/onboarding/interests');
  }

  void _handleSkip(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Onboarding?'),
        content: const Text(
          'We recommend completing the onboarding to personalize your ChekMate experience. '
          'You can always update your preferences later in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go Back'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/');
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Skip Anyway'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Skip button (top right)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => _handleSkip(context),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // ChekMate Logo
              Center(
                child: Image.asset(
                  'assets/images/auth/Top_asset.png',
                  width: 300,
                  fit: BoxFit.contain,
                ),
              ),

              AppSpacing.gapXL,

              // Welcome Heading
              const Text(
                'Welcome to ChekMate!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              AppSpacing.gapMD,

              // Tagline
              const Text(
                'Dating can be a Game - Don\'t Get Played',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF5A623),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              AppSpacing.gapSM,

              // Description
              const Text(
                'Share your dating experiences, rate your dates,\nand discover what others are saying.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // Feature highlights
              _buildFeatureItem(
                icon: Icons.star_rounded,
                title: 'Rate Your Dates',
                description: 'Share experiences with WOW, GTFOH, or ChekMate',
              ),

              AppSpacing.gapLG,

              _buildFeatureItem(
                icon: Icons.location_on_rounded,
                title: 'Discover Local Stories',
                description: 'See what\'s happening in your dating scene',
              ),

              AppSpacing.gapLG,

              _buildFeatureItem(
                icon: Icons.people_rounded,
                title: 'Join the Community',
                description: 'Connect through shared dating experiences',
              ),

              const Spacer(flex: 2),

              // Get Started Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _handleGetStarted(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5A623),
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              AppSpacing.gapLG,

              // Progress indicator
              const Text(
                'Step 1 of 5',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),

              AppSpacing.gapLG,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        AppSpacing.gapMD,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
