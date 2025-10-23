import 'package:flutter_chekmate/core/domain/entities/location_entity.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// LocationService - Core Service
///
/// Handles all location-related operations using geolocator and geocoding packages.
/// Provides current location, reverse geocoding, and forward geocoding.
///
/// Features:
/// - Get current location with permission handling
/// - Reverse geocoding (coordinates → address)
/// - Forward geocoding (address → coordinates)
/// - Location permission management
/// - Distance calculations
///
/// Clean Architecture: Core Layer (Infrastructure)
class LocationService {
  /// Get current location with permission handling
  ///
  /// Returns [LocationEntity] with current coordinates and address.
  /// Throws [LocationServiceException] if location services are disabled or permission denied.
  ///
  /// Example:
  /// ```dart
  /// final location = await LocationService.getCurrentLocation();
  /// print('Current location: ${location.displayName}');
  /// ```
  static Future<LocationEntity> getCurrentLocation({
    bool includeAddress = true,
  }) async {
    // Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceException(
        'Location services are disabled. Please enable location services.',
      );
    }

    // Check and request permission
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationServiceException(
          'Location permission denied. Please grant location permission.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationServiceException(
        'Location permission permanently denied. Please enable location permission in settings.',
      );
    }

    // Get current position
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Get address if requested
    String? address;
    String? city;
    String? country;
    String? postalCode;
    String? street;

    if (includeAddress) {
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          street = placemark.street;
          city = placemark.locality;
          country = placemark.country;
          postalCode = placemark.postalCode;

          // Build full address
          final addressParts = <String>[];
          if (placemark.street != null && placemark.street!.isNotEmpty) {
            addressParts.add(placemark.street!);
          }
          if (placemark.locality != null && placemark.locality!.isNotEmpty) {
            addressParts.add(placemark.locality!);
          }
          if (placemark.administrativeArea != null &&
              placemark.administrativeArea!.isNotEmpty) {
            addressParts.add(placemark.administrativeArea!);
          }
          if (placemark.postalCode != null &&
              placemark.postalCode!.isNotEmpty) {
            addressParts.add(placemark.postalCode!);
          }
          if (placemark.country != null && placemark.country!.isNotEmpty) {
            addressParts.add(placemark.country!);
          }

          address = addressParts.join(', ');
        }
      } on Exception {
        // Ignore geocoding errors, return location without address
      }
    }

    return LocationEntity(
      latitude: position.latitude,
      longitude: position.longitude,
      address: address,
      city: city,
      country: country,
      postalCode: postalCode,
      street: street,
    );
  }

  /// Get address from coordinates (reverse geocoding)
  ///
  /// Returns [LocationEntity] with address information for given coordinates.
  ///
  /// Example:
  /// ```dart
  /// final location = await LocationService.getAddressFromCoordinates(
  ///   latitude: 37.7749,
  ///   longitude: -122.4194,
  /// );
  /// print('Address: ${location.fullAddress}');
  /// ```
  static Future<LocationEntity> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) {
        return LocationEntity(
          latitude: latitude,
          longitude: longitude,
        );
      }

      final placemark = placemarks.first;

      // Build full address
      final addressParts = <String>[];
      if (placemark.street != null && placemark.street!.isNotEmpty) {
        addressParts.add(placemark.street!);
      }
      if (placemark.locality != null && placemark.locality!.isNotEmpty) {
        addressParts.add(placemark.locality!);
      }
      if (placemark.administrativeArea != null &&
          placemark.administrativeArea!.isNotEmpty) {
        addressParts.add(placemark.administrativeArea!);
      }
      if (placemark.postalCode != null && placemark.postalCode!.isNotEmpty) {
        addressParts.add(placemark.postalCode!);
      }
      if (placemark.country != null && placemark.country!.isNotEmpty) {
        addressParts.add(placemark.country!);
      }

      return LocationEntity(
        latitude: latitude,
        longitude: longitude,
        address: addressParts.join(', '),
        city: placemark.locality,
        country: placemark.country,
        postalCode: placemark.postalCode,
        street: placemark.street,
        name: placemark.name,
      );
    } catch (e) {
      throw LocationServiceException(
        'Failed to get address from coordinates: $e',
      );
    }
  }

  /// Get coordinates from address (forward geocoding)
  ///
  /// Returns list of [LocationEntity] matching the address query.
  ///
  /// Example:
  /// ```dart
  /// final locations = await LocationService.getCoordinatesFromAddress(
  ///   address: 'San Francisco, CA',
  /// );
  /// print('Found ${locations.length} locations');
  /// ```
  static Future<List<LocationEntity>> getCoordinatesFromAddress({
    required String address,
  }) async {
    try {
      final locations = await locationFromAddress(address);

      final results = <LocationEntity>[];
      for (final location in locations) {
        // Get address details for each location
        try {
          final placemarks = await placemarkFromCoordinates(
            location.latitude,
            location.longitude,
          );

          if (placemarks.isNotEmpty) {
            final placemark = placemarks.first;

            results.add(
              LocationEntity(
                latitude: location.latitude,
                longitude: location.longitude,
                address: address,
                city: placemark.locality,
                country: placemark.country,
                postalCode: placemark.postalCode,
                street: placemark.street,
                name: placemark.name,
              ),
            );
          } else {
            results.add(
              LocationEntity(
                latitude: location.latitude,
                longitude: location.longitude,
                address: address,
              ),
            );
          }
        } on Exception {
          // Add location without detailed address
          results.add(
            LocationEntity(
              latitude: location.latitude,
              longitude: location.longitude,
              address: address,
            ),
          );
        }
      }

      return results;
    } catch (e) {
      throw LocationServiceException(
        'Failed to get coordinates from address: $e',
      );
    }
  }

  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  static Future<LocationPermission> checkPermission() async {
    return Geolocator.checkPermission();
  }

  /// Request location permission
  static Future<LocationPermission> requestPermission() async {
    return Geolocator.requestPermission();
  }

  /// Open app settings to enable location permission
  static Future<bool> openAppSettings() async {
    return Geolocator.openAppSettings();
  }

  /// Open location settings
  static Future<bool> openLocationSettings() async {
    return Geolocator.openLocationSettings();
  }

  /// Get last known location (cached)
  ///
  /// Returns last known location without requesting new location.
  /// May return null if no cached location is available.
  static Future<LocationEntity?> getLastKnownLocation() async {
    final position = await Geolocator.getLastKnownPosition();
    if (position == null) return null;

    return LocationEntity(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  /// Calculate distance between two locations in kilometers
  static double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
          startLatitude,
          startLongitude,
          endLatitude,
          endLongitude,
        ) /
        1000; // Convert meters to kilometers
  }
}

/// LocationServiceException - Custom exception for location errors
class LocationServiceException implements Exception {
  const LocationServiceException(this.message);

  final String message;

  @override
  String toString() => 'LocationServiceException: $message';
}
