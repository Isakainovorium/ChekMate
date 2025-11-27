import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Welcome Screen - First step of onboarding flow
/// Features entrance animations for premium feel
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _featuresController;
  late AnimationController _buttonController;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _featuresFade;
  late Animation<Offset> _featuresSlide;
  late Animation<double> _buttonScale;
  late Animation<double> _buttonFade;

  @override
  void initState() {
    super.initState();

    // Header animation (logo + text)
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    ));

    // Features animation (staggered)
    _featuresController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _featuresFade = CurvedAnimation(
      parent: _featuresController,
      curve: Curves.easeOut,
    );
    _featuresSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _featuresController,
      curve: Curves.easeOutCubic,
    ));

    // Button animation
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _buttonScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.elasticOut),
    );
    _buttonFade = CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeOut,
    );

    // Start staggered animations
    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _featuresController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _buttonController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _featuresController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

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
  Widget build(BuildContext context) {
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

              // Animated Header Section
              SlideTransition(
                position: _headerSlide,
                child: FadeTransition(
                  opacity: _headerFade,
                  child: Column(
                    children: [
                      // ChekMate Logo (animated icon instead of image)
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.primary, Color(0xFFFF8C00)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '✓',
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
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

                      // Tagline with gradient
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [AppColors.primary, Color(0xFFFF6B6B)],
                        ).createShader(bounds),
                        child: const Text(
                          'Dating can be a Game - Don\'t Get Played',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
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
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // Animated Features Section
              SlideTransition(
                position: _featuresSlide,
                child: FadeTransition(
                  opacity: _featuresFade,
                  child: Column(
                    children: [
                      _buildFeatureItem(
                        icon: Icons.star_rounded,
                        title: 'Rate Your Dates',
                        description:
                            'Share experiences with WOW, GTFOH, or ChekMate',
                        delay: 0,
                      ),
                      AppSpacing.gapLG,
                      _buildFeatureItem(
                        icon: Icons.location_on_rounded,
                        title: 'Discover Local Stories',
                        description:
                            'See what\'s happening in your local community',
                        delay: 1,
                      ),
                      AppSpacing.gapLG,
                      _buildFeatureItem(
                        icon: Icons.people_rounded,
                        title: 'Join the Community',
                        description: 'Connect through shared dating experiences',
                        delay: 2,
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Animated Get Started Button
              ScaleTransition(
                scale: _buttonScale,
                child: FadeTransition(
                  opacity: _buttonFade,
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _handleGetStarted(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: AppColors.primary.withOpacity(0.4),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
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
    required int delay,
  }) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.15),
                AppColors.secondary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 26,
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
