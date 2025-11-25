import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';

/// Permission Service
/// Handles app permissions using permission_handler package
class PermissionService {
  PermissionService();

  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      return _isGranted(status);
    } catch (e) {
      return false;
    }
  }

  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return _isGranted(status);
    } catch (e) {
      return false;
    }
  }

  /// Request storage permission
  Future<bool> requestStoragePermission() async {
    try {
      final permission = Platform.isAndroid
          ? Permission.storage
          : Permission.photos;
      final status = await permission.request();
      return _isGranted(status);
    } catch (e) {
      return false;
    }
  }

  /// Request notification permission
  Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      return _isGranted(status);
    } catch (e) {
      return false;
    }
  }

  /// Request multiple permissions at once
  Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
    List<Permission> permissions,
  ) async {
    try {
      final Map<Permission, PermissionStatus> results = {};
      for (final permission in permissions) {
        final status = await permission.request();
        results[permission] = status;
      }
      return results;
    } catch (e) {
      return {};
    }
  }

  /// Check if microphone permission is granted
  Future<bool> hasMicrophonePermission() async {
    try {
      final status = await Permission.microphone.status;
      return _isGranted(status);
    } catch (e) {
      return false;
    }
  }

  /// Check if camera permission is granted
  Future<bool> hasCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      return _isGranted(status);
    } catch (e) {
      return false;
    }
  }

  /// Check if storage permission is granted
  Future<bool> hasStoragePermission() async {
    try {
      final permission = Platform.isAndroid
          ? Permission.storage
          : Permission.photos;
      final status = await permission.status;
      return _isGranted(status);
    } catch (e) {
      return false;
    }
  }

  /// Check if notification permission is granted
  Future<bool> hasNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      return _isGranted(status);
    } catch (e) {
      return false;
    }
  }

  /// Get permission status for a specific permission
  Future<PermissionStatus> getPermissionStatus(Permission permission) async {
    try {
      return await permission.status;
    } catch (e) {
      return PermissionStatus.denied;
    }
  }

  /// Check if rationale should be shown for a permission
  Future<bool> shouldShowRationale(Permission permission) async {
    try {
      return await permission.shouldShowRequestRationale;
    } catch (e) {
      return false;
    }
  }

  /// Open app settings
  Future<bool> openSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      return false;
    }
  }

  /// Helper method to check if permission status is granted
  bool _isGranted(PermissionStatus status) {
    return status == PermissionStatus.granted ||
           status == PermissionStatus.limited;
  }
}
