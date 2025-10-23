import 'package:flutter/material.dart';
import 'package:flutter_chekmate/shared/ui/animations/lottie_animations.dart';
import 'package:lottie/lottie.dart';

/// Like Button with Lottie Animation
///
/// Animated like button that plays a Lottie animation when toggled.
/// Perfect for social media interactions.
class AnimatedLikeButton extends StatefulWidget {
  const AnimatedLikeButton({
    required this.isLiked,
    required this.onTap,
    super.key,
    this.size = 32,
    this.likeCount,
    this.showCount = true,
  });

  final bool isLiked;
  final VoidCallback onTap;
  final double size;
  final int? likeCount;
  final bool showCount;

  @override
  State<AnimatedLikeButton> createState() => _AnimatedLikeButtonState();
}

class _AnimatedLikeButtonState extends State<AnimatedLikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedLikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLiked != oldWidget.isLiked && widget.isLiked) {
      _playAnimation();
    }
  }

  void _playAnimation() {
    if (!_isAnimating) {
      setState(() => _isAnimating = true);
      _controller.forward(from: 0).then((_) {
        setState(() => _isAnimating = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: widget.isLiked
                ? Lottie.asset(
                    LottieAnimations.heart,
                    controller: _controller,
                    repeat: false,
                    onLoaded: (composition) {
                      _controller.duration = composition.duration;
                    },
                  )
                : Icon(
                    Icons.favorite_border,
                    size: widget.size * 0.8,
                    color: Theme.of(context).iconTheme.color,
                  ),
          ),
          if (widget.showCount && widget.likeCount != null) ...[
            const SizedBox(width: 4),
            Text(
              _formatCount(widget.likeCount!),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight:
                        widget.isLiked ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

/// Bookmark Button with Lottie Animation
class AnimatedBookmarkButton extends StatefulWidget {
  const AnimatedBookmarkButton({
    required this.isBookmarked,
    required this.onTap,
    super.key,
    this.size = 32,
  });

  final bool isBookmarked;
  final VoidCallback onTap;
  final double size;

  @override
  State<AnimatedBookmarkButton> createState() => _AnimatedBookmarkButtonState();
}

class _AnimatedBookmarkButtonState extends State<AnimatedBookmarkButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedBookmarkButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBookmarked != oldWidget.isBookmarked && widget.isBookmarked) {
      _playAnimation();
    }
  }

  void _playAnimation() {
    if (!_isAnimating) {
      setState(() => _isAnimating = true);
      _controller.forward(from: 0).then((_) {
        setState(() => _isAnimating = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: widget.isBookmarked
            ? Lottie.asset(
                LottieAnimations.bookmark,
                controller: _controller,
                repeat: false,
                onLoaded: (composition) {
                  _controller.duration = composition.duration;
                },
              )
            : Icon(
                Icons.bookmark_border,
                size: widget.size * 0.8,
                color: Theme.of(context).iconTheme.color,
              ),
      ),
    );
  }
}

/// Checkmark Animation (for success states)
class AnimatedCheckmark extends StatefulWidget {
  const AnimatedCheckmark({
    super.key,
    this.size = 100,
    this.onComplete,
  });

  final double size;
  final VoidCallback? onComplete;

  @override
  State<AnimatedCheckmark> createState() => _AnimatedCheckmarkState();
}

class _AnimatedCheckmarkState extends State<AnimatedCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      LottieAnimations.checkmark,
      width: widget.size,
      height: widget.size,
      controller: _controller,
      repeat: false,
      onLoaded: (composition) {
        _controller.duration = composition.duration;
        _controller.forward().then((_) {
          widget.onComplete?.call();
        });
      },
    );
  }
}

/// Confetti Animation (for celebrations)
class ConfettiAnimation extends StatefulWidget {
  const ConfettiAnimation({
    super.key,
    this.size = 300,
    this.autoPlay = true,
  });

  final double size;
  final bool autoPlay;

  @override
  State<ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void play() {
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Lottie.asset(
        LottieAnimations.confetti,
        width: widget.size,
        height: widget.size,
        controller: _controller,
        repeat: false,
        onLoaded: (composition) {
          _controller.duration = composition.duration;
          if (widget.autoPlay) {
            _controller.forward();
          }
        },
      ),
    );
  }
}

/// Swipe Indicator Animation
class SwipeIndicatorAnimation extends StatelessWidget {
  const SwipeIndicatorAnimation({
    super.key,
    this.direction = SwipeDirection.up,
    this.size = 80,
  });

  final SwipeDirection direction;
  final double size;

  @override
  Widget build(BuildContext context) {
    String animationPath;
    switch (direction) {
      case SwipeDirection.up:
        animationPath = LottieAnimations.swipeUp;
        break;
      case SwipeDirection.left:
        animationPath = LottieAnimations.swipeLeft;
        break;
      case SwipeDirection.right:
        animationPath = LottieAnimations.swipeRight;
        break;
    }

    return LottieAnimation.asset(
      animationPath,
      width: size,
      height: size,
    );
  }
}

enum SwipeDirection { up, left, right }

/// Pulsing Animation Wrapper
///
/// Wraps any widget with a pulsing scale animation.
/// Useful for drawing attention to interactive elements.
class PulsingAnimation extends StatefulWidget {
  const PulsingAnimation({
    required this.child,
    super.key,
    this.duration = const Duration(milliseconds: 1000),
    this.minScale = 0.95,
    this.maxScale = 1.05,
  });

  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  @override
  State<PulsingAnimation> createState() => _PulsingAnimationState();
}

class _PulsingAnimationState extends State<PulsingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

