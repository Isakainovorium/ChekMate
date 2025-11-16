import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// App Info Service Exception
class AppInfoException implements Exception {
  const AppInfoException(this.message);

  final String message;

  @override
  String toString() => 'AppInfoException: $message';
}

/// App Info Service
/// Provides access to app and device information using platform plugins
class AppInfoService {
  AppInfoService._();

  static PackageInfo? _packageInfo;
  static AndroidDeviceInfo? _androidInfo;
  static IosDeviceInfo? _iosInfo;

  /// Initialize the service by loading app and device info
  static Future<void> initialize() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        _androidInfo = await deviceInfo.androidInfo;
      } else if (Platform.isIOS) {
        _iosInfo = await deviceInfo.iosInfo;
      }
    } catch (e) {
      throw AppInfoException('Failed to initialize app info service: $e');
    }
  }

  /// Get app name
  static String get appName {
    _ensureInitialized();
    return _packageInfo!.appName;
  }

  /// Get package name
  static String get packageName {
    _ensureInitialized();
    return _packageInfo!.packageName;
  }

  /// Get app version
  static String get appVersion {
    _ensureInitialized();
    return _packageInfo!.version;
  }

  /// Get build number
  static String get buildNumber {
    _ensureInitialized();
    return _packageInfo!.buildNumber;
  }

  /// Get full version (version + build)
  static String get fullVersion {
    _ensureInitialized();
    return '${_packageInfo!.version}+${_packageInfo!.buildNumber}';
  }

  /// Get installer store (Android only) - Not available in device_info_plus
  static String? get installerStore {
    _ensureInitialized();
    return null; // Not supported by device_info_plus
  }

  /// Get device model
  static String get deviceModel {
    _ensureInitialized();
    if (Platform.isAndroid) {
      return _androidInfo!.model;
    } else if (Platform.isIOS) {
      return _iosInfo!.model;
    }
    return 'Unknown';
  }

  /// Get device manufacturer
  static String get deviceManufacturer {
    _ensureInitialized();
    if (Platform.isAndroid) {
      return _androidInfo!.manufacturer;
    } else if (Platform.isIOS) {
      return 'Apple';
    }
    return 'Unknown';
  }

  /// Get device brand
  static String get deviceBrand {
    _ensureInitialized();
    if (Platform.isAndroid) {
      return _androidInfo!.brand;
    } else if (Platform.isIOS) {
      return 'Apple';
    }
    return 'Unknown';
  }

  /// Get OS version
  static String get osVersion {
    _ensureInitialized();
    if (Platform.isAndroid) {
      return _androidInfo!.version.release;
    } else if (Platform.isIOS) {
      return _iosInfo!.systemVersion;
    }
    return 'Unknown';
  }

  /// Get OS name
  static String get osName {
    _ensureInitialized();
    if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else if (Platform.isWindows) {
      return 'Windows';
    } else if (Platform.isMacOS) {
      return 'macOS';
    } else if (Platform.isLinux) {
      return 'Linux';
    }
    return 'Unknown';
  }

  /// Get platform name
  static String get platform {
    if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isWindows) {
      return 'windows';
    } else if (Platform.isMacOS) {
      return 'macos';
    } else if (Platform.isLinux) {
      return 'linux';
    } else if (Platform.isFuchsia) {
      return 'fuchsia';
    }
    return 'unknown';
  }

  /// Check if device is physical
  static bool get isPhysicalDevice {
    _ensureInitialized();
    if (Platform.isAndroid) {
      return _androidInfo!.isPhysicalDevice;
    } else if (Platform.isIOS) {
      return _iosInfo!.isPhysicalDevice;
    }
    return true;
  }

  /// Get Android SDK version
  static int? get androidSdkVersion {
    _ensureInitialized();
    return _androidInfo?.version.sdkInt;
  }

  /// Get Android ID
  static String? get androidId {
    _ensureInitialized();
    return _androidInfo?.id;
  }

  /// Get Android security patch level
  static String? get androidSecurityPatch {
    _ensureInitialized();
    return _androidInfo?.version.securityPatch;
  }

  /// Get iOS device name
  static String? get iosDeviceName {
    _ensureInitialized();
    return _iosInfo?.name;
  }

  /// Get iOS system name
  static String? get iosSystemName {
    _ensureInitialized();
    return _iosInfo?.systemName;
  }

  /// Get iOS identifier for vendor
  static String? get iosIdentifierForVendor {
    _ensureInitialized();
    return _iosInfo?.identifierForVendor;
  }

  /// Get iOS localized model
  static String? get iosLocalizedModel {
    _ensureInitialized();
    return _iosInfo?.localizedModel;
  }

  /// Get analytics info as map
  static Map<String, dynamic> getAnalyticsInfo() {
    _ensureInitialized();
    return {
      'appName': appName,
      'appVersion': appVersion,
      'buildNumber': buildNumber,
      'deviceModel': deviceModel,
      'osVersion': osVersion,
      'platform': platform,
      'isPhysicalDevice': isPhysicalDevice,
    };
  }

  /// Get support info as formatted string
  static String getSupportInfo() {
    _ensureInitialized();
    final buffer = StringBuffer();

    buffer.writeln('App: $appName');
    buffer.writeln('Version: $fullVersion');
    buffer.writeln('Package: $packageName');

    buffer.writeln('Device: $deviceModel');
    buffer.writeln('Manufacturer: $deviceManufacturer');
    buffer.writeln('Brand: $deviceBrand');
    buffer.writeln('OS: $osName $osVersion');
    buffer.writeln('Platform: $platform');
    buffer.writeln('Physical Device: $isPhysicalDevice');

    if (Platform.isAndroid && _androidInfo != null) {
      buffer.writeln('Android ID: ${androidId ?? 'N/A'}');
      buffer.writeln('SDK Version: ${androidSdkVersion ?? 'N/A'}');
      buffer.writeln('Security Patch: ${androidSecurityPatch ?? 'N/A'}');
      buffer.writeln('Installer Store: ${installerStore ?? 'N/A'}');
    } else if (Platform.isIOS && _iosInfo != null) {
      buffer.writeln('Device Name: ${iosDeviceName ?? 'N/A'}');
      buffer.writeln('System Name: ${iosSystemName ?? 'N/A'}');
      buffer.writeln('Identifier: ${iosIdentifierForVendor ?? 'N/A'}');
      buffer.writeln('Localized Model: ${iosLocalizedModel ?? 'N/A'}');
    }

    return buffer.toString();
  }

  /// Get all info as comprehensive map
  static Map<String, dynamic> getAllInfo() {
    _ensureInitialized();
    final info = <String, dynamic>{};

    // App info
    info['appName'] = appName;
    info['packageName'] = packageName;
    info['appVersion'] = appVersion;
    info['buildNumber'] = buildNumber;
    info['fullVersion'] = fullVersion;
    info['installerStore'] = installerStore;

    // Device info
    info['deviceModel'] = deviceModel;
    info['deviceManufacturer'] = deviceManufacturer;
    info['deviceBrand'] = deviceBrand;
    info['osVersion'] = osVersion;
    info['osName'] = osName;
    info['platform'] = platform;
    info['isPhysicalDevice'] = isPhysicalDevice;

    // Platform-specific info
    if (Platform.isAndroid) {
      info['androidSdkVersion'] = androidSdkVersion;
      info['androidId'] = androidId;
      info['androidSecurityPatch'] = androidSecurityPatch;
    } else if (Platform.isIOS) {
      info['iosDeviceName'] = iosDeviceName;
      info['iosSystemName'] = iosSystemName;
      info['iosIdentifierForVendor'] = iosIdentifierForVendor;
      info['iosLocalizedModel'] = iosLocalizedModel;
    }

    return info;
  }

  /// Ensure service is initialized
  static void _ensureInitialized() {
    if (_packageInfo == null) {
      throw const AppInfoException(
        'AppInfoService not initialized. Call initialize() first.',
      );
    }
  }
}
