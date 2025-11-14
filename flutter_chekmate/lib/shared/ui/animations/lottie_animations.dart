import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart'; // Uncomment when lottie package is added

/// Lottie Animations - Lottie animation wrapper widgets
///
/// Provides Lottie animation widgets for the dating experience platform.
/// Falls back to Material icons when Lottie package is not available.
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
  });

  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool repeat;
  final bool reverse;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    // When lottie package is available, uncomment:
    // return Lottie.asset(
    //   assetPath,
    //   width: width,
    //   height: height,
    //   fit: fit,
    //   repeat: repeat,
    //   reverse: reverse,
    //   animate: animate,
    // );

    // Fallback to loading indicator
    return SizedBox(
      width: width ?? 100,
      height: height ?? 100,
      child: const CircularProgressIndicator(),
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

