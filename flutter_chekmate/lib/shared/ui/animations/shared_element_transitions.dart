import 'package:flutter/material.dart';

/// Shared Element Transitions - Shared element transition utilities
///
/// Provides utilities for shared element transitions in the dating experience platform.
///
/// Date: November 13, 2025

/// SharedElementTransition - Helper for creating shared element transitions
class SharedElementTransition {
  /// Creates a hero tag for shared element transitions
  static String createTag(String prefix, String id) {
    return '$prefix-$id';
  }

  /// Creates a hero tag for images
  static String imageTag(String imageId) {
    return createTag('image', imageId);
  }

  /// Creates a hero tag for avatars
  static String avatarTag(String userId) {
    return createTag('avatar', userId);
  }

  /// Creates a hero tag for cards
  static String cardTag(String cardId) {
    return createTag('card', cardId);
  }
}

/// SharedImageTransition - Image with shared element transition
class SharedImageTransition extends StatelessWidget {
  const SharedImageTransition({
    required this.tag,
    required this.image,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String tag;
  final ImageProvider image;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Hero(
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

/// SharedAvatarTransition - Avatar with shared element transition
class SharedAvatarTransition extends StatelessWidget {
  const SharedAvatarTransition({
    required this.tag,
    required this.imageUrl,
    super.key,
    this.radius = 30.0,
  });

  final String tag;
  final String imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl),
      ),
    );
  }
}

/// SharedCardTransition - Card with shared element transition
class SharedCardTransition extends StatelessWidget {
  const SharedCardTransition({
    required this.tag,
    required this.child,
    super.key,
    this.elevation = 2.0,
  });

  final String tag;
  final Widget child;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Card(
        elevation: elevation,
        child: child,
      ),
    );
  }
}

