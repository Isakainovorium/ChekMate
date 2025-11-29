import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

/// Animated Splash Screen - Premium app launch experience
/// Features:
/// - Animated logo with scale + fade
/// - Pulsing glow effect
/// - Smart routing based on auth state
///
/// Flow:
/// - If logged in + onboarding complete → Home
/// - If logged in + onboarding NOT complete → Onboarding
/// - If NOT logged in → Login
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _glowController;
  late AnimationController _textController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _glowOpacity;
  late Animation<double> _textSlide;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    // Logo animation - scale up with bounce
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(_logoController);

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Glow pulse animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _glowOpacity = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Text slide up animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    // Start animation sequence
    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _glowController.repeat(reverse: true);

    await Future.delayed(const Duration(milliseconds: 400));
    _textController.forward();

    // Wait for animations then determine route
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      await _navigateBasedOnAuthState();
    }
  }

  /// Determine where to navigate based on auth state and onboarding status
  Future<void> _navigateBasedOnAuthState() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // Not logged in → Go to Login
        if (mounted) context.go('/auth/login');
        return;
      }

      // User is logged in - check onboarding status
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        // User doc doesn't exist - new user, needs onboarding
        if (mounted) context.go('/onboarding/welcome');
        return;
      }

      final data = userDoc.data();
      final onboardingCompleted =
          data?['onboardingCompleted'] as bool? ?? false;

      if (onboardingCompleted) {
        // Onboarding complete → Go to Home
        if (mounted) context.go('/');
      } else {
        // Onboarding not complete → Go to Onboarding
        if (mounted) context.go('/onboarding/welcome');
      }
    } catch (e) {
      // On error, default to login
      debugPrint('Splash navigation error: $e');
      if (mounted) context.go('/auth/login');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _glowController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated logo with glow
            AnimatedBuilder(
              animation: Listenable.merge([_logoController, _glowController]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _logoScale.value,
                  child: Opacity(
                    opacity: _logoOpacity.value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow effect
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary
                                    .withOpacity(_glowOpacity.value),
                                blurRadius: 60,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                        ),
                        // Official ChekMate Logo
                        ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.asset(
                            'assets/images/auth/checkmate_logo.png',
                            width: 180,
                            height: 180,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // Animated tagline
            AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _textSlide.value),
                  child: Opacity(
                    opacity: _textOpacity.value,
                    child: Column(
                      children: [
                        // Tagline with brand styling
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Text(
                            "Dating can be a Game - Don't Get Played",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
