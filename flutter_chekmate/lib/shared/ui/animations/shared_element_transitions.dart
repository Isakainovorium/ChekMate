import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

/// Shared Element Transitions
///
/// Provides Material Design 3 shared element transitions using the animations package.
/// These transitions create smooth, connected experiences between screens.
///
/// Usage:
/// ```dart
/// // OpenContainer for expanding transitions
/// OpenContainer(
///   closedBuilder: (context, action) => CardWidget(),
///   openBuilder: (context, action) => DetailPage(),
/// )
///
/// // SharedAxisPageTransition for navigation
/// Navigator.push(
///   context,
///   SharedAxisPageRoute(
///     builder: (context) => NextPage(),
///     transitionType: SharedAxisTransitionType.horizontal,
///   ),
/// );
/// ```

/// Open Container Wrapper
///
/// Wraps a widget with OpenContainer for expanding transitions.
/// Perfect for card-to-detail page transitions.
class AppOpenContainer extends StatelessWidget {
  const AppOpenContainer({
    required this.closedBuilder,
    required this.openBuilder,
    super.key,
    this.transitionType = ContainerTransitionType.fade,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.closedElevation = 0.0,
    this.closedShape,
    this.closedColor,
    this.openColor,
    this.middleColor,
    this.onClosed,
  });

  final CloseContainerBuilder closedBuilder;
  final OpenContainerBuilder<void> openBuilder;
  final ContainerTransitionType transitionType;
  final Duration transitionDuration;
  final double closedElevation;
  final ShapeBorder? closedShape;
  final Color? closedColor;
  final Color? openColor;
  final Color? middleColor;
  final ClosedCallback<bool?>? onClosed;

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedBuilder: closedBuilder,
      openBuilder: openBuilder,
      transitionType: transitionType,
      transitionDuration: transitionDuration,
      closedElevation: closedElevation,
      closedShape: closedShape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
      closedColor: closedColor ?? Theme.of(context).cardColor,
      openColor: openColor ?? Theme.of(context).scaffoldBackgroundColor,
      middleColor: middleColor ?? Theme.of(context).scaffoldBackgroundColor,
      onClosed: onClosed as ClosedCallback<Object?>?,
    );
  }
}

/// Shared Axis Page Route
///
/// Custom PageRoute with SharedAxisTransition.
/// Use with Navigator.push for smooth page transitions.
class SharedAxisPageRoute<T> extends PageRoute<T> {
  SharedAxisPageRoute({
    required this.builder,
    this.transitionType = SharedAxisTransitionType.horizontal,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration,
    this.fillColor,
    super.settings,
  });

  final WidgetBuilder builder;
  final SharedAxisTransitionType transitionType;
  final Duration duration;
  final Duration? reverseDuration;
  final Color? fillColor;

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
    return SharedAxisTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      transitionType: transitionType,
      fillColor: fillColor,
      child: child,
    );
  }
}

/// Fade Through Page Route
///
/// Custom PageRoute with FadeThroughTransition.
/// Use for transitions between unrelated screens.
class FadeThroughPageRoute<T> extends PageRoute<T> {
  FadeThroughPageRoute({
    required this.builder,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration,
    this.fillColor,
    super.settings,
  });

  final WidgetBuilder builder;
  final Duration duration;
  final Duration? reverseDuration;
  final Color? fillColor;

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
    return FadeThroughTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      fillColor: fillColor,
      child: child,
    );
  }
}

/// Fade Scale Page Route
///
/// Custom PageRoute with FadeScaleTransition.
/// Use for modal dialogs and bottom sheets.
class FadeScalePageRoute<T> extends PageRoute<T> {
  FadeScalePageRoute({
    required this.builder,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration,
    super.settings,
  });

  final WidgetBuilder builder;
  final Duration duration;
  final Duration? reverseDuration;

  @override
  Color? get barrierColor => Colors.black54;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  bool get barrierDismissible => true;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

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
    return FadeScaleTransition(
      animation: animation,
      child: child,
    );
  }
}

/// Page Transition Switcher
///
/// Switches between widgets with a transition animation.
/// Perfect for tab switching or content updates.
class AppPageTransitionSwitcher extends StatelessWidget {
  const AppPageTransitionSwitcher({
    required this.child,
    super.key,
    this.duration = const Duration(milliseconds: 300),
    this.reverse = false,
    this.transitionBuilder = fadeScaleTransitionConfiguration,
  });

  final Widget child;
  final Duration duration;
  final bool reverse;
  final PageTransitionSwitcherTransitionBuilder transitionBuilder;

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      duration: duration,
      reverse: reverse,
      transitionBuilder: transitionBuilder,
      child: child,
    );
  }
}

/// Fade Scale Transition Configuration
///
/// Default transition builder for PageTransitionSwitcher.
Widget fadeScaleTransitionConfiguration(
  Widget child,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
) {
  return FadeScaleTransition(
    animation: animation,
    child: child,
  );
}

/// Shared Axis Transition Configuration
///
/// Shared axis transition builder for PageTransitionSwitcher.
Widget sharedAxisTransitionConfiguration(
  Widget child,
  Animation<double> animation,
  Animation<double> secondaryAnimation, {
  SharedAxisTransitionType transitionType = SharedAxisTransitionType.horizontal,
}) {
  return SharedAxisTransition(
    animation: animation,
    secondaryAnimation: secondaryAnimation,
    transitionType: transitionType,
    child: child,
  );
}
