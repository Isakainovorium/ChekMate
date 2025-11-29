import 'package:flutter/material.dart';

/// Custom page route for smooth onboarding transitions
/// Features:
/// - Slide + fade combination
/// - Shared element hero support
/// - Customizable direction
class OnboardingPageRoute<T> extends PageRouteBuilder<T> {
  OnboardingPageRoute({
    required this.page,
    this.direction = SlideDirection.left,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Combined slide + fade transition
            final slideTween = Tween<Offset>(
              begin: _getBeginOffset(direction),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic));

            final fadeTween = Tween<double>(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: Curves.easeOut));

            // Scale for depth effect
            final scaleTween = Tween<double>(begin: 0.95, end: 1.0)
                .chain(CurveTween(curve: Curves.easeOut));

            return SlideTransition(
              position: animation.drive(slideTween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: ScaleTransition(
                  scale: animation.drive(scaleTween),
                  child: child,
                ),
              ),
            );
          },
        );

  final Widget page;
  final SlideDirection direction;

  static Offset _getBeginOffset(SlideDirection direction) {
    switch (direction) {
      case SlideDirection.left:
        return const Offset(0.3, 0);
      case SlideDirection.right:
        return const Offset(-0.3, 0);
      case SlideDirection.up:
        return const Offset(0, 0.3);
      case SlideDirection.down:
        return const Offset(0, -0.3);
    }
  }
}

enum SlideDirection { left, right, up, down }

/// Fade scale page transition for modal-like screens
class FadeScalePageRoute<T> extends PageRouteBuilder<T> {
  FadeScalePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );

            return FadeTransition(
              opacity: curvedAnimation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0)
                    .animate(curvedAnimation),
                child: child,
              ),
            );
          },
        );

  final Widget page;
}

/// Hero fade route for seamless shared element transitions
class HeroFadeRoute<T> extends PageRouteBuilder<T> {
  HeroFadeRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
        );

  final Widget page;
}
