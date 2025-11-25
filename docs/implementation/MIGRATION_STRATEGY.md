# Cultural System Migration Strategy
## Comprehensive Playbook for Enum → ML Transition

**Version:** 1.0.0  
**Created:** November 20, 2025  
**Status:** Ready for Execution

---

## Executive Summary

This document provides a detailed migration strategy for transitioning ChekMate's cultural system from enum-based categorical matching to ML-driven free-form pattern recognition. The migration affects **3 core traces** and requires careful orchestration to ensure zero data loss and minimal user disruption.

### Migration Scope

| Component | Current State | Target State | Risk Level |
|-----------|--------------|--------------|------------|
| **Trace 1**: Fingerprinting | Enum extraction + weighted matching | Vector generation + cosine similarity | Medium |
| **Trace 2**: Geographic | Static country mapping | ML location patterns | Low |
| **Trace 3**: Profile Integration | Enum dropdowns | Free-form text inputs | High |

---

## Migration Approach: Parallel Systems

### Strategy Overview

We'll use a **parallel systems approach** where both enum-based and ML-based systems run simultaneously for 4-8 weeks, allowing for:

1. **Gradual user migration** (10% → 50% → 100%)
2. **A/B testing** to validate ML improvements
3. **Rollback capability** if issues arise
4. **Data validation** before deprecating old system

### Timeline

```
Week 1-2:   Infrastructure setup (databases, ML services)
Week 3-4:   Deploy parallel systems (both running)
Week 5-6:   Gradual migration (10% → 50% users)
Week 7-8:   Full migration (100% users)
Week 9-10:  Monitoring & optimization
Week 11-12: Deprecate enum system
```

---

## Phase 1: Infrastructure Setup (Weeks 1-2)

### Database Migrations

**Priority:** Critical  
**Risk:** High (data loss potential)

#### Step 1.1: Add New Columns (Non-Breaking)

```sql
-- Add ML columns to existing tables WITHOUT dropping old columns
ALTER TABLE cultural_profiles
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

-- Keep old enum columns for backward compatibility
-- DO NOT DROP: primary_ethnicity, sub_ethnicities, etc.
```

#### Step 1.2: Create Vector Indexes

```sql
-- Install pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Create vector similarity index
CREATE INDEX idx_cultural_vector_similarity 
  ON cultural_profiles 
  USING ivfflat (cultural_vector vector_cosine_ops)
  WITH (lists = 100);

-- Create text search indexes
CREATE INDEX idx_heritage_description_fts 
  ON cultural_profiles 
  USING gin(to_tsvector('english', heritage_description));
```

#### Step 1.3: Create New Tables

```sql
-- Discovered cultural patterns
CREATE TABLE discovered_cultural_clusters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cluster_identifier VARCHAR(64) UNIQUE NOT NULL,
  member_count INTEGER NOT NULL,
  common_themes TEXT[],
  centroid_vector FLOAT8[384],
  last_updated TIMESTAMP NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Location-based patterns
CREATE TABLE discovered_location_patterns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  location VARCHAR(255) NOT NULL,
  user_count INTEGER NOT NULL,
  common_themes TEXT[],
  centroid_vector FLOAT8[384],
  discovered_at TIMESTAMP NOT NULL,
  is_active BOOLEAN DEFAULT true
);

-- Migration tracking
CREATE TABLE migration_status (
  user_id UUID PRIMARY KEY,
  migration_stage VARCHAR(50) NOT NULL, -- 'pending', 'in_progress', 'completed', 'failed'
  enum_data_backed_up BOOLEAN DEFAULT false,
  vector_generated BOOLEAN DEFAULT false,
  migrated_at TIMESTAMP,
  rollback_data JSONB, -- Store original enum data for rollback
  error_message TEXT
);
```

### ML Infrastructure Deployment

**Priority:** Critical  
**Risk:** Medium

#### Step 1.4: Deploy Vector Embedding Service

**Option A: Self-Hosted (Recommended for cost)**
```bash
# Deploy sentence-transformers model on GPU instance
docker run -d \
  --name embedding-service \
  --gpus all \
  -p 8080:8080 \
  -e MODEL_NAME=all-MiniLM-L6-v2 \
  huggingface/text-embeddings-inference:latest
```

**Option B: Cloud API (Faster setup)**
- Use OpenAI Embeddings API
- Use Cohere Embed API
- Use HuggingFace Inference API

#### Step 1.5: Set Up Vector Database

**Option A: PostgreSQL + pgvector (Recommended)**
- Already integrated with existing DB
- No additional infrastructure
- Good for <1M users

**Option B: Dedicated Vector DB**
- Pinecone (managed, expensive)
- Weaviate (self-hosted, scalable)
- Qdrant (self-hosted, fast)

---

## Phase 2: Parallel System Deployment (Weeks 3-4)

### Dual-Mode Service Architecture

```dart
/// Service that routes to enum or ML system based on user flag
class CulturalMatchingRouter {
  Future<List<String>> findMatchingContent({
    required String userId,
    required Map<String, dynamic> contentPool,
  }) async {
    final user = await _getUserProfile(userId);
    
    // Check migration status
    final migrationStatus = await _getMigrationStatus(userId);
    
    if (migrationStatus.stage == 'completed') {
      // Use ML system
      return await _mlMatchingService.findMatches(
        userVector: user.culturalVector!,
        contentVectors: contentPool,
      );
    } else {
      // Use enum system
      return await _enumMatchingService.findMatches(
        userIdentity: user.culturalIdentity!,
        contentFingerprints: contentPool,
      );
    }
  }
}
```

### Feature Flags

```dart
class FeatureFlags {
  static const String ML_CULTURAL_MATCHING = 'ml_cultural_matching';
  static const String FREE_FORM_ONBOARDING = 'free_form_onboarding';
  static const String LOCATION_PATTERN_DISCOVERY = 'location_pattern_discovery';
  
  static Future<bool> isEnabled(String flag, String userId) async {
    // Check user's feature flag status
    final userFlags = await _fetchUserFlags(userId);
    return userFlags[flag] ?? false;
  }
}
```

### A/B Testing Setup

```dart
class ABTestingService {
  /// Assign users to test groups
  Future<String> assignTestGroup(String userId) async {
    final hash = userId.hashCode % 100;
    
    if (hash < 10) {
      return 'ml_system_10pct'; // 10% ML
    } else if (hash < 50) {
      return 'ml_system_50pct'; // 40% ML (total 50%)
    } else {
      return 'enum_system_control'; // 50% enum (control)
    }
  }
  
  /// Track engagement metrics per group
  Future<void> trackEngagement({
    required String userId,
    required String contentId,
    required String engagementType, // 'view', 'like', 'share'
  }) async {
    final testGroup = await _getTestGroup(userId);
    
    await _analytics.track(
      event: 'content_engagement',
      properties: {
        'user_id': userId,
        'content_id': contentId,
        'engagement_type': engagementType,
        'test_group': testGroup,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
```

---

## Phase 3: Gradual User Migration (Weeks 5-6)

### Migration Waves

#### Wave 1: 10% of Users (Week 5, Days 1-3)

**Target:** New users + power users (high engagement)

```dart
class MigrationWave1 {
  Future<void> execute() async {
    // 1. Identify target users
    final targetUsers = await _identifyWave1Users();
    
    // 2. Backup enum data
    for (final user in targetUsers) {
      await _backupEnumData(user.id);
    }
    
    // 3. Convert enum to text
    for (final user in targetUsers) {
      final textData = await _convertEnumToText(user.culturalIdentity);
      await _storeTextData(user.id, textData);
    }
    
    // 4. Generate vectors
    final vectors = await _generateVectorsBatch(targetUsers);
    await _storeVectors(vectors);
    
    // 5. Update migration status
    for (final user in targetUsers) {
      await _updateMigrationStatus(user.id, 'completed');
    }
    
    // 6. Enable ML matching for these users
    for (final user in targetUsers) {
      await _enableFeatureFlag(user.id, 'ml_cultural_matching');
    }
  }
  
  Future<List<User>> _identifyWave1Users() async {
    // New users (created in last 7 days)
    final newUsers = await db.query(
      'SELECT * FROM users WHERE created_at > NOW() - INTERVAL \'7 days\' LIMIT 1000'
    );
    
    // Power users (high engagement)
    final powerUsers = await db.query(
      'SELECT * FROM users WHERE engagement_score > 0.8 LIMIT 1000'
    );
    
    return [...newUsers, ...powerUsers];
  }
}
```

**Monitoring:**
- Track migration success rate (target: >99%)
- Monitor vector generation latency (target: <500ms)
- Compare engagement: ML vs enum groups

#### Wave 2: 50% of Users (Week 5, Days 4-7)

**Target:** Random sample of remaining users

```dart
class MigrationWave2 {
  Future<void> execute() async {
    final allUsers = await _getAllUsers();
    final wave1Users = await _getWave1Users();
    final remainingUsers = allUsers.where((u) => !wave1Users.contains(u));
    
    // Random sample of 40% (to reach 50% total)
    final wave2Users = _randomSample(remainingUsers, 0.4);
    
    // Same migration steps as Wave 1
    await _migrateUsers(wave2Users);
  }
}
```

**Validation:**
- Compare match quality: ML vs enum
- User feedback surveys
- Engagement metrics comparison

#### Wave 3: 100% of Users (Week 6)

**Target:** All remaining users

```dart
class MigrationWave3 {
  Future<void> execute() async {
    final remainingUsers = await _getUnmigratedUsers();
    
    // Migrate in batches of 1000
    final batches = _createBatches(remainingUsers, 1000);
    
    for (final batch in batches) {
      await _migrateUsers(batch);
      await Future.delayed(Duration(minutes: 5)); // Rate limiting
    }
  }
}
```

---

## Phase 4: Monitoring & Validation (Weeks 7-8)

### Key Metrics Dashboard

```dart
class MigrationMetrics {
  // Migration progress
  int totalUsers;
  int migratedUsers;
  int failedMigrations;
  double migrationSuccessRate;
  
  // Performance metrics
  double avgVectorGenerationTime;
  double avgSimilaritySearchTime;
  double p95VectorGenerationTime;
  double p95SimilaritySearchTime;
  
  // Quality metrics
  double mlMatchEngagementRate;
  double enumMatchEngagementRate;
  double engagementImprovement;
  
  // User satisfaction
  double profileCompletionRate;
  double avgProfileRichness;
  int userFeedbackPositive;
  int userFeedbackNegative;
}
```

### Automated Monitoring

```dart
class MigrationMonitor {
  Future<void> runHealthChecks() async {
    // 1. Data integrity checks
    await _validateDataIntegrity();
    
    // 2. Performance checks
    await _validatePerformance();
    
    // 3. Quality checks
    await _validateMatchQuality();
    
    // 4. Alert if issues detected
    if (_hasIssues()) {
      await _sendAlert();
    }
  }
  
  Future<void> _validateDataIntegrity() async {
    // Check for data loss
    final usersWithEnumData = await db.count('users WHERE primary_ethnicity IS NOT NULL');
    final usersWithVectorData = await db.count('users WHERE cultural_vector IS NOT NULL');
    
    if (usersWithVectorData < usersWithEnumData * 0.95) {
      throw MigrationException('Data loss detected: ${usersWithEnumData - usersWithVectorData} users missing vectors');
    }
  }
  
  Future<void> _validatePerformance() async {
    // Test vector generation speed
    final startTime = DateTime.now();
    await CulturalVectorService.instance.generateCulturalVector(
      heritageDescription: 'Test heritage',
      communityAffiliations: ['Test community'],
      generationalIdentity: 'Test generation',
      culturalPractices: [],
      culturalInterests: [],
      regionalInfluence: null,
    );
    final duration = DateTime.now().difference(startTime);
    
    if (duration.inMilliseconds > 500) {
      throw PerformanceException('Vector generation too slow: ${duration.inMilliseconds}ms');
    }
  }
}
```

---

## Phase 5: Enum System Deprecation (Weeks 9-12)

### Gradual Deprecation

#### Week 9-10: Disable Enum Matching

```dart
// Remove enum-based matching from production
@Deprecated('Enum matching deprecated. All users migrated to ML system.')
class EnumCulturalMatchingService {
  Future<List<String>> findMatches(...) async {
    throw DeprecatedException('This service is no longer available');
  }
}
```

#### Week 11: Remove Enum UI

```dart
// Remove enum dropdown screens
@Deprecated('Use CulturalOnboardingScreen instead')
class InterestsSelectionScreen extends StatelessWidget {
  // Old enum-based UI
}
```

#### Week 12: Database Cleanup

```sql
-- After confirming ML system stable for 4+ weeks
-- Backup old columns first!
CREATE TABLE cultural_profiles_enum_backup AS 
  SELECT user_id, primary_ethnicity, sub_ethnicities, communities, generation, interests
  FROM cultural_profiles;

-- Then drop old columns
ALTER TABLE cultural_profiles
  DROP COLUMN primary_ethnicity,
  DROP COLUMN sub_ethnicities,
  DROP COLUMN communities,
  DROP COLUMN generation,
  DROP COLUMN interests;
```

---

## Rollback Plan

### Trigger Conditions

Rollback if any of these occur:
1. **Data loss**: >1% of users lose cultural data
2. **Performance degradation**: Vector generation >1s or search >500ms
3. **Match quality drop**: Engagement drops >10% vs enum system
4. **User complaints**: >5% negative feedback on new system

### Rollback Procedure

```dart
class RollbackService {
  Future<void> executeRollback() async {
    print('INITIATING ROLLBACK TO ENUM SYSTEM');
    
    // 1. Disable ML matching for all users
    await _disableMLMatching();
    
    // 2. Restore enum data from backup
    await _restoreEnumData();
    
    // 3. Re-enable enum matching service
    await _enableEnumMatching();
    
    // 4. Notify users (if needed)
    await _notifyUsers();
    
    print('ROLLBACK COMPLETE');
  }
  
  Future<void> _restoreEnumData() async {
    await db.execute('''
      UPDATE cultural_profiles cp
      SET 
        primary_ethnicity = ms.rollback_data->>'primary_ethnicity',
        sub_ethnicities = ms.rollback_data->>'sub_ethnicities',
        communities = ms.rollback_data->>'communities',
        generation = ms.rollback_data->>'generation',
        interests = ms.rollback_data->>'interests'
      FROM migration_status ms
      WHERE cp.user_id = ms.user_id
        AND ms.rollback_data IS NOT NULL
    ''');
  }
}
```

---

## Risk Mitigation

### High-Risk Areas

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| Data loss during migration | Low | Critical | Backup all enum data before migration |
| Vector generation service downtime | Medium | High | Deploy redundant embedding services |
| Poor ML match quality | Medium | High | A/B test extensively before full rollout |
| User confusion with free-form input | High | Medium | Clear examples + optional fields |
| Database performance degradation | Low | High | Index optimization + query tuning |

### Contingency Plans

**If vector service fails:**
- Fall back to enum matching automatically
- Queue vector generation for retry
- Alert engineering team

**If match quality is poor:**
- Adjust similarity thresholds
- Retrain embedding model on ChekMate data
- Hybrid approach: ML + enum fallback

**If users don't complete profiles:**
- Make all questions optional
- Show profile richness score as incentive
- Gamify profile completion

---

## Success Criteria

### Technical Success

✅ **Migration completion**: >99% of users successfully migrated  
✅ **Zero data loss**: All enum data preserved or converted  
✅ **Performance**: Vector generation <500ms, search <100ms  
✅ **Uptime**: >99.9% during migration period

### User Success

✅ **Profile completion**: >60% of users complete cultural profile  
✅ **Profile richness**: Average score >0.5  
✅ **User satisfaction**: >80% positive feedback  
✅ **Engagement improvement**: >15% increase vs enum system

### Business Success

✅ **Differentiation**: Unique ML-driven cultural matching  
✅ **Scalability**: Support 100K+ users without code changes  
✅ **Cultural coverage**: Discover 50+ emergent patterns  
✅ **Retention**: No degradation in user retention

---

## Post-Migration Optimization

### Continuous Improvement

**Month 1-3:**
- Monitor discovered patterns
- Adjust similarity thresholds
- Optimize vector search performance

**Month 4-6:**
- Fine-tune embedding model on ChekMate data
- Implement cross-cultural bridge recommendations
- Add multi-language support

**Month 7-12:**
- Advanced pattern discovery
- Emerging trend detection
- International expansion

---

## Communication Plan

### Internal Stakeholders

**Engineering Team:**
- Weekly migration status updates
- Daily monitoring reports during migration
- Incident response procedures

**Product Team:**
- User feedback summaries
- A/B test results
- Feature flag rollout schedule

**Leadership:**
- Monthly progress reports
- Risk assessment updates
- Success metrics dashboard

### External Users

**New Users:**
- Onboarding explains free-form cultural questions
- Examples provided for each question
- "Skip" option clearly visible

**Existing Users:**
- Optional prompt to enrich cultural profile
- Explain benefits of ML matching
- No forced re-onboarding

---

## Conclusion

This migration strategy provides a comprehensive, low-risk path to evolving ChekMate's cultural system from enum-based to ML-driven matching. The parallel systems approach ensures we can validate improvements before fully committing, while the gradual rollout minimizes user disruption.

**Key Success Factors:**
1. Thorough testing at each wave
2. Continuous monitoring and quick rollback capability
3. Clear user communication
4. Data integrity preservation

**Timeline:** 12 weeks from start to enum deprecation  
**Risk Level:** Medium (mitigated by parallel systems)  
**Expected Impact:** 15-20% improvement in match quality

---

## Related Documents

- **Main Plan**: `OVERVIEW_EVOLUTION_PLAN.md`
- **Trace 1**: `TRACE_1_FINGERPRINTING_MIGRATION.md`
- **Trace 2**: `TRACE_2_GEOGRAPHIC_CLASSIFICATION_MIGRATION.md`
- **Trace 3**: `TRACE_3_PROFILE_INTEGRATION_MIGRATION.md`
