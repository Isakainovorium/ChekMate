import 'package:flutter/material.dart';

/// Page Transitions - Custom page transition animations
///
/// Provides page transition animations for the dating experience platform.
///
/// Date: November 13, 2025

/// SlidePageRoute - Slide transition for page navigation
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  SlidePageRoute({
    required this.page,
    this.direction = AxisDirection.left,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final offset = _getOffsetForDirectionStatic(direction);
            return SlideTransition(
              position: Tween<Offset>(
                begin: offset,
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            );
          },
        );

  final Widget page;
  final AxisDirection direction;
  final Duration duration;

  static Offset _getOffsetForDirectionStatic(AxisDirection direction) {
    switch (direction) {
      case AxisDirection.up:
        return const Offset(0, 1);
      case AxisDirection.down:
        return const Offset(0, -1);
      case AxisDirection.left:
        return const Offset(1, 0);
      case AxisDirection.right:
        return const Offset(-1, 0);
    }
  }
}

/// TikTok-style Page Transition
enum TikTokTransitionType {
  slideUp,
  slideDown,
  fade,
}

class TikTokPageTransition<T> extends Page<T> {
  const TikTokPageTransition({
    required this.child,
    required this.type,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;
  final TikTokTransitionType type;

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (type) {
          case TikTokTransitionType.slideUp:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            );
          case TikTokTransitionType.slideDown:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            );
          case TikTokTransitionType.fade:
            return FadeTransition(
              opacity: animation,
              child: child,
            );
        }
      },
    );
  }
}

/// Shared Axis Transition (Material Design 3)
class SharedAxisTransition extends StatelessWidget {
  const SharedAxisTransition({
    required this.animation,
    required this.child,
    super.key,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.3, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

/// Fade Through Transition (Material Design 3)
class FadeThroughTransition extends StatelessWidget {
  const FadeThroughTransition({
    required this.animation,
    required this.child,
    super.key,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

/// TikTokPageRoute - TikTok-style page route with customizable transitions
class TikTokPageRoute<T> extends PageRouteBuilder<T> {
  TikTokPageRoute({
    required super.pageBuilder,
    super.settings,
    this.type = TikTokTransitionType.slideUp,
    Duration duration = const Duration(milliseconds: 300),
  }) : super(
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildTransition(type, animation, child);
          },
        );

  final TikTokTransitionType type;

  static Widget _buildTransition(
    TikTokTransitionType type,
    Animation<double> animation,
    Widget child,
  ) {
    switch (type) {
      case TikTokTransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1), // Slide up from bottom
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          )),
          child: child,
        );
      case TikTokTransitionType.slideDown:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1), // Slide down from top
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          )),
          child: child,
        );
      case TikTokTransitionType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
    }
  }
}

/// FadePageRoute - Fade transition for page navigation
class FadePageRoute<T> extends PageRouteBuilder<T> {
  FadePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );

  final Widget page;
  final Duration duration;
}

/// ScalePageRoute - Scale transition for page navigation
class ScalePageRoute<T> extends PageRouteBuilder<T> {
  ScalePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              scale: Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            );
          },
        );

  final Widget page;
  final Duration duration;
}

/// SlideFadePageRoute - Combined slide and fade transition
class SlideFadePageRoute<T> extends PageRouteBuilder<T> {
  SlideFadePageRoute({
    required this.page,
    this.direction = AxisDirection.left,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final offset = _getOffsetForDirectionStatic(direction);
            return SlideTransition(
              position: Tween<Offset>(
                begin: offset,
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );

  final Widget page;
  final AxisDirection direction;
  final Duration duration;

  static Offset _getOffsetForDirectionStatic(AxisDirection direction) {
    switch (direction) {
      case AxisDirection.up:
        return const Offset(0, 1);
      case AxisDirection.down:
        return const Offset(0, -1);
      case AxisDirection.left:
        return const Offset(1, 0);
      case AxisDirection.right:
        return const Offset(-1, 0);
    }
  }
}
