import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

/// Animated Splash Screen - Premium app launch experience
/// Features:
/// - Animated logo with scale + fade
/// - Pulsing glow effect
/// - Smooth transition to main app
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
    
    // Navigate after splash
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      context.go('/onboarding/welcome');
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
                        // Logo container
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary,
                                Color(0xFFFF8C00),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(28),
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
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
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
                        const Text(
                          'ChekMate',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Date Smart. Stay Safe.',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
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
