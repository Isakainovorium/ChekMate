import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Lottie Animations - Lottie animation wrapper widgets
///
/// Provides Lottie animation widgets for the dating experience platform.
///
/// Date: November 13, 2025

/// LottieAnimation - Generic Lottie animation widget
class LottieAnimation extends StatelessWidget {
  const LottieAnimation({
    required this.assetPath,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.repeat = true,
    this.reverse = false,
    this.animate = true,
    this.onLoaded,
  });

  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool repeat;
  final bool reverse;
  final bool animate;
  final void Function(LottieComposition)? onLoaded;

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      repeat: repeat,
      reverse: reverse,
      animate: animate,
      onLoaded: onLoaded,
      errorBuilder: (context, error, stackTrace) {
        // Graceful fallback if animation fails to load
        return SizedBox(
          width: width ?? 100,
          height: height ?? 100,
          child: const Icon(Icons.animation, size: 48),
        );
      },
    );
  }
}

/// LottieLoading - Loading animation using Lottie
class LottieLoading extends StatelessWidget {
  const LottieLoading({
    super.key,
    this.size = 100.0,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return LottieAnimation(
      assetPath: 'assets/animations/loading.json',
      width: size,
      height: size,
    );
  }
}

/// LottieSuccess - Success animation using Lottie
class LottieSuccess extends StatelessWidget {
  const LottieSuccess({
    super.key,
    this.size = 100.0,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return LottieAnimation(
      assetPath: 'assets/animations/success.json',
      width: size,
      height: size,
      repeat: false,
    );
  }
}

/// LottieError - Error animation using Lottie
class LottieError extends StatelessWidget {
  const LottieError({
    super.key,
    this.size = 100.0,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return LottieAnimation(
      assetPath: 'assets/animations/error.json',
      width: size,
      height: size,
      repeat: false,
    );
  }
}

