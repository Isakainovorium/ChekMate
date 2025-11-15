import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Location Entity
///
/// Represents a geographic location in the ChekMate application.
/// Used for user location, post location, and location-based features.
///
/// Clean Architecture: Domain Layer
class LocationEntity extends Equatable {
  const LocationEntity({
    required this.latitude,
    required this.longitude,
    this.name,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.geohash,
    this.accuracy,
    this.timestamp,
  });

  final double latitude;
  final double longitude;
  final String? name;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? geohash;
  final double? accuracy; // Accuracy in meters
  final DateTime? timestamp; // When the location was captured

  /// Convert to GeoPoint for Firestore
  GeoPoint toGeoPoint() {
    return GeoPoint(latitude, longitude);
  }

  /// Create from GeoPoint
  factory LocationEntity.fromGeoPoint(
    GeoPoint geoPoint, {
    String? name,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? geohash,
    double? accuracy,
    DateTime? timestamp,
  }) {
    return LocationEntity(
      latitude: geoPoint.latitude,
      longitude: geoPoint.longitude,
      name: name,
      address: address,
      city: city,
      state: state,
      country: country,
      postalCode: postalCode,
      geohash: geohash,
      accuracy: accuracy,
      timestamp: timestamp,
    );
  }

  /// Get formatted location string
  String get formattedLocation {
    if (name != null && name!.isNotEmpty) {
      return name!;
    }

    final parts = <String>[];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (country != null && country!.isNotEmpty) parts.add(country!);

    return parts.isNotEmpty ? parts.join(', ') : 'Unknown Location';
  }

  /// Get display name (alias for formattedLocation)
  String get displayName => formattedLocation;

  /// Get short location string (city, state)
  String get shortLocation {
    final parts = <String>[];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);

    return parts.isNotEmpty ? parts.join(', ') : formattedLocation;
  }

  /// Calculate distance to another location in kilometers
  double distanceTo(LocationEntity other) {
    return _haversineDistance(
      latitude,
      longitude,
      other.latitude,
      other.longitude,
    );
  }

  /// Calculate distance using Haversine formula
  static double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * asin(sqrt(a));

    return earthRadiusKm * c;
  }

  /// Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }

  /// Copy with method for creating modified copies
  LocationEntity copyWith({
    double? latitude,
    double? longitude,
    String? name,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? geohash,
    double? accuracy,
    DateTime? timestamp,
  }) {
    return LocationEntity(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      geohash: geohash ?? this.geohash,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'geohash': geohash,
      'accuracy': accuracy,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory LocationEntity.fromJson(Map<String, dynamic> json) {
    return LocationEntity(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      name: json['name'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      geohash: json['geohash'] as String?,
      accuracy: json['accuracy'] as double?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        name,
        address,
        city,
        state,
        country,
        postalCode,
        geohash,
        accuracy,
        timestamp,
      ];
}
