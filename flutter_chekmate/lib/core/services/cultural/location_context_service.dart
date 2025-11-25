import 'package:flutter_chekmate/core/services/location_service.dart';
import 'package:flutter_chekmate/core/domain/entities/location_entity.dart';

/// Enhanced location context extraction for cultural pattern discovery
class LocationContextService {
  static final LocationContextService _instance =
      LocationContextService._internal();
  static LocationContextService get instance => _instance;

  LocationContextService._internal();

  /// Extract rich location context from GPS coordinates
  Future<LocationContext> extractLocationContext({
    required double latitude,
    required double longitude,
  }) async {
    final location = await LocationService.getAddressFromCoordinates(
      latitude: latitude,
      longitude: longitude,
    );

    return LocationContext(
      latitude: latitude,
      longitude: longitude,
      neighborhood:
          location.name, // Use name field as neighborhood approximation
      city: location.city,
      state: location.state,
      country: location.country,
      postalCode: location.postalCode,
      // Generate free-form location description
      locationDescription: _buildLocationDescription(location),
      // Extract cultural keywords from location
      locationKeywords: _extractLocationKeywords(location),
      extractedAt: DateTime.now(),
    );
  }

  /// Build human-readable location description
  String _buildLocationDescription(LocationEntity location) {
    final parts = <String>[];

    if (location.name?.isNotEmpty ?? false) {
      parts.add(location.name!);
    }
    if (location.city?.isNotEmpty ?? false) {
      parts.add(location.city!);
    }
    if (location.state?.isNotEmpty ?? false) {
      parts.add(location.state!);
    }
    if (location.country?.isNotEmpty ?? false) {
      parts.add(location.country!);
    }

    return parts.join(', ');
  }

  /// Extract cultural keywords from location names
  List<String> _extractLocationKeywords(LocationEntity location) {
    final keywords = <String>[];

    // Add location names as keywords
    if (location.name != null) keywords.add(location.name!);
    if (location.city != null) keywords.add(location.city!);
    if (location.state != null) keywords.add(location.state!);

    // Add known cultural regions (can be expanded)
    final culturalRegions = _identifyCulturalRegions(location);
    keywords.addAll(culturalRegions);

    return keywords;
  }

  /// Identify known cultural regions from location
  List<String> _identifyCulturalRegions(LocationEntity location) {
    final regions = <String>[];

    // US regional patterns
    if (location.country == 'United States') {
      if (_isNortheast(location.state)) {
        regions.add('Northeast US');
      }
      if (_isSouth(location.state)) {
        regions.add('Southern US');
      }
      if (_isWestCoast(location.state)) {
        regions.add('West Coast');
      }
      if (_isMidwest(location.state)) {
        regions.add('Midwest');
      }

      // Major cultural hubs
      if (location.city == 'New York') {
        regions.add('NYC metro');
      }
      if (location.city == 'Atlanta') {
        regions.add('Atlanta culture');
      }
      if (location.city == 'Los Angeles') {
        regions.add('LA culture');
      }
      if (location.city == 'Miami') {
        regions.add('Miami Latino culture');
      }
      if (location.city == 'Chicago') {
        regions.add('Chicago culture');
      }
      if (location.city == 'Houston') {
        regions.add('Houston diverse culture');
      }
      if (location.city == 'San Francisco' || location.city == 'Oakland') {
        regions.add('Bay Area culture');
      }
      if (location.city == 'Seattle') {
        regions.add('Pacific Northwest culture');
      }
      if (location.city == 'New Orleans') {
        regions.add('New Orleans culture');
      }
      if (location.city == 'Detroit') {
        regions.add('Detroit culture');
      }
    }

    // International regions
    if (location.country == 'Jamaica' ||
        location.country == 'Trinidad and Tobago' ||
        location.country == 'Barbados' ||
        location.country == 'Haiti') {
      regions.add('Caribbean');
    }
    if (location.country == 'Mexico' ||
        location.country == 'Colombia' ||
        location.country == 'Brazil' ||
        location.country == 'Argentina' ||
        location.country == 'Peru' ||
        location.country == 'Chile') {
      regions.add('Latin America');
    }
    if (location.country == 'Nigeria' ||
        location.country == 'Ghana' ||
        location.country == 'Kenya' ||
        location.country == 'South Africa' ||
        location.country == 'Ethiopia') {
      regions.add('African');
    }
    if (location.country == 'United Kingdom' ||
        location.country == 'France' ||
        location.country == 'Germany' ||
        location.country == 'Italy' ||
        location.country == 'Spain') {
      regions.add('European');
    }
    if (location.country == 'Japan' ||
        location.country == 'South Korea' ||
        location.country == 'China' ||
        location.country == 'India' ||
        location.country == 'Philippines') {
      regions.add('Asian');
    }
    if (location.country == 'Canada') {
      regions.add('Canadian');
      if (location.state == 'Quebec') {
        regions.add('French Canadian');
      }
    }

    return regions;
  }

  bool _isNortheast(String? state) {
    final northeastStates = [
      'New York',
      'New Jersey',
      'Pennsylvania',
      'Massachusetts',
      'Connecticut',
      'Rhode Island',
      'Vermont',
      'New Hampshire',
      'Maine',
      'Maryland',
      'Delaware',
      'Washington DC'
    ];
    return northeastStates.contains(state);
  }

  bool _isSouth(String? state) {
    final southStates = [
      'Georgia',
      'Florida',
      'Texas',
      'Louisiana',
      'Alabama',
      'Mississippi',
      'North Carolina',
      'South Carolina',
      'Virginia',
      'Tennessee',
      'Kentucky',
      'Arkansas',
      'West Virginia'
    ];
    return southStates.contains(state);
  }

  bool _isWestCoast(String? state) {
    final westStates = ['California', 'Washington', 'Oregon', 'Nevada'];
    return westStates.contains(state);
  }

  bool _isMidwest(String? state) {
    final midwestStates = [
      'Illinois',
      'Michigan',
      'Ohio',
      'Wisconsin',
      'Minnesota',
      'Indiana',
      'Iowa',
      'Missouri',
      'Kansas',
      'Nebraska',
      'North Dakota',
      'South Dakota'
    ];
    return midwestStates.contains(state);
  }

  /// Get cached or extract location context
  static final Map<String, LocationContext> _cache = {};

  Future<LocationContext> getCachedOrExtract({
    required double latitude,
    required double longitude,
  }) async {
    // Round to 4 decimal places for cache key (about 11 meter precision)
    final key =
        '${latitude.toStringAsFixed(4)}_${longitude.toStringAsFixed(4)}';

    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    final context = await extractLocationContext(
      latitude: latitude,
      longitude: longitude,
    );

    _cache[key] = context;

    // Limit cache size to prevent memory issues
    if (_cache.length > 1000) {
      // Remove oldest entries (simple FIFO)
      final keysToRemove = _cache.keys.take(100).toList();
      for (final key in keysToRemove) {
        _cache.remove(key);
      }
    }

    return context;
  }
}

/// Rich location context model
class LocationContext {
  final double latitude;
  final double longitude;
  final String? neighborhood;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String locationDescription;
  final List<String> locationKeywords;
  final DateTime extractedAt;

  LocationContext({
    required this.latitude,
    required this.longitude,
    this.neighborhood,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    required this.locationDescription,
    required this.locationKeywords,
    required this.extractedAt,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'neighborhood': neighborhood,
        'city': city,
        'state': state,
        'country': country,
        'postalCode': postalCode,
        'locationDescription': locationDescription,
        'locationKeywords': locationKeywords,
        'extractedAt': extractedAt.toIso8601String(),
      };

  factory LocationContext.fromJson(Map<String, dynamic> json) =>
      LocationContext(
        latitude: json['latitude'] as double,
        longitude: json['longitude'] as double,
        neighborhood: json['neighborhood'] as String?,
        city: json['city'] as String?,
        state: json['state'] as String?,
        country: json['country'] as String?,
        postalCode: json['postalCode'] as String?,
        locationDescription: json['locationDescription'] as String,
        locationKeywords: List<String>.from(json['locationKeywords']),
        extractedAt: DateTime.parse(json['extractedAt'] as String),
      );
}

/// Address model (should match LocationService implementation)
class Address {
  final String? neighborhood;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? street;
  final String? streetNumber;

  Address({
    this.neighborhood,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.street,
    this.streetNumber,
  });
}
