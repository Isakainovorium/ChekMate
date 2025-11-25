import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_chekmate/core/domain/entities/location_entity.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Location Service Exception
class LocationServiceException implements Exception {
  const LocationServiceException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() =>
      'LocationServiceException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Location Service
/// Handles location-related operations
class LocationService {
  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      developer.log(
        'Failed to check location service status',
        name: 'LocationService',
        error: e,
      );
      return false;
    }
  }

  /// Check location permission status
  static Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (e) {
      developer.log(
        'Failed to check location permission',
        name: 'LocationService',
        error: e,
      );
      throw const LocationServiceException(
        'Failed to check location permission',
        code: 'PERMISSION_CHECK_FAILED',
      );
    }
  }

  /// Request location permission
  static Future<LocationPermission> requestPermission() async {
    try {
      return await Geolocator.requestPermission();
    } catch (e) {
      developer.log(
        'Failed to request location permission',
        name: 'LocationService',
        error: e,
      );
      throw const LocationServiceException(
        'Failed to request location permission',
        code: 'PERMISSION_REQUEST_FAILED',
      );
    }
  }

  /// Get current location
  static Future<LocationEntity> getCurrentLocation(
      {bool includeAddress = false}) async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const LocationServiceException(
          'Location services are disabled',
          code: 'SERVICE_DISABLED',
        );
      }

      // Check permission
      LocationPermission permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          throw const LocationServiceException(
            'Location permission denied',
            code: 'PERMISSION_DENIED',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw const LocationServiceException(
          'Location permission permanently denied',
          code: 'PERMISSION_DENIED_FOREVER',
        );
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      developer.log(
        'Got current location: ${position.latitude}, ${position.longitude}',
        name: 'LocationService',
      );

      return LocationEntity(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
      );
    } on LocationServiceException {
      rethrow;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to get current location',
        name: 'LocationService',
        error: e,
        stackTrace: stackTrace,
      );
      throw LocationServiceException(
        'Failed to get current location: $e',
        code: 'LOCATION_FETCH_FAILED',
      );
    }
  }

  /// Get last known location
  static Future<LocationEntity?> getLastKnownLocation() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position == null) return null;

      return LocationEntity(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
      );
    } catch (e) {
      developer.log(
        'Failed to get last known location',
        name: 'LocationService',
        error: e,
      );
      return null;
    }
  }

  /// Get address from coordinates
  static Future<LocationEntity> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) {
        throw const LocationServiceException(
          'No address found for coordinates',
          code: 'ADDRESS_NOT_FOUND',
        );
      }

      final placemark = placemarks.first;

      return LocationEntity(
        latitude: latitude,
        longitude: longitude,
        name: placemark.name,
        address: placemark.street,
        city: placemark.locality,
        state: placemark.administrativeArea,
        country: placemark.country,
        postalCode: placemark.postalCode,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      developer.log(
        'Failed to get address from coordinates',
        name: 'LocationService',
        error: e,
      );
      throw LocationServiceException(
        'Failed to get address from coordinates: $e',
        code: 'ADDRESS_LOOKUP_FAILED',
      );
    }
  }

  /// Get coordinates from address
  static Future<List<LocationEntity>> getCoordinatesFromAddress({
    required String address,
  }) async {
    try {
      final locations = await locationFromAddress(address);

      return locations.map((location) {
        return LocationEntity(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
        );
      }).toList();
    } catch (e) {
      developer.log(
        'Failed to get coordinates from address',
        name: 'LocationService',
        error: e,
      );
      throw LocationServiceException(
        'Failed to get coordinates from address: $e',
        code: 'COORDINATES_LOOKUP_FAILED',
      );
    }
  }

  /// Get location stream for real-time updates
  static Stream<LocationEntity> getLocationStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // Minimum distance (in meters) before update
  }) {
    try {
      final positionStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          distanceFilter: distanceFilter,
        ),
      );

      return positionStream.map((position) {
        return LocationEntity(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          timestamp: position.timestamp,
        );
      });
    } catch (e, stackTrace) {
      developer.log(
        'Failed to get location stream',
        name: 'LocationService',
        error: e,
        stackTrace: stackTrace,
      );
      throw LocationServiceException(
        'Failed to get location stream: $e',
        code: 'LOCATION_STREAM_FAILED',
      );
    }
  }

  /// Calculate distance between two locations (in meters)
  static double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    try {
      return Geolocator.distanceBetween(
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude,
      );
    } catch (e) {
      developer.log(
        'Failed to calculate distance',
        name: 'LocationService',
        error: e,
      );
      return 0.0;
    }
  }

  /// Format distance for display (e.g., "1.2 km", "500 m")
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m';
    } else {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  /// Open location settings
  static Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      developer.log(
        'Failed to open location settings',
        name: 'LocationService',
        error: e,
      );
      return false;
    }
  }

  /// Open app settings
  static Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      developer.log(
        'Failed to open app settings',
        name: 'LocationService',
        error: e,
      );
      return false;
    }
  }
}
