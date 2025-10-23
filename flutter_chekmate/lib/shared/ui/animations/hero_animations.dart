import 'package:flutter/material.dart';

/// Hero Animations
///
/// Provides helper widgets and utilities for Hero animations.
/// Hero animations create smooth transitions for shared elements between screens.
///
/// Usage:
/// ```dart
/// // Source screen
/// AppHero(
///   tag: 'profile-${user.id}',
///   child: CircleAvatar(backgroundImage: NetworkImage(user.avatar)),
/// )
///
/// // Destination screen
/// AppHero(
///   tag: 'profile-${user.id}',
///   child: Image.network(user.avatar),
/// )
/// ```

/// App Hero Widget
///
/// Wrapper around Hero with sensible defaults and custom flight shuttle builder.
class AppHero extends StatelessWidget {
  const AppHero({
    required this.tag,
    required this.child,
    super.key,
    this.flightShuttleBuilder,
    this.placeholderBuilder,
    this.transitionOnUserGestures = false,
    this.createRectTween,
  });

  final Object tag;
  final Widget child;
  final HeroFlightShuttleBuilder? flightShuttleBuilder;
  final HeroPlaceholderBuilder? placeholderBuilder;
  final bool transitionOnUserGestures;
  final CreateRectTween? createRectTween;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder:
          flightShuttleBuilder ?? _defaultFlightShuttleBuilder,
      placeholderBuilder: placeholderBuilder,
      transitionOnUserGestures: transitionOnUserGestures,
      createRectTween: createRectTween,
      child: child,
    );
  }

  /// Default flight shuttle builder with fade transition
  static Widget _defaultFlightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return DefaultTextStyle(
      style: DefaultTextStyle.of(toHeroContext).style,
      child: toHeroContext.widget,
    );
  }
}

/// Hero Image Widget
///
/// Specialized Hero for images with smooth transitions.
class HeroImage extends StatelessWidget {
  const HeroImage({
    required this.tag,
    required this.imageUrl,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final Object tag;
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    Widget image = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: const Icon(Icons.image, color: Colors.grey),
        );
      },
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return AppHero(
      tag: tag,
      child: image,
    );
  }
}

/// Hero Avatar Widget
///
/// Specialized Hero for circular avatars.
class HeroAvatar extends StatelessWidget {
  const HeroAvatar({
    required this.tag,
    required this.imageUrl,
    super.key,
    this.radius = 20.0,
    this.name,
  });

  final Object tag;
  final String imageUrl;
  final double radius;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return AppHero(
      tag: tag,
      child: CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl),
        onBackgroundImageError: (exception, stackTrace) {
          // Handle error
        },
        child: name != null
            ? Text(
                name!.isNotEmpty ? name![0].toUpperCase() : '',
                style: TextStyle(
                  fontSize: radius * 0.8,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
    );
  }
}

/// Hero Card Widget
///
/// Specialized Hero for cards with custom flight animation.
class HeroCard extends StatelessWidget {
  const HeroCard({
    required this.tag,
    required this.child,
    super.key,
    this.elevation = 2.0,
    this.borderRadius,
    this.color,
  });

  final Object tag;
  final Widget child;
  final double elevation;
  final BorderRadius? borderRadius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AppHero(
      tag: tag,
      flightShuttleBuilder: _cardFlightShuttleBuilder,
      child: Card(
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
        color: color,
        child: child,
      ),
    );
  }

  /// Custom flight shuttle builder for cards
  static Widget _cardFlightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.95,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
      ),
      child: DefaultTextStyle(
        style: DefaultTextStyle.of(toHeroContext).style,
        child: toHeroContext.widget,
      ),
    );
  }
}

/// Hero Icon Widget
///
/// Specialized Hero for icons with rotation animation.
class HeroIcon extends StatelessWidget {
  const HeroIcon({
    required this.tag,
    required this.icon,
    super.key,
    this.size = 24.0,
    this.color,
  });

  final Object tag;
  final IconData icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AppHero(
      tag: tag,
      flightShuttleBuilder: _iconFlightShuttleBuilder,
      child: Icon(
        icon,
        size: size,
        color: color,
      ),
    );
  }

  /// Custom flight shuttle builder for icons with rotation
  static Widget _iconFlightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return RotationTransition(
      turns: Tween<double>(
        begin: 0.0,
        end: 0.25,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
      ),
      child: DefaultTextStyle(
        style: DefaultTextStyle.of(toHeroContext).style,
        child: toHeroContext.widget,
      ),
    );
  }
}

/// Hero Text Widget
///
/// Specialized Hero for text with smooth font size transitions.
class HeroText extends StatelessWidget {
  const HeroText({
    required this.tag,
    required this.text,
    super.key,
    this.style,
  });

  final Object tag;
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return AppHero(
      tag: tag,
      flightShuttleBuilder: _textFlightShuttleBuilder,
      child: Text(
        text,
        style: style,
      ),
    );
  }

  /// Custom flight shuttle builder for text
  static Widget _textFlightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final fromStyle = DefaultTextStyle.of(fromHeroContext).style;
    final toStyle = DefaultTextStyle.of(toHeroContext).style;

    return DefaultTextStyle(
      style: TextStyle.lerp(fromStyle, toStyle, animation.value)!,
      child: toHeroContext.widget,
    );
  }
}

/// Hero Tag Generator
///
/// Utility class for generating unique hero tags.
class HeroTags {
  /// Generate tag for user avatar
  static String userAvatar(String userId) => 'user-avatar-$userId';

  /// Generate tag for post image
  static String postImage(String postId, [int index = 0]) =>
      'post-image-$postId-$index';

  /// Generate tag for story
  static String story(String storyId) => 'story-$storyId';

  /// Generate tag for profile header
  static String profileHeader(String userId) => 'profile-header-$userId';

  /// Generate tag for profile photo
  static String profilePhoto(String userId, int index) =>
      'profile-photo-$userId-$index';

  /// Generate tag for message avatar
  static String messageAvatar(String userId) => 'message-avatar-$userId';

  /// Generate tag for notification icon
  static String notificationIcon(String notificationId) =>
      'notification-icon-$notificationId';
}
