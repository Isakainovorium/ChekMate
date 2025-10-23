import 'package:permission_handler/permission_handler.dart';

/// Service for handling app permissions (microphone, camera, storage, etc.)
///
/// This service provides a centralized way to request and check permissions
/// across iOS and Android platforms. It handles permission states including
/// denied, granted, permanently denied, and restricted.
///
/// Usage:
/// ```dart
/// final permissionService = PermissionService();
///
/// // Request microphone permission
/// final granted = await permissionService.requestMicrophonePermission();
/// if (granted) {
///   // Start recording
/// }
///
/// // Check camera permission status
/// final hasCamera = await permissionService.hasCameraPermission();
/// ```
class PermissionService {
  /// Requests microphone permission for voice recording
  ///
  /// Returns `true` if permission is granted, `false` otherwise.
  /// If permission is permanently denied, opens app settings.
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.status;

    // Already granted
    if (status.isGranted) {
      return true;
    }

    // Permanently denied - open settings
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    // Request permission
    final result = await Permission.microphone.request();

    // Handle permanently denied after request
    if (result.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return result.isGranted;
  }

  /// Requests camera permission for video recording
  ///
  /// Returns `true` if permission is granted, `false` otherwise.
  /// If permission is permanently denied, opens app settings.
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.status;

    // Already granted
    if (status.isGranted) {
      return true;
    }

    // Permanently denied - open settings
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    // Request permission
    final result = await Permission.camera.request();

    // Handle permanently denied after request
    if (result.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return result.isGranted;
  }

  /// Requests storage permission for saving files
  ///
  /// On Android 13+, this requests photos/videos/audio permissions.
  /// On iOS, this requests photo library permission.
  ///
  /// Returns `true` if permission is granted, `false` otherwise.
  Future<bool> requestStoragePermission() async {
    // On Android 13+, use granular media permissions
    // On iOS, use photos permission
    const permission = Permission.photos;

    final status = await permission.status;

    // Already granted
    if (status.isGranted) {
      return true;
    }

    // Permanently denied - open settings
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    // Request permission
    final result = await permission.request();

    // Handle permanently denied after request
    if (result.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return result.isGranted;
  }

  /// Requests multiple permissions at once
  ///
  /// Useful for requesting microphone + camera together for video calls.
  /// Returns a map of permission statuses.
  Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
    List<Permission> permissions,
  ) async {
    return permissions.request();
  }

  /// Checks if microphone permission is granted
  Future<bool> hasMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// Checks if camera permission is granted
  Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Checks if storage permission is granted
  Future<bool> hasStoragePermission() async {
    final status = await Permission.photos.status;
    return status.isGranted;
  }

  /// Checks if notification permission is granted
  Future<bool> hasNotificationPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Requests notification permission
  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    final result = await Permission.notification.request();

    if (result.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return result.isGranted;
  }

  /// Gets the current status of a permission
  Future<PermissionStatus> getPermissionStatus(Permission permission) async {
    return permission.status;
  }

  /// Checks if we should show a rationale for requesting a permission
  ///
  /// This is useful on Android to show an explanation before requesting
  /// a permission that was previously denied.
  Future<bool> shouldShowRationale(Permission permission) async {
    return permission.shouldShowRequestRationale;
  }

  /// Opens the app settings page
  ///
  /// Used when a permission is permanently denied and the user needs to
  /// manually enable it in system settings.
  Future<bool> openAppSettings() async {
    return openAppSettings();
  }

  /// Requests microphone and camera permissions together
  ///
  /// Useful for video call features that need both permissions.
  /// Returns `true` only if both permissions are granted.
  Future<bool> requestVideoCallPermissions() async {
    final statuses = await [
      Permission.microphone,
      Permission.camera,
    ].request();

    final micGranted = statuses[Permission.microphone]?.isGranted ?? false;
    final cameraGranted = statuses[Permission.camera]?.isGranted ?? false;

    // Check for permanently denied
    final micPermanentlyDenied =
        statuses[Permission.microphone]?.isPermanentlyDenied ?? false;
    final cameraPermanentlyDenied =
        statuses[Permission.camera]?.isPermanentlyDenied ?? false;

    if (micPermanentlyDenied || cameraPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return micGranted && cameraGranted;
  }

  /// Checks permission status with detailed information
  ///
  /// Returns a [PermissionCheckResult] with status and whether settings
  /// should be opened.
  Future<PermissionCheckResult> checkPermission(Permission permission) async {
    final status = await permission.status;

    return PermissionCheckResult(
      permission: permission,
      status: status,
      isGranted: status.isGranted,
      isDenied: status.isDenied,
      isPermanentlyDenied: status.isPermanentlyDenied,
      isRestricted: status.isRestricted,
      shouldOpenSettings: status.isPermanentlyDenied,
    );
  }
}

/// Result of a permission check with detailed information
class PermissionCheckResult {

  const PermissionCheckResult({
    required this.permission,
    required this.status,
    required this.isGranted,
    required this.isDenied,
    required this.isPermanentlyDenied,
    required this.isRestricted,
    required this.shouldOpenSettings,
  });
  final Permission permission;
  final PermissionStatus status;
  final bool isGranted;
  final bool isDenied;
  final bool isPermanentlyDenied;
  final bool isRestricted;
  final bool shouldOpenSettings;

  @override
  String toString() {
    return 'PermissionCheckResult('
        'permission: $permission, '
        'status: $status, '
        'isGranted: $isGranted, '
        'isDenied: $isDenied, '
        'isPermanentlyDenied: $isPermanentlyDenied, '
        'isRestricted: $isRestricted, '
        'shouldOpenSettings: $shouldOpenSettings'
        ')';
  }
}
