import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Lottie Animation Widget
///
/// Provides a consistent way to display Lottie animations throughout the app.
/// Supports both asset and network animations with customizable controls.
///
/// Usage:
/// ```dart
/// LottieAnimation.asset(
///   'assets/animations/loading.json',
///   width: 200,
///   height: 200,
/// )
/// ```
class LottieAnimation extends StatefulWidget {
  const LottieAnimation.asset(
    this.assetPath, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.repeat = true,
    this.reverse = false,
    this.animate = true,
    this.onLoaded,
    this.controller,
  })  : networkUrl = null,
        isAsset = true;

  const LottieAnimation.network(
    this.networkUrl, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.repeat = true,
    this.reverse = false,
    this.animate = true,
    this.onLoaded,
    this.controller,
  })  : assetPath = null,
        isAsset = false;

  final String? assetPath;
  final String? networkUrl;
  final bool isAsset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool repeat;
  final bool reverse;
  final bool animate;
  final void Function(LottieComposition)? onLoaded;
  final AnimationController? controller;

  @override
  State<LottieAnimation> createState() => _LottieAnimationState();
}

class _LottieAnimationState extends State<LottieAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _useProvidedController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
      _useProvidedController = true;
    } else {
      _controller = AnimationController(vsync: this);
    }
  }

  @override
  void dispose() {
    if (!_useProvidedController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAsset) {
      return Lottie.asset(
        widget.assetPath!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        repeat: widget.repeat,
        reverse: widget.reverse,
        animate: widget.animate,
        controller: _controller,
        onLoaded: (composition) {
          _controller.duration = composition.duration;
          widget.onLoaded?.call(composition);
          if (widget.animate) {
            if (widget.repeat) {
              _controller.repeat(reverse: widget.reverse);
            } else {
              _controller.forward();
            }
          }
        },
      );
    } else {
      return Lottie.network(
        widget.networkUrl!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        repeat: widget.repeat,
        reverse: widget.reverse,
        animate: widget.animate,
        controller: _controller,
        onLoaded: (composition) {
          _controller.duration = composition.duration;
          widget.onLoaded?.call(composition);
          if (widget.animate) {
            if (widget.repeat) {
              _controller.repeat(reverse: widget.reverse);
            } else {
              _controller.forward();
            }
          }
        },
      );
    }
  }
}

/// Pre-built Lottie animations for common use cases
class LottieAnimations {
  LottieAnimations._();

  // Loading animations
  static const String loading = 'assets/animations/loading.json';
  static const String loadingDots = 'assets/animations/loading_dots.json';
  static const String loadingCircle = 'assets/animations/loading_circle.json';

  // Success/Error animations
  static const String success = 'assets/animations/success.json';
  static const String error = 'assets/animations/error.json';
  static const String warning = 'assets/animations/warning.json';

  // Social interactions
  static const String like = 'assets/animations/like.json';
  static const String heart = 'assets/animations/heart.json';
  static const String favorite = 'assets/animations/favorite.json';
  static const String bookmark = 'assets/animations/bookmark.json';

  // Empty states
  static const String emptyBox = 'assets/animations/empty_box.json';
  static const String noData = 'assets/animations/no_data.json';
  static const String noMessages = 'assets/animations/no_messages.json';
  static const String noNotifications =
      'assets/animations/no_notifications.json';

  // Actions
  static const String swipeUp = 'assets/animations/swipe_up.json';
  static const String swipeLeft = 'assets/animations/swipe_left.json';
  static const String swipeRight = 'assets/animations/swipe_right.json';
  static const String checkmark = 'assets/animations/checkmark.json';

  // Misc
  static const String confetti = 'assets/animations/confetti.json';
  static const String celebration = 'assets/animations/celebration.json';
}

/// Loading Animation Widget
class LoadingAnimation extends StatelessWidget {
  const LoadingAnimation({
    super.key,
    this.size = 100,
    this.message,
  });

  final double size;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LottieAnimation.asset(
            LottieAnimations.loading,
            width: size,
            height: size,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Success Animation Widget
class SuccessAnimation extends StatelessWidget {
  const SuccessAnimation({
    super.key,
    this.size = 150,
    this.message,
    this.onComplete,
  });

  final double size;
  final String? message;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LottieAnimation.asset(
            LottieAnimations.success,
            width: size,
            height: size,
            repeat: false,
            onLoaded: (composition) {
              if (onComplete != null) {
                Future.delayed(composition.duration, onComplete);
              }
            },
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Error Animation Widget
class ErrorAnimation extends StatelessWidget {
  const ErrorAnimation({
    super.key,
    this.size = 150,
    this.message,
  });

  final double size;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LottieAnimation.asset(
            LottieAnimations.error,
            width: size,
            height: size,
            repeat: false,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Empty State Animation Widget
class EmptyStateAnimation extends StatelessWidget {
  const EmptyStateAnimation({
    super.key,
    this.size = 200,
    this.title,
    this.message,
    this.actionButton,
    this.animationPath = LottieAnimations.emptyBox,
  });

  final double size;
  final String? title;
  final String? message;
  final Widget? actionButton;
  final String animationPath;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LottieAnimation.asset(
              animationPath,
              width: size,
              height: size,
            ),
            if (title != null) ...[
              const SizedBox(height: 24),
              Text(
                title!,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ],
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withValues(alpha: 0.6),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionButton != null) ...[
              const SizedBox(height: 24),
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }
}

