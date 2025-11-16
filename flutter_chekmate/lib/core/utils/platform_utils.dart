/// Platform-specific utilities for handling web vs mobile differences
///
/// This file provides helper functions to detect the current platform
/// and handle platform-specific logic throughout the app.
library;

import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';

/// Platform detection utilities
class PlatformUtils {
  /// Check if the app is running on web
  static bool get isWeb => kIsWeb;

  /// Check if the app is running on mobile (Android or iOS)
  static bool get isMobile => !kIsWeb;

  /// Check if the app is running on desktop (Windows, macOS, Linux)
  static bool get isDesktop {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  /// Check if the app is running on Android
  static bool get isAndroid {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android;
  }

  /// Check if the app is running on iOS
  static bool get isIOS {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Get a platform-specific message for camera access
  static String get cameraAccessMessage {
    if (isWeb) {
      return 'Camera access is not available on web. Please upload a photo from your device.';
    }
    return 'Allow camera access to take photos';
  }

  /// Get a platform-specific message for audio recording
  static String get audioRecordingMessage {
    if (isWeb) {
      return 'Audio recording is not available on web. Please upload an audio file from your device.';
    }
    return 'Allow microphone access to record audio';
  }

  /// Get a platform-specific message for push notifications
  static String get pushNotificationMessage {
    if (isWeb) {
      if (isIOS) {
        return 'Push notifications are not supported on iOS Safari. Please check the app manually for updates.';
      }
      return 'Enable push notifications to receive updates (Android/Desktop only)';
    }
    return 'Enable push notifications to receive updates';
  }

  /// Check if camera is supported on current platform
  static bool get isCameraSupported => !isWeb;

  /// Check if audio recording is supported on current platform
  static bool get isAudioRecordingSupported => !isWeb;

  /// Check if push notifications are supported on current platform
  static bool get isPushNotificationsSupported {
    if (isWeb) {
      // Web push notifications only work on Android/Desktop, not iOS
      return !isIOS;
    }
    return true;
  }

  /// Check if background sync is supported on current platform
  static bool get isBackgroundSyncSupported => !isWeb;

  /// Get platform name for display
  static String get platformName {
    if (isWeb) return 'Web';
    if (kIsWeb) return 'Web'; // Extra check for web
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (isDesktop) {
      if (defaultTargetPlatform == TargetPlatform.windows) return 'Windows';
      if (defaultTargetPlatform == TargetPlatform.macOS) return 'macOS';
      if (defaultTargetPlatform == TargetPlatform.linux) return 'Linux';
    }
    return 'Unknown';
  }
}

/// Responsive layout utilities
class ResponsiveUtils {
  /// Check if the screen is mobile-sized (< 650px)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 650;
  }

  /// Check if the screen is tablet-sized (650px - 1100px)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 650 && width < 1100;
  }

  /// Check if the screen is desktop-sized (>= 1100px)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1100;
  }

  /// Get the number of columns for a grid based on screen size
  static int getGridColumns(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }

  /// Get the maximum width for content on large screens
  static double getMaxContentWidth(BuildContext context) {
    if (isDesktop(context)) return 1200;
    if (isTablet(context)) return 800;
    return double.infinity;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 24);
    }
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  }

  /// Get responsive font size based on screen size
  static double getResponsiveFontSize(
      BuildContext context, double baseFontSize) {
    if (isDesktop(context)) return baseFontSize * 1.1;
    if (isTablet(context)) return baseFontSize * 1.05;
    return baseFontSize;
  }
}

/// Widget for responsive layouts
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1100) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 650) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Widget for centering content on large screens
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMaxWidth =
        maxWidth ?? ResponsiveUtils.getMaxContentWidth(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        child: child,
      ),
    );
  }
}

/// Show a platform-specific dialog explaining feature limitations
Future<void> showPlatformLimitationDialog(
  BuildContext context, {
  required String feature,
  required String limitation,
  String? workaround,
}) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('$feature Not Available'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(limitation),
          if (workaround != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Workaround:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(workaround),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

/// Show a snackbar with platform-specific information
void showPlatformInfo(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ),
  );
}
