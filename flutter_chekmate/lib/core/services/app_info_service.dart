import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// AppInfoService - Core Service for App and Device Information
///
/// Provides access to app metadata and device information.
/// Useful for analytics, debugging, and support.
///
/// Features:
/// - App version and build number
/// - Package name and app name
/// - Device model and OS version
/// - Platform information
/// - Device identifiers
///
/// Usage:
/// ```dart
/// await AppInfoService.initialize();
/// final version = AppInfoService.appVersion;
/// final deviceModel = AppInfoService.deviceModel;
/// ```
class AppInfoService {
  static PackageInfo? _packageInfo;
  static AndroidDeviceInfo? _androidInfo;
  static IosDeviceInfo? _iosInfo;
  static bool _initialized = false;

  /// Initialize the service
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      _packageInfo = await PackageInfo.fromPlatform();

      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        _androidInfo = await deviceInfo.androidInfo;
      } else if (Platform.isIOS) {
        _iosInfo = await deviceInfo.iosInfo;
      }

      _initialized = true;
    } catch (e) {
      throw AppInfoException('Failed to initialize AppInfoService: $e');
    }
  }

  /// Ensure service is initialized
  static void _ensureInitialized() {
    if (!_initialized) {
      throw const AppInfoException(
        'AppInfoService not initialized. Call initialize() first.',
      );
    }
  }

  // ========== APP INFORMATION ==========

  /// Get app name
  static String get appName {
    _ensureInitialized();
    return _packageInfo?.appName ?? 'Unknown';
  }

  /// Get package name (e.g., com.example.app)
  static String get packageName {
    _ensureInitialized();
    return _packageInfo?.packageName ?? 'Unknown';
  }

  /// Get app version (e.g., 1.0.0)
  static String get appVersion {
    _ensureInitialized();
    return _packageInfo?.version ?? 'Unknown';
  }

  /// Get build number (e.g., 1)
  static String get buildNumber {
    _ensureInitialized();
    return _packageInfo?.buildNumber ?? 'Unknown';
  }

  /// Get full version string (e.g., 1.0.0 (1))
  static String get fullVersion {
    return '$appVersion ($buildNumber)';
  }

  /// Get installer store (e.g., com.android.vending for Play Store)
  static String? get installerStore {
    _ensureInitialized();
    return _packageInfo?.installerStore;
  }

  // ========== DEVICE INFORMATION ==========

  /// Get device model
  static String get deviceModel {
    _ensureInitialized();
    if (Platform.isAndroid) {
      return _androidInfo?.model ?? 'Unknown';
    } else if (Platform.isIOS) {
      return _iosInfo?.model ?? 'Unknown';
    }
    return 'Unknown';
  }

  /// Get device manufacturer
  static String get deviceManufacturer {
    _ensureInitialized();
    if (Platform.isAndroid) {
      return _androidInfo?.manufacturer ?? 'Unknown';
    } else if (Platform.isIOS) {
      return 'Apple';
    }
    return 'Unknown';
  }

  /// Get device brand
  static String get deviceBrand {
    _ensureInitialized();
    if (Platform.isAndroid) {
      return _androidInfo?.brand ?? 'Unknown';
    } else if (Platform.isIOS) {
      return 'Apple';
    }
    return 'Unknown';
  }

  /// Get OS version
  static String get osVersion {
    _ensureInitialized();
    if (Platform.isAndroid) {
      return _androidInfo?.version.release ?? 'Unknown';
    } else if (Platform.isIOS) {
      return _iosInfo?.systemVersion ?? 'Unknown';
    }
    return 'Unknown';
  }

  /// Get OS name
  static String get osName {
    if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else if (Platform.isMacOS) {
      return 'macOS';
    } else if (Platform.isWindows) {
      return 'Windows';
    } else if (Platform.isLinux) {
      return 'Linux';
    }
    return 'Unknown';
  }

  /// Get platform name
  static String get platform {
    return Platform.operatingSystem;
  }

  /// Check if running on Android
  static bool get isAndroid => Platform.isAndroid;

  /// Check if running on iOS
  static bool get isIOS => Platform.isIOS;

  /// Check if running on physical device
  static bool get isPhysicalDevice {
    _ensureInitialized();
    if (Platform.isAndroid) {
      return _androidInfo?.isPhysicalDevice ?? false;
    } else if (Platform.isIOS) {
      return _iosInfo?.isPhysicalDevice ?? false;
    }
    return false;
  }

  // ========== ANDROID-SPECIFIC ==========

  /// Get Android SDK version (Android only)
  static int? get androidSdkVersion {
    _ensureInitialized();
    return _androidInfo?.version.sdkInt;
  }

  /// Get Android device ID (Android only)
  static String? get androidId {
    _ensureInitialized();
    return _androidInfo?.id;
  }

  /// Get Android security patch (Android only)
  static String? get androidSecurityPatch {
    _ensureInitialized();
    return _androidInfo?.version.securityPatch;
  }

  // ========== iOS-SPECIFIC ==========

  /// Get iOS device name (iOS only)
  static String? get iosDeviceName {
    _ensureInitialized();
    return _iosInfo?.name;
  }

  /// Get iOS system name (iOS only)
  static String? get iosSystemName {
    _ensureInitialized();
    return _iosInfo?.systemName;
  }

  /// Get iOS identifier for vendor (iOS only)
  static String? get iosIdentifierForVendor {
    _ensureInitialized();
    return _iosInfo?.identifierForVendor;
  }

  /// Get iOS localized model (iOS only)
  static String? get iosLocalizedModel {
    _ensureInitialized();
    return _iosInfo?.localizedModel;
  }

  // ========== ANALYTICS HELPERS ==========

  /// Get device info for analytics
  static Map<String, dynamic> getAnalyticsInfo() {
    _ensureInitialized();
    return {
      'app_name': appName,
      'app_version': appVersion,
      'build_number': buildNumber,
      'package_name': packageName,
      'device_model': deviceModel,
      'device_manufacturer': deviceManufacturer,
      'os_name': osName,
      'os_version': osVersion,
      'platform': platform,
      'is_physical_device': isPhysicalDevice,
    };
  }

  /// Get device info string for support
  static String getSupportInfo() {
    _ensureInitialized();
    return '''
App: $appName
Version: $fullVersion
Package: $packageName

Device: $deviceManufacturer $deviceModel
OS: $osName $osVersion
Platform: $platform
Physical Device: $isPhysicalDevice
''';
  }

  /// Get all device info as map
  static Map<String, dynamic> getAllInfo() {
    _ensureInitialized();
    final info = <String, dynamic>{
      'app': {
        'name': appName,
        'version': appVersion,
        'build_number': buildNumber,
        'package_name': packageName,
        'installer_store': installerStore,
      },
      'device': {
        'model': deviceModel,
        'manufacturer': deviceManufacturer,
        'brand': deviceBrand,
        'is_physical': isPhysicalDevice,
      },
      'os': {
        'name': osName,
        'version': osVersion,
        'platform': platform,
      },
    };

    if (Platform.isAndroid && _androidInfo != null) {
      info['android'] = {
        'sdk_version': androidSdkVersion,
        'id': androidId,
        'security_patch': androidSecurityPatch,
      };
    }

    if (Platform.isIOS && _iosInfo != null) {
      info['ios'] = {
        'device_name': iosDeviceName,
        'system_name': iosSystemName,
        'identifier_for_vendor': iosIdentifierForVendor,
        'localized_model': iosLocalizedModel,
      };
    }

    return info;
  }
}

/// AppInfoException - Custom exception for app info errors
class AppInfoException implements Exception {
  const AppInfoException(this.message);
  final String message;

  @override
  String toString() => 'AppInfoException: $message';
}
