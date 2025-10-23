import 'package:equatable/equatable.dart';

/// LocationEntity - Core Domain Entity
///
/// Represents a geographic location with coordinates and address information.
/// Used for location tagging on posts, user profiles, and location-based search.
///
/// Features:
/// - Latitude/longitude coordinates
/// - Human-readable address
/// - Distance calculation
/// - Location formatting
///
/// Clean Architecture: Domain Layer (Core)
class LocationEntity extends Equatable {
  const LocationEntity({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.country,
    this.postalCode,
    this.street,
    this.name,
  });

  /// Latitude coordinate (-90 to 90)
  final double latitude;

  /// Longitude coordinate (-180 to 180)
  final double longitude;

  /// Full formatted address
  final String? address;

  /// City name
  final String? city;

  /// Country name
  final String? country;

  /// Postal/ZIP code
  final String? postalCode;

  /// Street address
  final String? street;

  /// Location name (e.g., "Central Park", "Starbucks")
  final String? name;

  /// Get display name for location
  /// Priority: name > city > address > coordinates
  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    if (city != null && city!.isNotEmpty) return city!;
    if (address != null && address!.isNotEmpty) return address!;
    return '$latitude, $longitude';
  }

  /// Get short display name (city, country)
  String get shortDisplayName {
    if (name != null && name!.isNotEmpty) return name!;
    if (city != null && country != null) {
      return '$city, $country';
    }
    if (city != null) return city!;
    if (country != null) return country!;
    return displayName;
  }

  /// Get full address string
  String get fullAddress {
    if (address != null && address!.isNotEmpty) return address!;

    final parts = <String>[];
    if (street != null && street!.isNotEmpty) parts.add(street!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (postalCode != null && postalCode!.isNotEmpty) parts.add(postalCode!);
    if (country != null && country!.isNotEmpty) parts.add(country!);

    return parts.isEmpty ? displayName : parts.join(', ');
  }

  /// Calculate distance to another location in kilometers
  /// Uses Haversine formula
  double distanceTo(LocationEntity other) {
    const earthRadiusKm = 6371.0;

    final dLat = _degreesToRadians(other.latitude - latitude);
    final dLon = _degreesToRadians(other.longitude - longitude);

    final lat1 = _degreesToRadians(latitude);
    final lat2 = _degreesToRadians(other.latitude);

    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _sin(dLon / 2) * _sin(dLon / 2) * _cos(lat1) * _cos(lat2);
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));

    return earthRadiusKm * c;
  }

  /// Calculate distance to another location in miles
  double distanceToInMiles(LocationEntity other) {
    return distanceTo(other) * 0.621371;
  }

  /// Get formatted distance string
  /// Returns "X km" or "X m" for metric
  String getDistanceString(LocationEntity other, {bool useMetric = true}) {
    final distanceKm = distanceTo(other);

    if (useMetric) {
      if (distanceKm < 1) {
        return '${(distanceKm * 1000).round()} m';
      }
      return '${distanceKm.toStringAsFixed(1)} km';
    } else {
      final distanceMiles = distanceToInMiles(other);
      if (distanceMiles < 1) {
        return '${(distanceMiles * 5280).round()} ft';
      }
      return '${distanceMiles.toStringAsFixed(1)} mi';
    }
  }

  /// Check if location is within radius (in kilometers)
  bool isWithinRadius(LocationEntity other, double radiusKm) {
    return distanceTo(other) <= radiusKm;
  }

  /// Check if coordinates are valid
  bool get isValid {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  /// Create a copy with updated fields
  LocationEntity copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? country,
    String? postalCode,
    String? street,
    String? name,
  }) {
    return LocationEntity(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      street: street ?? this.street,
      name: name ?? this.name,
    );
  }

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        address,
        city,
        country,
        postalCode,
        street,
        name,
      ];

  @override
  String toString() {
    return 'LocationEntity(lat: $latitude, lng: $longitude, name: $displayName)';
  }

  // Helper math functions
  double _degreesToRadians(double degrees) =>
      degrees * (3.141592653589793 / 180.0);
  double _sin(double x) => _taylorSin(x);
  double _cos(double x) => _taylorCos(x);
  double _sqrt(double x) => _newtonSqrt(x);
  double _atan2(double y, double x) => _taylorAtan2(y, x);

  // Taylor series approximation for sin
  double _taylorSin(double x) {
    var result = 0.0;
    var term = x;
    for (var n = 1; n < 10; n++) {
      result += term;
      term *= -x * x / ((2 * n) * (2 * n + 1));
    }
    return result;
  }

  // Taylor series approximation for cos
  double _taylorCos(double x) {
    var result = 1.0;
    var term = 1.0;
    for (var n = 1; n < 10; n++) {
      term *= -x * x / ((2 * n - 1) * (2 * n));
      result += term;
    }
    return result;
  }

  // Newton's method for square root
  double _newtonSqrt(double x) {
    if (x == 0) return 0;
    var guess = x / 2;
    for (var i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  // Taylor series approximation for atan2
  double _taylorAtan2(double y, double x) {
    if (x == 0) {
      return y > 0 ? 1.5707963267948966 : -1.5707963267948966; // π/2
    }
    final z = y / x;
    var result = z;
    var term = z;
    for (var n = 1; n < 10; n++) {
      term *= -z * z;
      result += term / (2 * n + 1);
    }
    return x > 0
        ? result
        : (y >= 0 ? result + 3.141592653589793 : result - 3.141592653589793);
  }
}
