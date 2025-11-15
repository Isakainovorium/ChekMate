import 'dart:math';

/// Geohash Utilities
///
/// Provides utility functions for generating and working with geohashes.
/// Geohashes are used for efficient location-based queries in Firestore.
///
/// This implementation uses a simple geohash algorithm for location encoding.
class GeohashUtils {
  /// Base32 characters used in geohash encoding
  static const String _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

  /// Generate a geohash from latitude and longitude
  ///
  /// [latitude] - Latitude coordinate (-90 to 90)
  /// [longitude] - Longitude coordinate (-180 to 180)
  /// [precision] - Number of characters in the geohash (default: 9)
  ///
  /// Returns a geohash string
  static String generateGeohash(
    double latitude,
    double longitude, {
    int precision = 9,
  }) {
    // Validate inputs
    if (latitude < -90 || latitude > 90) {
      throw ArgumentError('Latitude must be between -90 and 90');
    }
    if (longitude < -180 || longitude > 180) {
      throw ArgumentError('Longitude must be between -180 and 180');
    }
    if (precision < 1 || precision > 12) {
      throw ArgumentError('Precision must be between 1 and 12');
    }

    var latRange = [-90.0, 90.0];
    var lonRange = [-180.0, 180.0];
    var geohash = '';
    var isEven = true;
    var bit = 0;
    var ch = 0;

    while (geohash.length < precision) {
      if (isEven) {
        // Longitude
        final mid = (lonRange[0] + lonRange[1]) / 2;
        if (longitude > mid) {
          ch |= (1 << (4 - bit));
          lonRange[0] = mid;
        } else {
          lonRange[1] = mid;
        }
      } else {
        // Latitude
        final mid = (latRange[0] + latRange[1]) / 2;
        if (latitude > mid) {
          ch |= (1 << (4 - bit));
          latRange[0] = mid;
        } else {
          latRange[1] = mid;
        }
      }

      isEven = !isEven;

      if (bit < 4) {
        bit++;
      } else {
        geohash += _base32[ch];
        bit = 0;
        ch = 0;
      }
    }

    return geohash;
  }

  /// Decode a geohash into latitude and longitude bounds
  ///
  /// [geohash] - The geohash string to decode
  ///
  /// Returns a map with 'latitude' and 'longitude' keys, each containing
  /// a list of [min, max] bounds
  static Map<String, List<double>> decodeGeohash(String geohash) {
    var latRange = [-90.0, 90.0];
    var lonRange = [-180.0, 180.0];
    var isEven = true;

    for (var i = 0; i < geohash.length; i++) {
      final char = geohash[i];
      final charIndex = _base32.indexOf(char);

      if (charIndex == -1) {
        throw ArgumentError('Invalid geohash character: $char');
      }

      for (var bit = 4; bit >= 0; bit--) {
        final mask = 1 << bit;

        if (isEven) {
          // Longitude
          final mid = (lonRange[0] + lonRange[1]) / 2;
          if ((charIndex & mask) != 0) {
            lonRange[0] = mid;
          } else {
            lonRange[1] = mid;
          }
        } else {
          // Latitude
          final mid = (latRange[0] + latRange[1]) / 2;
          if ((charIndex & mask) != 0) {
            latRange[0] = mid;
          } else {
            latRange[1] = mid;
          }
        }

        isEven = !isEven;
      }
    }

    return {
      'latitude': latRange,
      'longitude': lonRange,
    };
  }

  /// Get the center point of a geohash
  ///
  /// [geohash] - The geohash string
  ///
  /// Returns a map with 'latitude' and 'longitude' keys
  static Map<String, double> getGeohashCenter(String geohash) {
    final bounds = decodeGeohash(geohash);
    final latRange = bounds['latitude']!;
    final lonRange = bounds['longitude']!;

    return {
      'latitude': (latRange[0] + latRange[1]) / 2,
      'longitude': (lonRange[0] + lonRange[1]) / 2,
    };
  }

  /// Get neighboring geohashes
  ///
  /// [geohash] - The center geohash
  ///
  /// Returns a list of 8 neighboring geohashes (N, NE, E, SE, S, SW, W, NW)
  static List<String> getNeighbors(String geohash) {
    final center = getGeohashCenter(geohash);
    final lat = center['latitude']!;
    final lon = center['longitude']!;

    // Calculate approximate degree offset based on geohash precision
    final precision = geohash.length;
    final latOffset = _getLatitudeOffset(precision);
    final lonOffset = _getLongitudeOffset(precision, lat);

    return [
      generateGeohash(lat + latOffset, lon, precision: precision), // N
      generateGeohash(lat + latOffset, lon + lonOffset,
          precision: precision), // NE
      generateGeohash(lat, lon + lonOffset, precision: precision), // E
      generateGeohash(lat - latOffset, lon + lonOffset,
          precision: precision), // SE
      generateGeohash(lat - latOffset, lon, precision: precision), // S
      generateGeohash(lat - latOffset, lon - lonOffset,
          precision: precision), // SW
      generateGeohash(lat, lon - lonOffset, precision: precision), // W
      generateGeohash(lat + latOffset, lon - lonOffset,
          precision: precision), // NW
    ];
  }

  /// Get latitude offset for a given precision
  static double _getLatitudeOffset(int precision) {
    // Approximate latitude degrees per geohash character
    const latDegreesPerChar = [
      180.0, // precision 1
      45.0, // precision 2
      5.625, // precision 3
      1.40625, // precision 4
      0.17578125, // precision 5
      0.0439453125, // precision 6
      0.0054931640625, // precision 7
      0.001373291015625, // precision 8
      0.000171661376953125, // precision 9
      0.0000429153442382812, // precision 10
      0.00000536441802978516, // precision 11
      0.00000134110450744629, // precision 12
    ];

    return precision <= 12
        ? latDegreesPerChar[precision - 1]
        : 0.00000134110450744629;
  }

  /// Get longitude offset for a given precision and latitude
  static double _getLongitudeOffset(int precision, double latitude) {
    // Longitude offset varies with latitude
    final latOffset = _getLatitudeOffset(precision);
    // Adjust for latitude (longitude lines converge at poles)
    return latOffset / (latitude.abs() > 85 ? 2 : 1);
  }

  /// Calculate distance between two geohashes in kilometers
  ///
  /// Uses the Haversine formula for great-circle distance
  static double distanceBetween(String geohash1, String geohash2) {
    final center1 = getGeohashCenter(geohash1);
    final center2 = getGeohashCenter(geohash2);

    return _haversineDistance(
      center1['latitude']!,
      center1['longitude']!,
      center2['latitude']!,
      center2['longitude']!,
    );
  }

  /// Calculate distance between two coordinates using Haversine formula
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
}
