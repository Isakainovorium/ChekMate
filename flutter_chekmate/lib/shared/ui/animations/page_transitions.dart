import 'package:flutter/material.dart';

/// Page Transitions
///
/// Custom page transitions for smooth navigation between screens.
/// Inspired by TikTok's navigation patterns.
///
/// Usage with GoRouter:
/// ```dart
/// GoRoute(
///   path: '/profile',
///   pageBuilder: (context, state) {
///     return TikTokPageTransition(
///       child: ProfilePage(),
///       type: TikTokTransitionType.slideUp,
///     );
///   },
/// )
/// ```
///
/// Usage with Navigator:
/// ```dart
/// Navigator.push(
///   context,
///   TikTokPageRoute(
///     builder: (context) => ProfilePage(),
///     type: TikTokTransitionType.slideUp,
///   ),
/// );
/// ```

/// TikTok-style page transition types
enum TikTokTransitionType {
  /// Slide from bottom (TikTok profile, comments)
  slideUp,

  /// Slide from right (TikTok standard navigation)
  slideRight,

  /// Slide from left (TikTok back navigation)
  slideLeft,

  /// Fade transition (TikTok modal overlays)
  fade,

  /// Scale transition (TikTok image zoom)
  scale,

  /// Slide up with fade (TikTok bottom sheet)
  slideUpFade,

  /// No transition (instant)
  none,
}

/// TikTok Page Transition Widget
///
/// Use with GoRouter's pageBuilder
class TikTokPageTransition extends Page<void> {
  const TikTokPageTransition({
    required this.child,
    this.type = TikTokTransitionType.slideRight,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;
  final TikTokTransitionType type;
  final Duration duration;
  final Duration? reverseDuration;

  @override
  Route<void> createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration,
      reverseTransitionDuration: reverseDuration ?? duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildTransition(
          context,
          animation,
          secondaryAnimation,
          child,
          type,
        );
      },
    );
  }
}

/// TikTok Page Route
///
/// Use with Navigator.push
class TikTokPageRoute<T> extends PageRoute<T> {
  TikTokPageRoute({
    required this.builder,
    this.type = TikTokTransitionType.slideRight,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration,
    super.settings,
    super.fullscreenDialog = false,
  });

  final WidgetBuilder builder;
  final TikTokTransitionType type;
  final Duration duration;
  final Duration? reverseDuration;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  Duration get reverseTransitionDuration => reverseDuration ?? duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _buildTransition(
      context,
      animation,
      secondaryAnimation,
      child,
      type,
    );
  }
}

/// Build transition based on type
Widget _buildTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
  TikTokTransitionType type,
) {
  switch (type) {
    case TikTokTransitionType.slideUp:
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: child,
      );

    case TikTokTransitionType.slideRight:
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: child,
      );

    case TikTokTransitionType.slideLeft:
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: child,
      );

    case TikTokTransitionType.fade:
      return FadeTransition(
        opacity: animation,
        child: child,
      );

    case TikTokTransitionType.scale:
      return ScaleTransition(
        scale: Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
        ),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );

    case TikTokTransitionType.slideUpFade:
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );

    case TikTokTransitionType.none:
      return child;
  }
}

/// Shared Axis Transition (Material Design 3)
///
/// Smooth transition between related screens
class SharedAxisTransition extends StatelessWidget {
  const SharedAxisTransition({
    required this.animation,
    required this.child,
    super.key,
    this.fillColor,
  });

  final Animation<double> animation;
  final Widget child;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Fade Through Transition (Material Design 3)
///
/// Transition between unrelated screens
class FadeThroughTransition extends StatelessWidget {
  const FadeThroughTransition({
    required this.animation,
    required this.child,
    super.key,
    this.fillColor,
  });

  final Animation<double> animation;
  final Widget child;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.92,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Bottom Sheet Transition
///
/// Slide up from bottom with backdrop
class BottomSheetTransition extends StatelessWidget {
  const BottomSheetTransition({
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
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
      ),
      child: child,
    );
  }
}
