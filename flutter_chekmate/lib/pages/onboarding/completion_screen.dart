import 'package:flutter/material.dart';
import 'package:flutter_chekmate/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_chekmate/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:flutter_chekmate/shared/utils/haptic_feedback.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Completion Screen - Step 5 of onboarding
/// Shows success message and profile summary with premium visual design
class CompletionScreen extends ConsumerStatefulWidget {
  const CompletionScreen({super.key});

  @override
  ConsumerState<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends ConsumerState<CompletionScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkAnimationController;
  late AnimationController _contentAnimationController;
  late AnimationController _shimmerController;
  late Animation<double> _checkScaleAnimation;
  late Animation<double> _checkRotateAnimation;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    
    // Check mark animation
    _checkAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _checkScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.9), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(
      parent: _checkAnimationController,
      curve: Curves.easeOutBack,
    ));
    
    _checkRotateAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _checkAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    // Content fade/slide animation
    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Curves.easeOut,
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Shimmer animation for button
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Start animations with delay
    _checkAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _contentAnimationController.forward();
    });
    
    // Haptic feedback on success
    AppHaptics.success();
  }

  @override
  void dispose() {
    _checkAnimationController.dispose();
    _contentAnimationController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _handleStartExploring() async {
    AppHaptics.medium();
    setState(() => _isCompleting = true);

    try {
      // Watch auth state to handle loading state properly
      final authState = ref.read(authStateProvider);
      
      final userId = authState.when(
        data: (user) => user?.uid,
        loading: () => null,
        error: (_, __) => null,
      );

      if (userId == null) {
        // If still loading, wait a moment and retry
        await Future.delayed(const Duration(milliseconds: 500));
        final retryUser = ref.read(currentUserProvider);
        if (retryUser?.uid == null) {
          // Skip Firestore sync but still navigate - user can sync later
          if (mounted) {
            context.go('/');
          }
          return;
        }
      }

      // Complete onboarding and sync to Firestore
      if (userId != null) {
        await ref
            .read(onboardingStateProvider.notifier)
            .completeOnboarding(userId);
      }

      if (mounted) {
        context.go('/');
      }
    } on Exception catch (e) {
      debugPrint('Onboarding completion error: $e');
      // Navigate anyway - don't block user
      if (mounted) {
        context.go('/');
      }
    } finally {
      if (mounted) {
        setState(() => _isCompleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingStateProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFBF5), // Warm cream top
              Color(0xFFFFFFFF), // White bottom
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.06),

                // Animated success badge
                AnimatedBuilder(
                  animation: _checkAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _checkScaleAnimation.value,
                      child: Transform.rotate(
                        angle: _checkRotateAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: _buildSuccessBadge(),
                ),

                const SizedBox(height: 32),

                // Animated content
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeInAnimation,
                    child: Column(
                      children: [
                        // Welcome heading with gradient
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFF1A1A2E),
                              Color(0xFF16213E),
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            'Welcome to ChekMate!',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Animated tagline
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFF5A623),
                                Color(0xFFFF8C00),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF5A623).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Text(
                            "Dating can be a Game - Don't Get Played",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Subtitle
                        Text(
                          'Your profile is ready!\nStart sharing your dating experiences.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Premium profile summary card
                        _buildProfileSummaryCard(onboardingState),

                        const SizedBox(height: 32),

                        // Animated CTA button
                        _buildStartExploringButton(),

                        const SizedBox(height: 20),

                        // Step indicator
                        _buildStepIndicator(),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessBadge() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4ADE80), // Light green
            Color(0xFF22C55E), // Green
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22C55E).withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFF22C55E).withOpacity(0.2),
            blurRadius: 60,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 3,
              ),
            ),
          ),
          // Check icon
          const Icon(
            Icons.check_rounded,
            size: 70,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSummaryCard(dynamic onboardingState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade100,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5A623).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Color(0xFFF5A623),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Your Profile Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Interests
          if (onboardingState.selectedInterests.isNotEmpty) ...[
            _buildEnhancedSummaryItem(
              icon: Icons.favorite_rounded,
              iconColor: const Color(0xFFEC4899),
              iconBgColor: const Color(0xFFFCE7F3),
              title: 'Interests',
              value: '${onboardingState.selectedInterests.length} selected',
              subtitle: onboardingState.selectedInterests.take(3).join(', ') +
                  (onboardingState.selectedInterests.length > 3 ? '...' : ''),
            ),
            const SizedBox(height: 16),
          ],

          // Location
          _buildEnhancedSummaryItem(
            icon: Icons.location_on_rounded,
            iconColor: const Color(0xFF8B5CF6),
            iconBgColor: const Color(0xFFEDE9FE),
            title: 'Location',
            value: onboardingState.locationEnabled ? 'Enabled' : 'Not set',
            subtitle: onboardingState.locationName ?? 'Unknown Location',
          ),

          const SizedBox(height: 20),

          // Completion progress
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Profile Completion',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getCompletionColor(onboardingState.completionScore)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${onboardingState.completionScore}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _getCompletionColor(onboardingState.completionScore),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: onboardingState.completionScore / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getCompletionColor(onboardingState.completionScore),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCompletionColor(int score) {
    if (score >= 80) return const Color(0xFF22C55E);
    if (score >= 50) return const Color(0xFFF5A623);
    return const Color(0xFFEF4444);
  }

  Widget _buildEnhancedSummaryItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
    String? subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                  ),
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStartExploringButton() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFF5A623),
                Color(0xFFFF8C00),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF5A623).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isCompleting ? null : _handleStartExploring,
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Shimmer effect
                  if (!_isCompleting)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.white.withOpacity(0),
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0),
                              ],
                              stops: [
                                _shimmerController.value - 0.3,
                                _shimmerController.value,
                                _shimmerController.value + 0.3,
                              ].map((s) => s.clamp(0.0, 1.0)).toList(),
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.srcATop,
                          child: Container(color: Colors.white),
                        ),
                      ),
                    ),
                  // Button content
                  Center(
                    child: _isCompleting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Start Exploring',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(5, (index) {
          final isComplete = index < 5;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: index == 4 ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isComplete
                  ? const Color(0xFF22C55E)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
        const SizedBox(width: 12),
        const Text(
          'Complete!',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF22C55E),
          ),
        ),
        const SizedBox(width: 4),
        const Icon(
          Icons.check_circle_rounded,
          size: 16,
          color: Color(0xFF22C55E),
        ),
      ],
    );
  }
}
