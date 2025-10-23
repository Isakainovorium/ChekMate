import 'package:flutter/material.dart';

/// AppAspectRatio - Aspect ratio container utility for responsive design
class AppAspectRatio extends StatelessWidget {
  const AppAspectRatio({
    required this.aspectRatio,
    required this.child,
    super.key,
  });

  /// Creates a 16:9 aspect ratio container
  const AppAspectRatio.video({
    required this.child,
    super.key,
  }) : aspectRatio = 16 / 9;

  /// Creates a 4:3 aspect ratio container
  const AppAspectRatio.photo({
    required this.child,
    super.key,
  }) : aspectRatio = 4 / 3;

  /// Creates a 1:1 square aspect ratio container
  const AppAspectRatio.square({
    required this.child,
    super.key,
  }) : aspectRatio = 1.0;

  /// Creates a golden ratio container (1.618:1)
  const AppAspectRatio.golden({
    required this.child,
    super.key,
  }) : aspectRatio = 1.618;

  /// Creates a 3:2 aspect ratio container (common for photos)
  const AppAspectRatio.photo32({
    required this.child,
    super.key,
  }) : aspectRatio = 3 / 2;

  /// Creates a 21:9 ultrawide aspect ratio container
  const AppAspectRatio.ultrawide({
    required this.child,
    super.key,
  }) : aspectRatio = 21 / 9;

  final double aspectRatio;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: child,
    );
  }
}

/// AppResponsiveAspectRatio - Aspect ratio that adapts to screen size
class AppResponsiveAspectRatio extends StatelessWidget {
  const AppResponsiveAspectRatio({
    required this.child,
    super.key,
    this.mobileAspectRatio = 16 / 9,
    this.tabletAspectRatio = 4 / 3,
    this.desktopAspectRatio = 21 / 9,
    this.mobileBreakpoint = 600,
    this.tabletBreakpoint = 1024,
  });

  final Widget child;
  final double mobileAspectRatio;
  final double tabletAspectRatio;
  final double desktopAspectRatio;
  final double mobileBreakpoint;
  final double tabletBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        double aspectRatio;
        if (width < mobileBreakpoint) {
          aspectRatio = mobileAspectRatio;
        } else if (width < tabletBreakpoint) {
          aspectRatio = tabletAspectRatio;
        } else {
          aspectRatio = desktopAspectRatio;
        }

        return AspectRatio(
          aspectRatio: aspectRatio,
          child: child,
        );
      },
    );
  }
}

/// AppConstrainedAspectRatio - Aspect ratio with min/max constraints
class AppConstrainedAspectRatio extends StatelessWidget {
  const AppConstrainedAspectRatio({
    required this.aspectRatio,
    required this.child,
    super.key,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
  });

  final double aspectRatio;
  final Widget child;
  final double? minWidth;
  final double? maxWidth;
  final double? minHeight;
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minWidth ?? 0,
        maxWidth: maxWidth ?? double.infinity,
        minHeight: minHeight ?? 0,
        maxHeight: maxHeight ?? double.infinity,
      ),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: child,
      ),
    );
  }
}

/// AppFlexibleAspectRatio - Aspect ratio that can flex within constraints
class AppFlexibleAspectRatio extends StatelessWidget {
  const AppFlexibleAspectRatio({
    required this.preferredAspectRatio,
    required this.child,
    super.key,
    this.minAspectRatio,
    this.maxAspectRatio,
    this.flex = 1,
  });

  final double preferredAspectRatio;
  final Widget child;
  final double? minAspectRatio;
  final double? maxAspectRatio;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: flex,
      child: LayoutBuilder(
        builder: (context, constraints) {
          var aspectRatio = preferredAspectRatio;

          // Calculate what the aspect ratio would be with current constraints
          if (constraints.hasBoundedWidth && constraints.hasBoundedHeight) {
            final constraintRatio =
                constraints.maxWidth / constraints.maxHeight;

            // Clamp to min/max if specified
            if (minAspectRatio != null && constraintRatio < minAspectRatio!) {
              aspectRatio = minAspectRatio!;
            } else if (maxAspectRatio != null &&
                constraintRatio > maxAspectRatio!) {
              aspectRatio = maxAspectRatio!;
            } else {
              aspectRatio = constraintRatio;
            }
          }

          return AspectRatio(
            aspectRatio: aspectRatio,
            child: child,
          );
        },
      ),
    );
  }
}

/// Utility class for common aspect ratios
class AppAspectRatios {
  AppAspectRatios._();

  // Video formats
  static const double video16x9 = 16 / 9;
  static const double video4x3 = 4 / 3;
  static const double video21x9 = 21 / 9;
  static const double videoVertical9x16 = 9 / 16;

  // Photo formats
  static const double photo3x2 = 3 / 2;
  static const double photo2x3 = 2 / 3;
  static const double photoSquare = 1.0;
  static const double photoPortrait3x4 = 3 / 4;
  static const double photoLandscape4x3 = 4 / 3;

  // Design ratios
  static const double golden = 1.618;
  static const double goldenInverse = 1 / 1.618;
  static const double silver = 1.414;

  // Social media formats
  static const double instagramSquare = 1.0;
  static const double instagramPortrait4x5 = 4 / 5;
  static const double instagramLandscape1_91x1 = 1.91;
  static const double twitterHeader3x1 = 3 / 1;
  static const double facebookCover820x312 = 820 / 312;

  // Screen formats
  static const double mobile9x16 = 9 / 16;
  static const double tablet4x3 = 4 / 3;
  static const double desktop16x9 = 16 / 9;
  static const double ultrawide21x9 = 21 / 9;

  // Card formats
  static const double creditCard = 85.60 / 53.98; // ISO/IEC 7810 ID-1
  static const double businessCard = 3.5 / 2.0;
  static const double postcard = 6 / 4;

  /// Get aspect ratio by name
  static double? getByName(String name) {
    switch (name.toLowerCase()) {
      case 'video':
      case '16:9':
        return video16x9;
      case 'photo':
      case '4:3':
        return video4x3;
      case 'square':
      case '1:1':
        return photoSquare;
      case 'golden':
        return golden;
      case 'ultrawide':
      case '21:9':
        return video21x9;
      case 'portrait':
      case '9:16':
        return videoVertical9x16;
      case '3:2':
        return photo3x2;
      case '2:3':
        return photo2x3;
      default:
        return null;
    }
  }

  /// Get all available aspect ratios
  static Map<String, double> get all => {
        'Video 16:9': video16x9,
        'Video 4:3': video4x3,
        'Video 21:9': video21x9,
        'Portrait 9:16': videoVertical9x16,
        'Photo 3:2': photo3x2,
        'Photo 2:3': photo2x3,
        'Square 1:1': photoSquare,
        'Portrait 3:4': photoPortrait3x4,
        'Golden Ratio': golden,
        'Golden Inverse': goldenInverse,
        'Silver Ratio': silver,
        'Instagram Square': instagramSquare,
        'Instagram Portrait': instagramPortrait4x5,
        'Instagram Landscape': instagramLandscape1_91x1,
        'Twitter Header': twitterHeader3x1,
        'Facebook Cover': facebookCover820x312,
        'Credit Card': creditCard,
        'Business Card': businessCard,
        'Postcard': postcard,
      };
}
