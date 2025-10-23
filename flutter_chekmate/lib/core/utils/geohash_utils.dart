import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

/// Geohash Utilities for Location-Based Features
///
/// This class provides utilities for working with geohashes and geospatial data.
/// It uses the GeoFlutterFire Plus package for geohash generation and distance calculations.
///
/// Key Features:
/// - Generate geohashes from latitude/longitude coordinates
/// - Calculate distance between two GeoPoints
/// - Convert coordinates to GeoPoint
/// - Validate coordinates
///
/// Usage:
/// ```dart
/// final geohash = GeohashUtils.generateGeohash(37.7749, -122.4194);
/// final distance = GeohashUtils.calculateDistance(point1, point2);
/// ```
class GeohashUtils {
  GeohashUtils._(); // Private constructor to prevent instantiation

  /// Generate a geohash from latitude and longitude coordinates
  ///
  /// Parameters:
  /// - [latitude]: Latitude coordinate (-90 to 90)
  /// - [longitude]: Longitude coordinate (-180 to 180)
  ///
  /// Returns: A geohash string representing the location
  ///
  /// Example:
  /// ```dart
  /// final geohash = GeohashUtils.generateGeohash(37.7749, -122.4194);
  /// print(geohash); // "9q8yy"
  /// ```
  static String generateGeohash(double latitude, double longitude) {
    // Validate coordinates
    if (!isValidLatitude(latitude)) {
      throw ArgumentError('Invalid latitude: $latitude. Must be between -90 and 90.');
    }
    if (!isValidLongitude(longitude)) {
      throw ArgumentError('Invalid longitude: $longitude. Must be between -180 and 180.');
    }

    // Create GeoFirePoint using GeoFlutterFire Plus
    final geoFirePoint = GeoFirePoint(GeoPoint(latitude, longitude));
    
    // Return the geohash
    return geoFirePoint.geohash;
  }

  /// Calculate the distance between two GeoPoints in kilometers
  ///
  /// Uses the Haversine formula to calculate the great-circle distance
  /// between two points on a sphere given their longitudes and latitudes.
  ///
  /// Parameters:
  /// - [point1]: First GeoPoint
  /// - [point2]: Second GeoPoint
  ///
  /// Returns: Distance in kilometers
  ///
  /// Example:
  /// ```dart
  /// final point1 = GeoPoint(37.7749, -122.4194); // San Francisco
  /// final point2 = GeoPoint(34.0522, -118.2437); // Los Angeles
  /// final distance = GeohashUtils.calculateDistance(point1, point2);
  /// print('Distance: ${distance.toStringAsFixed(2)} km'); // ~559 km
  /// ```
  static double calculateDistance(GeoPoint point1, GeoPoint point2) {
    return _haversineDistance(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  /// Calculate distance between two coordinate pairs in kilometers
  ///
  /// Parameters:
  /// - [lat1]: Latitude of first point
  /// - [lon1]: Longitude of first point
  /// - [lat2]: Latitude of second point
  /// - [lon2]: Longitude of second point
  ///
  /// Returns: Distance in kilometers
  static double calculateDistanceFromCoordinates(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return _haversineDistance(lat1, lon1, lat2, lon2);
  }

  /// Haversine formula implementation for calculating distance
  ///
  /// The Haversine formula determines the great-circle distance between
  /// two points on a sphere given their longitudes and latitudes.
  ///
  /// Earth's radius: 6371 km
  static double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    // Convert degrees to radians
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final lat1Rad = _degreesToRadians(lat1);
    final lat2Rad = _degreesToRadians(lat2);

    // Haversine formula
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) *
            math.sin(dLon / 2) *
            math.cos(lat1Rad) *
            math.cos(lat2Rad);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  /// Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }

  /// Convert radians to degrees
  static double _radiansToDegrees(double radians) {
    return radians * 180.0 / math.pi;
  }

  /// Create a GeoPoint from latitude and longitude
  ///
  /// Parameters:
  /// - [latitude]: Latitude coordinate (-90 to 90)
  /// - [longitude]: Longitude coordinate (-180 to 180)
  ///
  /// Returns: A Firestore GeoPoint
  ///
  /// Example:
  /// ```dart
  /// final geoPoint = GeohashUtils.createGeoPoint(37.7749, -122.4194);
  /// ```
  static GeoPoint createGeoPoint(double latitude, double longitude) {
    if (!isValidLatitude(latitude)) {
      throw ArgumentError('Invalid latitude: $latitude. Must be between -90 and 90.');
    }
    if (!isValidLongitude(longitude)) {
      throw ArgumentError('Invalid longitude: $longitude. Must be between -180 and 180.');
    }

    return GeoPoint(latitude, longitude);
  }

  /// Create a GeoFirePoint from latitude and longitude
  ///
  /// GeoFirePoint includes both the GeoPoint and its geohash
  ///
  /// Parameters:
  /// - [latitude]: Latitude coordinate (-90 to 90)
  /// - [longitude]: Longitude coordinate (-180 to 180)
  ///
  /// Returns: A GeoFirePoint with geohash
  ///
  /// Example:
  /// ```dart
  /// final geoFirePoint = GeohashUtils.createGeoFirePoint(37.7749, -122.4194);
  /// print(geoFirePoint.geohash); // "9q8yy"
  /// print(geoFirePoint.geopoint); // GeoPoint(37.7749, -122.4194)
  /// ```
  static GeoFirePoint createGeoFirePoint(double latitude, double longitude) {
    if (!isValidLatitude(latitude)) {
      throw ArgumentError('Invalid latitude: $latitude. Must be between -90 and 90.');
    }
    if (!isValidLongitude(longitude)) {
      throw ArgumentError('Invalid longitude: $longitude. Must be between -180 and 180.');
    }

    return GeoFirePoint(GeoPoint(latitude, longitude));
  }

  /// Validate latitude coordinate
  ///
  /// Parameters:
  /// - [latitude]: Latitude to validate
  ///
  /// Returns: true if valid, false otherwise
  static bool isValidLatitude(double latitude) {
    return latitude >= -90.0 && latitude <= 90.0;
  }

  /// Validate longitude coordinate
  ///
  /// Parameters:
  /// - [longitude]: Longitude to validate
  ///
  /// Returns: true if valid, false otherwise
  static bool isValidLongitude(double longitude) {
    return longitude >= -180.0 && longitude <= 180.0;
  }

  /// Validate both latitude and longitude coordinates
  ///
  /// Parameters:
  /// - [latitude]: Latitude to validate
  /// - [longitude]: Longitude to validate
  ///
  /// Returns: true if both are valid, false otherwise
  static bool isValidCoordinates(double latitude, double longitude) {
    return isValidLatitude(latitude) && isValidLongitude(longitude);
  }

  /// Format distance for display
  ///
  /// Parameters:
  /// - [distanceKm]: Distance in kilometers
  ///
  /// Returns: Formatted string (e.g., "2.5 km", "500 m")
  ///
  /// Example:
  /// ```dart
  /// print(GeohashUtils.formatDistance(2.5)); // "2.5 km"
  /// print(GeohashUtils.formatDistance(0.5)); // "500 m"
  /// print(GeohashUtils.formatDistance(0.05)); // "50 m"
  /// ```
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1.0) {
      // Convert to meters for distances less than 1 km
      final meters = (distanceKm * 1000).round();
      return '$meters m';
    } else {
      // Show km with 1 decimal place
      return '${distanceKm.toStringAsFixed(1)} km';
    }
  }

  /// Calculate bounding box for a given center point and radius
  ///
  /// This is useful for creating efficient geospatial queries
  ///
  /// Parameters:
  /// - [center]: Center GeoPoint
  /// - [radiusKm]: Radius in kilometers
  ///
  /// Returns: Map with 'southwest' and 'northeast' GeoPoints
  ///
  /// Example:
  /// ```dart
  /// final center = GeoPoint(37.7749, -122.4194);
  /// final bounds = GeohashUtils.calculateBoundingBox(center, 10.0);
  /// print(bounds['southwest']); // Southwest corner
  /// print(bounds['northeast']); // Northeast corner
  /// ```
  static Map<String, GeoPoint> calculateBoundingBox(
    GeoPoint center,
    double radiusKm,
  ) {
    const earthRadiusKm = 6371.0;

    // Calculate latitude offset
    final latOffset = _radiansToDegrees(radiusKm / earthRadiusKm);

    // Calculate longitude offset (accounting for latitude)
    final lonOffset = _radiansToDegrees(
      radiusKm / (earthRadiusKm * math.cos(_degreesToRadians(center.latitude))),
    );

    return {
      'southwest': GeoPoint(
        center.latitude - latOffset,
        center.longitude - lonOffset,
      ),
      'northeast': GeoPoint(
        center.latitude + latOffset,
        center.longitude + lonOffset,
      ),
    };
  }
}

