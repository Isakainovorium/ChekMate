import 'package:flutter/material.dart';

/// Hero Animations - Hero widget animations for shared element transitions
///
/// Provides hero animations for smooth transitions between screens
/// in the dating experience platform.
///
/// Date: November 13, 2025

/// AppHero - Wrapper for Hero widget with consistent styling
class AppHero extends StatelessWidget {
  const AppHero({
    required this.tag,
    required this.child,
    super.key,
    this.flightShuttleBuilder,
    this.placeholderBuilder,
    this.transitionOnUserGestures = false,
  });

  final Object tag;
  final Widget child;
  final HeroFlightShuttleBuilder? flightShuttleBuilder;
  final HeroPlaceholderBuilder? placeholderBuilder;
  final bool transitionOnUserGestures;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: child,
      flightShuttleBuilder: flightShuttleBuilder,
      placeholderBuilder: placeholderBuilder,
      transitionOnUserGestures: transitionOnUserGestures,
    );
  }
}

/// HeroImage - Hero widget specifically for images
class HeroImage extends StatelessWidget {
  const HeroImage({
    required this.tag,
    required this.image,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final Object tag;
  final ImageProvider image;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return AppHero(
      tag: tag,
      child: Image(
        image: image,
        width: width,
        height: height,
        fit: fit,
      ),
    );
  }
}

/// HeroAvatar - Hero widget for avatar/profile images
class HeroAvatar extends StatelessWidget {
  const HeroAvatar({
    required this.tag,
    required this.imageUrl,
    super.key,
    this.radius = 30.0,
  });

  final Object tag;
  final String imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return AppHero(
      tag: tag,
      child: CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl),
      ),
    );
  }
}

