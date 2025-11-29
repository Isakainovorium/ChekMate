# Trace 3: Profile Integration Migration Guide
## From Enum-Based Interests to Free-Form Cultural Expression

**Trace ID:** 3  
**Current Files:**
- `cultural_identity_model.dart` (enum-based interests)
- `cultural_context_model.dart` (context integration)
- `profile_entity.dart` (basic profile structure)
- `welcome_screen.dart` (onboarding flow)

**Status:** Enum dropdowns with predefined categories  
**Target:** Free-form text inputs with ML-driven matching

---

## Current Implementation Analysis

### Location 3a: Onboarding Flow Init
**File:** `welcome_screen.dart:12`

```dart
void _handleGetStarted(BuildContext context) {
  context.go('/onboarding/interests');
}
```

**Current Behavior:**
- Navigates to interests selection screen
- Likely shows dropdown/checkbox UI for predefined interests
- Forces users into preset categories

**Target Behavior:**
- Navigate to free-form cultural questions screen
- Text input fields for open-ended responses
- Optional questions, can skip any

---

### Location 3b: Profile Interest Storage
**File:** `profile_entity.dart:28`

```dart
this.interests = const [],
```

**Current Behavior:**
- Stores list of enum values or strings
- Limited to predefined interest categories
- No rich cultural description

**Target Behavior:**
- Store free-form text descriptions
- Include cultural vector embedding
- Track profile richness score

---

### Location 3c: Cultural Interest Enum
**File:** `cultural_identity_model.dart:16`

```dart
this.interests = const [],
```

**Current Behavior:**
- Uses `CulturalInterest` enum (e.g., `CulturalInterest.hipHop`)
- Predefined list of ~30 interests
- Can't express nuanced or emerging interests

**Target Behavior:**
- Free-form text list
- Users describe interests in their own words
- System learns patterns from aggregated data

---

### Location 3d: Context Cultural Integration
**File:** `cultural_context_model.dart:39`

```dart
@JsonKey(name: 'cultural_identity')
final CulturalIdentity? culturalIdentity;
```

**Current Behavior:**
- Links content to creator's enum-based cultural identity
- Structured data model with predefined fields
- Limited expressiveness

**Target Behavior:**
- Links to creator's free-form cultural profile
- Includes cultural vector for matching
- Supports rich, nuanced cultural expression

---

## Migration Implementation

### Step 1: Update Cultural Identity Model

**Modified File:** `cultural_identity_model.dart`

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cultural_identity_model.g.dart';

/// Free-form cultural identity model (ML-driven)
@JsonSerializable()
class CulturalProfile extends Equatable {
  final String id;
  final String userId;
  
  // Free-form user inputs (their own words)
  @JsonKey(name: 'heritage_description')
  final String? heritageDescription;
  
  @JsonKey(name: 'community_affiliations')
  final List<String> communityAffiliations;
  
  @JsonKey(name: 'generational_identity')
  final String? generationalIdentity;
  
  @JsonKey(name: 'cultural_practices')
  final List<String> culturalPractices;
  
  @JsonKey(name: 'cultural_interests')
  final List<String> culturalInterests; // Now free-form strings!
  
  @JsonKey(name: 'regional_influence')
  final String? regionalInfluence;
  
  // System-generated (invisible to user)
  @JsonKey(name: 'cultural_vector')
  final List<double>? culturalVector;
  
  @JsonKey(name: 'discovered_clusters')
  final List<String> discoveredClusters;
  
  @JsonKey(name: 'affinity_scores')
  final Map<String, double> affinityScores;
  
  @JsonKey(name: 'last_vector_update')
  final DateTime? lastVectorUpdate;
  
  @JsonKey(name: 'profile_richness')
  final double profileRichness;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  
  const CulturalProfile({
    required this.id,
    required this.userId,
    this.heritageDescription,
    this.communityAffiliations = const [],
    this.generationalIdentity,
    this.culturalPractices = const [],
    this.culturalInterests = const [],
    this.regionalInfluence,
    this.culturalVector,
    this.discoveredClusters = const [],
    this.affinityScores = const {},
    this.lastVectorUpdate,
    this.profileRichness = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory CulturalProfile.fromJson(Map<String, dynamic> json) =>
      _$CulturalProfileFromJson(json);
  
  Map<String, dynamic> toJson() => _$CulturalProfileToJson(this);
  
  @override
  List<Object?> get props => [
        id,
        userId,
        heritageDescription,
        communityAffiliations,
        generationalIdentity,
        culturalPractices,
        culturalInterests,
        regionalInfluence,
        culturalVector,
        discoveredClusters,
        affinityScores,
        lastVectorUpdate,
        profileRichness,
        createdAt,
        updatedAt,
      ];
  
  /// Calculate profile richness based on input completeness
  static double calculateRichness(CulturalProfile profile) {
    double richness = 0.0;
    
    // Each field contributes to richness
    if (profile.heritageDescription?.isNotEmpty ?? false) {
      richness += 0.25 * _calculateTextRichness(profile.heritageDescription!);
    }
    if (profile.communityAffiliations.isNotEmpty) {
      richness += 0.20 * (profile.communityAffiliations.length / 5).clamp(0, 1);
    }
    if (profile.generationalIdentity?.isNotEmpty ?? false) {
      richness += 0.15 * _calculateTextRichness(profile.generationalIdentity!);
    }
    if (profile.culturalPractices.isNotEmpty) {
      richness += 0.20 * (profile.culturalPractices.length / 5).clamp(0, 1);
    }
    if (profile.culturalInterests.isNotEmpty) {
      richness += 0.20 * (profile.culturalInterests.length / 5).clamp(0, 1);
    }
    
    return richness.clamp(0.0, 1.0);
  }
  
  static double _calculateTextRichness(String text) {
    final wordCount = text.split(' ').length;
    return (wordCount / 20).clamp(0, 1); // 20+ words = full score
  }
  
  /// Create copy with updated fields
  CulturalProfile copyWith({
    String? heritageDescription,
    List<String>? communityAffiliations,
    String? generationalIdentity,
    List<String>? culturalPractices,
    List<String>? culturalInterests,
    String? regionalInfluence,
    List<double>? culturalVector,
    List<String>? discoveredClusters,
    Map<String, double>? affinityScores,
    DateTime? lastVectorUpdate,
    double? profileRichness,
  }) {
    return CulturalProfile(
      id: id,
      userId: userId,
      heritageDescription: heritageDescription ?? this.heritageDescription,
      communityAffiliations: communityAffiliations ?? this.communityAffiliations,
      generationalIdentity: generationalIdentity ?? this.generationalIdentity,
      culturalPractices: culturalPractices ?? this.culturalPractices,
      culturalInterests: culturalInterests ?? this.culturalInterests,
      regionalInfluence: regionalInfluence ?? this.regionalInfluence,
      culturalVector: culturalVector ?? this.culturalVector,
      discoveredClusters: discoveredClusters ?? this.discoveredClusters,
      affinityScores: affinityScores ?? this.affinityScores,
      lastVectorUpdate: lastVectorUpdate ?? this.lastVectorUpdate,
      profileRichness: profileRichness ?? this.profileRichness,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

// KEEP OLD MODEL for backward compatibility during migration
@Deprecated('Use CulturalProfile instead')
@JsonSerializable()
class CulturalIdentity extends Equatable {
  // Existing enum-based implementation
  // Will be removed after migration
}
```

---

### Step 2: Update Profile Entity

**Modified File:** `profile_entity.dart`

```dart
import 'package:flutter_chekmate/features/cultural/models/cultural_identity_model.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String userId;
  final String? displayName;
  final int? age;
  final String? gender;
  final String? location;
  
  // OLD: Basic interests list
  @Deprecated('Use culturalProfile instead')
  final List<String> interests;
  
  // NEW: Rich cultural profile
  final CulturalProfile? culturalProfile;
  
  final List<String> voicePrompts;
  final String? videoIntroUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const ProfileEntity({
    required this.id,
    required this.userId,
    this.displayName,
    this.age,
    this.gender,
    this.location,
    this.interests = const [],
    this.culturalProfile,
    this.voicePrompts = const [],
    this.videoIntroUrl,
    required this.createdAt,
    required this.updatedAt,
  });
  
  @override
  List<Object?> get props => [
        id,
        userId,
        displayName,
        age,
        gender,
        location,
        interests,
        culturalProfile,
        voicePrompts,
        videoIntroUrl,
        createdAt,
        updatedAt,
      ];
  
  /// Check if user has completed cultural profile
  bool get hasCulturalProfile => culturalProfile != null;
  
  /// Get profile richness score
  double get culturalProfileRichness => 
      culturalProfile?.profileRichness ?? 0.0;
}
```

---

### Step 3: Create New Onboarding Flow

**New File:** `cultural_onboarding_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_chekmate/features/cultural/models/cultural_identity_model.dart';
import 'package:flutter_chekmate/core/services/cultural/cultural_vector_service.dart';

/// Free-form cultural onboarding screen
class CulturalOnboardingScreen extends StatefulWidget {
  const CulturalOnboardingScreen({super.key});
  
  @override
  State<CulturalOnboardingScreen> createState() => 
      _CulturalOnboardingScreenState();
}

class _CulturalOnboardingScreenState extends State<CulturalOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heritageController = TextEditingController();
  final _communitiesController = TextEditingController();
  final _generationController = TextEditingController();
  final _practicesController = TextEditingController();
  final _interestsController = TextEditingController();
  final _regionalController = TextEditingController();
  
  int _currentStep = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tell Us About Your Culture'),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        steps: [
          Step(
            title: const Text('Heritage'),
            content: _buildHeritageStep(),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Communities'),
            content: _buildCommunitiesStep(),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Generation'),
            content: _buildGenerationStep(),
            isActive: _currentStep >= 2,
          ),
          Step(
            title: const Text('Practices'),
            content: _buildPracticesStep(),
            isActive: _currentStep >= 3,
          ),
          Step(
            title: const Text('Interests'),
            content: _buildInterestsStep(),
            isActive: _currentStep >= 4,
          ),
          Step(
            title: const Text('Regional Influence'),
            content: _buildRegionalStep(),
            isActive: _currentStep >= 5,
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeritageStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Where is your family from?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tell us about your heritage in your own words. This is completely optional.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _heritageController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'e.g., "My parents are from Jamaica, I grew up in Brooklyn"',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => _currentStep++,
          child: const Text('Skip this question'),
        ),
      ],
    );
  }
  
  Widget _buildCommunitiesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What communities do you belong to?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'List communities, groups, or cultures you identify with (comma-separated)',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _communitiesController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'e.g., "Caribbean diaspora, hip-hop culture, young professionals"',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => _currentStep++,
          child: const Text('Skip this question'),
        ),
      ],
    );
  }
  
  Widget _buildGenerationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How would you describe your generation?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tell us about your age group or generation in your own words',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _generationController,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'e.g., "Born in 2005, grew up with TikTok and Instagram"',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => _currentStep++,
          child: const Text('Skip this question'),
        ),
      ],
    );
  }
  
  Widget _buildPracticesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What cultural traditions matter to you?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'List cultural practices, traditions, or customs (comma-separated)',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _practicesController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'e.g., "Dancehall music, Caribbean food, staying connected to roots"',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => _currentStep++,
          child: const Text('Skip this question'),
        ),
      ],
    );
  }
  
  Widget _buildInterestsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What cultural interests resonate with you?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'List cultural expressions, art forms, or interests (comma-separated)',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _interestsController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'e.g., "Music production, street fashion, Caribbean festivals"',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => _currentStep++,
          child: const Text('Skip this question'),
        ),
      ],
    );
  }
  
  Widget _buildRegionalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Where did you grow up?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tell us about the place that shaped you',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _regionalController,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'e.g., "Brooklyn, NYC - urban East Coast culture"',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _submitProfile,
          child: const Text('Skip this question'),
        ),
      ],
    );
  }
  
  void _onStepContinue() {
    if (_currentStep < 5) {
      setState(() => _currentStep++);
    } else {
      _submitProfile();
    }
  }
  
  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }
  
  Future<void> _submitProfile() async {
    // Parse comma-separated lists
    final communities = _communitiesController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    
    final practices = _practicesController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    
    final interests = _interestsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    
    // Generate cultural vector
    final vector = await CulturalVectorService.instance.generateCulturalVector(
      heritageDescription: _heritageController.text.isNotEmpty 
          ? _heritageController.text 
          : null,
      communityAffiliations: communities,
      generationalIdentity: _generationController.text.isNotEmpty 
          ? _generationController.text 
          : null,
      culturalPractices: practices,
      culturalInterests: interests,
      regionalInfluence: _regionalController.text.isNotEmpty 
          ? _regionalController.text 
          : null,
    );
    
    // Create cultural profile
    final profile = CulturalProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user_id', // Get from auth
      heritageDescription: _heritageController.text.isNotEmpty 
          ? _heritageController.text 
          : null,
      communityAffiliations: communities,
      generationalIdentity: _generationController.text.isNotEmpty 
          ? _generationController.text 
          : null,
      culturalPractices: practices,
      culturalInterests: interests,
      regionalInfluence: _regionalController.text.isNotEmpty 
          ? _regionalController.text 
          : null,
      culturalVector: vector,
      profileRichness: CulturalProfile.calculateRichness(
        CulturalProfile(
          id: '',
          userId: '',
          heritageDescription: _heritageController.text.isNotEmpty 
              ? _heritageController.text 
              : null,
          communityAffiliations: communities,
          generationalIdentity: _generationController.text.isNotEmpty 
              ? _generationController.text 
              : null,
          culturalPractices: practices,
          culturalInterests: interests,
          regionalInfluence: _regionalController.text.isNotEmpty 
              ? _regionalController.text 
              : null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Save to database
    await _saveCulturalProfile(profile);
    
    // Navigate to next screen
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
  
  Future<void> _saveCulturalProfile(CulturalProfile profile) async {
    // Implement database save logic
  }
  
  @override
  void dispose() {
    _heritageController.dispose();
    _communitiesController.dispose();
    _generationController.dispose();
    _practicesController.dispose();
    _interestsController.dispose();
    _regionalController.dispose();
    super.dispose();
  }
}
```

---

### Step 4: Update Welcome Screen

**Modified File:** `welcome_screen.dart`

```dart
void _handleGetStarted(BuildContext context) {
  // NEW: Navigate to free-form cultural onboarding
  context.go('/onboarding/cultural');
  
  // OLD: Navigate to enum-based interests
  // context.go('/onboarding/interests');
}
```

---

## Database Schema Updates

```sql
-- Add cultural profile fields to users table
ALTER TABLE users
  ADD COLUMN heritage_description TEXT,
  ADD COLUMN community_affiliations TEXT[],
  ADD COLUMN generational_identity TEXT,
  ADD COLUMN cultural_practices TEXT[],
  ADD COLUMN cultural_interests TEXT[],
  ADD COLUMN regional_influence TEXT,
  ADD COLUMN cultural_vector FLOAT8[384],
  ADD COLUMN discovered_clusters TEXT[],
  ADD COLUMN affinity_scores JSONB,
  ADD COLUMN last_vector_update TIMESTAMP,
  ADD COLUMN profile_richness DECIMAL(3,2);

-- Keep old interests column during migration
-- ALTER TABLE users DROP COLUMN interests; (after migration)
```

---

## Migration Script

**New File:** `scripts/migrate_profile_interests.dart`

```dart
/// Migrate enum-based interests to free-form cultural profiles
class ProfileMigrationScript {
  Future<void> migrateAllProfiles() async {
    print('Starting profile migration...');
    
    // 1. Fetch all user profiles with enum interests
    final profiles = await _fetchAllProfiles();
    print('Found ${profiles.length} profiles to migrate');
    
    // 2. Convert enum interests to free-form text
    for (final profile in profiles) {
      final freeFormInterests = _convertEnumInterests(profile.interests);
      
      // 3. Generate cultural vector
      final vector = await CulturalVectorService.instance.generateCulturalVector(
        heritageDescription: null, // Not in old system
        communityAffiliations: [],
        generationalIdentity: null,
        culturalPractices: [],
        culturalInterests: freeFormInterests,
        regionalInfluence: profile.location,
      );
      
      // 4. Create new cultural profile
      final culturalProfile = CulturalProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: profile.userId,
        culturalInterests: freeFormInterests,
        regionalInfluence: profile.location,
        culturalVector: vector,
        profileRichness: CulturalProfile.calculateRichness(
          CulturalProfile(
            id: '',
            userId: '',
            culturalInterests: freeFormInterests,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // 5. Save to database
      await _saveCulturalProfile(culturalProfile);
    }
    
    print('Migration complete!');
  }
  
  List<String> _convertEnumInterests(List<String> enumInterests) {
    final textMap = {
      'hipHop': 'Hip-hop culture',
      'jazzBlues': 'Jazz and blues music',
      'reggaeton': 'Reggaeton music',
      'kPop': 'K-pop music',
      'traditionalFolk': 'Traditional folk music',
      'visualArts': 'Visual arts',
      'streetArt': 'Street art',
      'filmCinema': 'Film and cinema',
      'soulFood': 'Soul food cuisine',
      // ... add all enum mappings
    };
    
    return enumInterests
        .map((e) => textMap[e] ?? e)
        .toList();
  }
  
  Future<List<ProfileEntity>> _fetchAllProfiles() async {
    // Implement database fetch
  }
  
  Future<void> _saveCulturalProfile(CulturalProfile profile) async {
    // Implement database save
  }
}
```

---

## Testing Strategy

```dart
// test/screens/cultural_onboarding_test.dart
void main() {
  group('CulturalOnboardingScreen', () {
    testWidgets('allows skipping all questions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: CulturalOnboardingScreen()),
      );
      
      // Skip all steps
      for (int i = 0; i < 6; i++) {
        await tester.tap(find.text('Skip this question'));
        await tester.pumpAndSettle();
      }
      
      // Should still create profile (with empty data)
      verify(mockProfileService.createProfile(any)).called(1);
    });
    
    testWidgets('calculates profile richness correctly', (tester) async {
      final profile = CulturalProfile(
        id: '1',
        userId: '1',
        heritageDescription: 'Jamaican-American heritage from Brooklyn',
        communityAffiliations: ['Caribbean diaspora', 'Hip-hop culture'],
        generationalIdentity: 'Gen Z',
        culturalPractices: ['Dancehall music'],
        culturalInterests: ['Music production', 'Street fashion'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final richness = CulturalProfile.calculateRichness(profile);
      expect(richness, greaterThan(0.7)); // Should be high richness
    });
  });
}
```

---

## Rollout Plan

### Week 1-2: Model & Database Updates
- Update `CulturalProfile` model
- Migrate database schema
- Create backward compatibility layer

### Week 3-4: Onboarding UI
- Build `CulturalOnboardingScreen`
- Design free-form input UX
- A/B test with 10% of new users

### Week 5-6: Profile Migration
- Migrate existing enum data to text
- Generate vectors for all users
- Validate migration accuracy

### Week 7-8: Full Rollout
- Switch all users to new onboarding
- Deprecate enum-based system
- Monitor completion rates

---

## Success Criteria

✅ **Onboarding completion**: > 60% (vs enum-based)  
✅ **Profile richness**: Average > 0.5  
✅ **User satisfaction**: > 80% prefer free-form input  
✅ **Data quality**: 90% of profiles have meaningful text  
✅ **Zero data loss**: All enum data successfully converted

---

## Related Documents

- **Main Plan**: `OVERVIEW_EVOLUTION_PLAN.md`
- **Trace 1**: `TRACE_1_FINGERPRINTING_MIGRATION.md`
- **Trace 2**: `TRACE_2_GEOGRAPHIC_CLASSIFICATION_MIGRATION.md`
