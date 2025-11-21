# Trace 2: Geographic Classification Migration Guide
## From Static Country Mapping to ML-Discovered Regional Patterns

**Trace ID:** 2  
**Current File:** `cultural_intelligence_service.dart`  
**Status:** Static country code → culture category mapping  
**Target:** ML-discovered regional cultural patterns

---

## Current Implementation Analysis

### Location 2a: Geographic Classification Entry
**File:** `cultural_intelligence_service.dart:30`

```dart
Future<CulturalContext> classifyContentGeographically({
  required String contentId,
  required double latitude,
  required double longitude,
}) async {
  // Converts GPS coordinates to cultural category
}
```

**Current Behavior:**
- Takes GPS coordinates as input
- Returns predefined `CultureCategory` enum
- Limited to ~12 hardcoded country mappings

**Target Behavior:**
- Extract rich location context (neighborhood, city culture, regional identity)
- Discover location-based cultural patterns from user data
- Support granular location matching (e.g., "Brooklyn" vs "Manhattan")

---

### Location 2b: Coordinate to Address
**File:** `cultural_intelligence_service.dart:36`

```dart
final location = await LocationService.getAddressFromCoordinates(
  latitude: latitude,
  longitude: longitude,
);
```

**Current Behavior:**
- Reverse geocoding to get country/state/city
- Only uses country for classification
- Discards valuable neighborhood/region data

**Target Behavior:**
- Capture full location hierarchy (neighborhood → city → region → country)
- Extract cultural context from location names
- Enable location-based pattern discovery

---

### Location 2c: Country Code Extraction
**File:** `cultural_intelligence_service.dart:41`

```dart
final countryCode = _extractCountryCode(location.country ?? '');
```

**Current Behavior:**
- Maps country name to ISO code
- Hardcoded lookup table
- Only 12 countries supported

**Target Behavior:**
- Extract location description text
- No manual country mapping needed
- Support any location worldwide

---

### Location 2d: Culture Category Mapping
**File:** `cultural_intelligence_service.dart:42`

```dart
final cultureCategory = _countryCultureMap[countryCode] ?? CultureCategory.unknown;
```

**Current Behavior:**
- Static map: `'US' → CultureCategory.northAmerica`
- Predefined categories
- Loses regional nuance (e.g., NYC vs rural Texas)

**Target Behavior:**
- No predefined categories
- ML discovers patterns like "urban Northeast" or "Southern hip-hop culture"
- Location becomes part of overall cultural vector

---

## Migration Implementation

### Step 1: Enhanced Location Context Extraction

**New File:** `location_context_service.dart`

```dart
import 'package:flutter_chekmate/core/services/location_service.dart';

/// Enhanced location context extraction for cultural pattern discovery
class LocationContextService {
  static final LocationContextService _instance = LocationContextService._internal();
  static LocationContextService get instance => _instance;
  
  LocationContextService._internal();
  
  /// Extract rich location context from GPS coordinates
  Future<LocationContext> extractLocationContext({
    required double latitude,
    required double longitude,
  }) async {
    final address = await LocationService.getAddressFromCoordinates(
      latitude: latitude,
      longitude: longitude,
    );
    
    return LocationContext(
      latitude: latitude,
      longitude: longitude,
      neighborhood: address.neighborhood,
      city: address.city,
      state: address.state,
      country: address.country,
      postalCode: address.postalCode,
      // Generate free-form location description
      locationDescription: _buildLocationDescription(address),
      // Extract cultural keywords from location
      locationKeywords: _extractLocationKeywords(address),
      extractedAt: DateTime.now(),
    );
  }
  
  /// Build human-readable location description
  String _buildLocationDescription(Address address) {
    final parts = <String>[];
    
    if (address.neighborhood?.isNotEmpty ?? false) {
      parts.add(address.neighborhood!);
    }
    if (address.city?.isNotEmpty ?? false) {
      parts.add(address.city!);
    }
    if (address.state?.isNotEmpty ?? false) {
      parts.add(address.state!);
    }
    if (address.country?.isNotEmpty ?? false) {
      parts.add(address.country!);
    }
    
    return parts.join(', ');
  }
  
  /// Extract cultural keywords from location names
  List<String> _extractLocationKeywords(Address address) {
    final keywords = <String>[];
    
    // Add location names as keywords
    if (address.neighborhood != null) keywords.add(address.neighborhood!);
    if (address.city != null) keywords.add(address.city!);
    if (address.state != null) keywords.add(address.state!);
    
    // Add known cultural regions (can be expanded)
    final culturalRegions = _identifyCulturalRegions(address);
    keywords.addAll(culturalRegions);
    
    return keywords;
  }
  
  /// Identify known cultural regions from location
  List<String> _identifyCulturalRegions(Address address) {
    final regions = <String>[];
    
    // US regional patterns
    if (address.country == 'United States') {
      if (_isNortheast(address.state)) {
        regions.add('Northeast US');
      }
      if (_isSouth(address.state)) {
        regions.add('Southern US');
      }
      if (_isWestCoast(address.state)) {
        regions.add('West Coast');
      }
      if (_isMidwest(address.state)) {
        regions.add('Midwest');
      }
      
      // Major cultural hubs
      if (address.city == 'New York') {
        regions.add('NYC metro');
      }
      if (address.city == 'Atlanta') {
        regions.add('Atlanta culture');
      }
      if (address.city == 'Los Angeles') {
        regions.add('LA culture');
      }
      if (address.city == 'Miami') {
        regions.add('Miami Latino culture');
      }
    }
    
    // International regions
    if (address.country == 'Jamaica' || address.country == 'Trinidad and Tobago') {
      regions.add('Caribbean');
    }
    if (address.country == 'Mexico' || address.country == 'Colombia') {
      regions.add('Latin America');
    }
    
    return regions;
  }
  
  bool _isNortheast(String? state) {
    final northeastStates = ['New York', 'New Jersey', 'Pennsylvania', 
                             'Massachusetts', 'Connecticut', 'Rhode Island'];
    return northeastStates.contains(state);
  }
  
  bool _isSouth(String? state) {
    final southStates = ['Georgia', 'Florida', 'Texas', 'Louisiana', 
                         'Alabama', 'Mississippi', 'North Carolina', 'South Carolina'];
    return southStates.contains(state);
  }
  
  bool _isWestCoast(String? state) {
    final westStates = ['California', 'Washington', 'Oregon'];
    return westStates.contains(state);
  }
  
  bool _isMidwest(String? state) {
    final midwestStates = ['Illinois', 'Michigan', 'Ohio', 'Wisconsin', 'Minnesota'];
    return midwestStates.contains(state);
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
}
```

---

### Step 2: Integrate Location into Cultural Vectors

**Modified File:** `cultural_vector_service.dart`

```dart
class CulturalVectorService {
  // ... existing code ...
  
  /// Generate vector with location context included
  Future<List<double>> generateCulturalVectorWithLocation({
    required String? heritageDescription,
    required List<String> communityAffiliations,
    required String? generationalIdentity,
    required List<String> culturalPractices,
    required List<String> culturalInterests,
    required String? regionalInfluence,
    // NEW: Location context
    required LocationContext? locationContext,
  }) async {
    // Combine cultural inputs with location data
    final combinedText = _combineInputsWithLocation(
      heritageDescription: heritageDescription,
      communityAffiliations: communityAffiliations,
      generationalIdentity: generationalIdentity,
      culturalPractices: culturalPractices,
      culturalInterests: culturalInterests,
      regionalInfluence: regionalInfluence,
      locationContext: locationContext,
    );
    
    // Generate embedding (same as before)
    return await _generateEmbedding(combinedText);
  }
  
  String _combineInputsWithLocation({
    required String? heritageDescription,
    required List<String> communityAffiliations,
    required String? generationalIdentity,
    required List<String> culturalPractices,
    required List<String> culturalInterests,
    required String? regionalInfluence,
    required LocationContext? locationContext,
  }) {
    final parts = <String>[];
    
    // Cultural inputs (same as before)
    if (heritageDescription?.isNotEmpty ?? false) {
      parts.add('Heritage: $heritageDescription');
    }
    if (communityAffiliations.isNotEmpty) {
      parts.add('Communities: ${communityAffiliations.join(", ")}');
    }
    if (generationalIdentity?.isNotEmpty ?? false) {
      parts.add('Generation: $generationalIdentity');
    }
    if (culturalPractices.isNotEmpty) {
      parts.add('Practices: ${culturalPractices.join(", ")}');
    }
    if (culturalInterests.isNotEmpty) {
      parts.add('Interests: ${culturalInterests.join(", ")}');
    }
    if (regionalInfluence?.isNotEmpty ?? false) {
      parts.add('Regional influence: $regionalInfluence');
    }
    
    // NEW: Add location context
    if (locationContext != null) {
      parts.add('Location: ${locationContext.locationDescription}');
      if (locationContext.locationKeywords.isNotEmpty) {
        parts.add('Regional context: ${locationContext.locationKeywords.join(", ")}');
      }
    }
    
    return parts.join('. ');
  }
}
```

---

### Step 3: Update CulturalIntelligenceService

**Modified File:** `cultural_intelligence_service.dart`

```dart
import 'location_context_service.dart';
import 'cultural_vector_service.dart';

class CulturalIntelligenceService {
  static final CulturalIntelligenceService _instance = 
      CulturalIntelligenceService._internal();
  static CulturalIntelligenceService get instance => _instance;
  
  CulturalIntelligenceService._internal();
  
  /// NEW: ML-driven geographic classification
  Future<EnhancedCulturalContext> classifyContentWithML({
    required String contentId,
    required double latitude,
    required double longitude,
    required String? creatorHeritageDescription,
    required List<String> creatorCommunities,
    required String? creatorGeneration,
  }) async {
    // Extract rich location context
    final locationContext = await LocationContextService.instance
        .extractLocationContext(
      latitude: latitude,
      longitude: longitude,
    );
    
    // Generate cultural vector including location
    final culturalVector = await CulturalVectorService.instance
        .generateCulturalVectorWithLocation(
      heritageDescription: creatorHeritageDescription,
      communityAffiliations: creatorCommunities,
      generationalIdentity: creatorGeneration,
      culturalPractices: [],
      culturalInterests: [],
      regionalInfluence: null,
      locationContext: locationContext,
    );
    
    return EnhancedCulturalContext(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      contentId: contentId,
      locationContext: locationContext,
      culturalVector: culturalVector,
      createdAt: DateTime.now(),
    );
  }
  
  // KEEP OLD METHOD for backward compatibility
  @Deprecated('Use classifyContentWithML instead')
  Future<CulturalContext> classifyContentGeographically({
    required String contentId,
    required double latitude,
    required double longitude,
  }) async {
    // Existing enum-based implementation
    // Will be removed after migration
  }
}

/// Enhanced cultural context with ML vectors
class EnhancedCulturalContext {
  final String id;
  final String contentId;
  final LocationContext locationContext;
  final List<double> culturalVector;
  final DateTime createdAt;
  
  EnhancedCulturalContext({
    required this.id,
    required this.contentId,
    required this.locationContext,
    required this.culturalVector,
    required this.createdAt,
  });
}
```

---

### Step 4: Location-Based Pattern Discovery

**New File:** `location_pattern_service.dart`

```dart
/// Discovers location-based cultural patterns from user data
class LocationPatternService {
  static final LocationPatternService _instance = LocationPatternService._internal();
  static LocationPatternService get instance => _instance;
  
  LocationPatternService._internal();
  
  /// Discover location-based cultural clusters
  Future<List<LocationCulturalPattern>> discoverLocationPatterns({
    required List<UserProfile> allUsers,
  }) async {
    final patterns = <LocationCulturalPattern>[];
    
    // Group users by location keywords
    final locationGroups = _groupByLocation(allUsers);
    
    // For each location group, find common cultural themes
    for (final entry in locationGroups.entries) {
      final location = entry.key;
      final users = entry.value;
      
      if (users.length < 20) continue; // Minimum cluster size
      
      // Extract common cultural themes
      final commonThemes = _extractCommonThemes(users);
      
      // Calculate centroid vector for this location cluster
      final centroidVector = _calculateCentroid(
        users.map((u) => u.culturalVector).toList()
      );
      
      patterns.add(LocationCulturalPattern(
        location: location,
        userCount: users.length,
        commonThemes: commonThemes,
        centroidVector: centroidVector,
        discoveredAt: DateTime.now(),
      ));
    }
    
    return patterns;
  }
  
  Map<String, List<UserProfile>> _groupByLocation(List<UserProfile> users) {
    final groups = <String, List<UserProfile>>{};
    
    for (final user in users) {
      final location = user.locationContext?.city ?? 'Unknown';
      groups.putIfAbsent(location, () => []).add(user);
    }
    
    return groups;
  }
  
  List<String> _extractCommonThemes(List<UserProfile> users) {
    final themeFrequency = <String, int>{};
    
    for (final user in users) {
      // Count heritage keywords
      final heritageWords = user.heritageDescription?.split(' ') ?? [];
      for (final word in heritageWords) {
        themeFrequency[word] = (themeFrequency[word] ?? 0) + 1;
      }
      
      // Count community affiliations
      for (final community in user.communityAffiliations) {
        themeFrequency[community] = (themeFrequency[community] ?? 0) + 1;
      }
    }
    
    // Return top themes (appearing in >30% of users)
    final threshold = (users.length * 0.3).round();
    return themeFrequency.entries
        .where((e) => e.value >= threshold)
        .map((e) => e.key)
        .toList();
  }
  
  List<double> _calculateCentroid(List<List<double>> vectors) {
    if (vectors.isEmpty) return [];
    
    final dimensions = vectors.first.length;
    final centroid = List<double>.filled(dimensions, 0.0);
    
    for (final vector in vectors) {
      for (int i = 0; i < dimensions; i++) {
        centroid[i] += vector[i];
      }
    }
    
    for (int i = 0; i < dimensions; i++) {
      centroid[i] /= vectors.length;
    }
    
    return centroid;
  }
}

/// Discovered location-based cultural pattern
class LocationCulturalPattern {
  final String location;
  final int userCount;
  final List<String> commonThemes;
  final List<double> centroidVector;
  final DateTime discoveredAt;
  
  LocationCulturalPattern({
    required this.location,
    required this.userCount,
    required this.commonThemes,
    required this.centroidVector,
    required this.discoveredAt,
  });
}
```

---

## Database Schema Updates

```sql
-- Add location context to cultural profiles
ALTER TABLE cultural_profiles
  ADD COLUMN location_latitude DECIMAL(10, 8),
  ADD COLUMN location_longitude DECIMAL(11, 8),
  ADD COLUMN location_neighborhood VARCHAR(255),
  ADD COLUMN location_city VARCHAR(255),
  ADD COLUMN location_state VARCHAR(255),
  ADD COLUMN location_country VARCHAR(255),
  ADD COLUMN location_description TEXT,
  ADD COLUMN location_keywords TEXT[];

-- Create discovered location patterns table
CREATE TABLE discovered_location_patterns (
  id UUID PRIMARY KEY,
  location VARCHAR(255) NOT NULL,
  user_count INTEGER NOT NULL,
  common_themes TEXT[],
  centroid_vector FLOAT8[384],
  discovered_at TIMESTAMP NOT NULL,
  is_active BOOLEAN DEFAULT true
);

-- Index for location-based queries
CREATE INDEX idx_location_city ON cultural_profiles(location_city);
CREATE INDEX idx_location_keywords ON cultural_profiles USING GIN(location_keywords);
```

---

## Migration Script

**New File:** `scripts/migrate_geographic_classification.dart`

```dart
/// Migrate from static country mapping to ML location patterns
class GeographicMigrationScript {
  Future<void> migrateAllLocations() async {
    print('Starting geographic classification migration...');
    
    // 1. Fetch all content with GPS coordinates
    final contentWithGPS = await _fetchContentWithCoordinates();
    print('Found ${contentWithGPS.length} content items with GPS data');
    
    // 2. Extract rich location context for each
    final locationContexts = <String, LocationContext>{};
    for (final content in contentWithGPS) {
      final context = await LocationContextService.instance
          .extractLocationContext(
        latitude: content.latitude,
        longitude: content.longitude,
      );
      locationContexts[content.id] = context;
    }
    
    // 3. Store location contexts in database
    await _storeLocationContexts(locationContexts);
    
    // 4. Regenerate cultural vectors with location data
    print('Regenerating cultural vectors with location context...');
    await _regenerateVectorsWithLocation(locationContexts);
    
    print('Migration complete!');
  }
  
  Future<List<ContentWithGPS>> _fetchContentWithCoordinates() async {
    // Implement database fetch
  }
  
  Future<void> _storeLocationContexts(
    Map<String, LocationContext> contexts
  ) async {
    // Implement database storage
  }
  
  Future<void> _regenerateVectorsWithLocation(
    Map<String, LocationContext> contexts
  ) async {
    // Regenerate vectors including location data
  }
}
```

---

## Testing Strategy

```dart
// test/services/location_context_service_test.dart
void main() {
  group('LocationContextService', () {
    test('extracts neighborhood from GPS coordinates', () async {
      final service = LocationContextService.instance;
      
      // Brooklyn coordinates
      final context = await service.extractLocationContext(
        latitude: 40.6782,
        longitude: -73.9442,
      );
      
      expect(context.city, equals('Brooklyn'));
      expect(context.locationKeywords, contains('Northeast US'));
    });
    
    test('identifies cultural regions correctly', () async {
      final service = LocationContextService.instance;
      
      // Atlanta coordinates
      final context = await service.extractLocationContext(
        latitude: 33.7490,
        longitude: -84.3880,
      );
      
      expect(context.locationKeywords, contains('Southern US'));
      expect(context.locationKeywords, contains('Atlanta culture'));
    });
  });
}
```

---

## Performance Considerations

### Caching Location Lookups

```dart
class LocationCacheService {
  static final _cache = <String, LocationContext>{};
  
  Future<LocationContext> getCachedOrExtract({
    required double latitude,
    required double longitude,
  }) async {
    final key = '${latitude.toStringAsFixed(4)}_${longitude.toStringAsFixed(4)}';
    
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }
    
    final context = await LocationContextService.instance
        .extractLocationContext(
      latitude: latitude,
      longitude: longitude,
    );
    
    _cache[key] = context;
    return context;
  }
}
```

---

## Rollout Plan

### Week 1-2: Location Context Extraction
- Implement `LocationContextService`
- Extract location data for all existing content
- Store in database

### Week 3-4: Vector Regeneration
- Regenerate cultural vectors with location context
- Compare old vs new matching results
- A/B test with 10% of users

### Week 5-6: Pattern Discovery
- Run location pattern discovery algorithm
- Identify emergent location-based clusters
- Validate discovered patterns

### Week 7-8: Full Migration
- Switch all users to ML-based location matching
- Deprecate static country mapping
- Monitor performance

---

## Success Criteria

✅ **Location extraction**: < 200ms per lookup  
✅ **Pattern discovery**: Identify 20+ meaningful location clusters  
✅ **Match improvement**: 15% better engagement on location-matched content  
✅ **Coverage**: Support all major US cities + international locations

---

## Related Documents

- **Main Plan**: `OVERVIEW_EVOLUTION_PLAN.md`
- **Trace 1**: `TRACE_1_FINGERPRINTING_MIGRATION.md`
- **Trace 3**: `TRACE_3_PROFILE_INTEGRATION_MIGRATION.md`
