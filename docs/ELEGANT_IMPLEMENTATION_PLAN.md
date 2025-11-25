# Elegant Cultural System Implementation

## Philosophy: Progressive Enhancement

Start simple with **free-form text**, evolve to **ML matching**. Three independent layers:

```
Layer 3: ML Intelligence (Future)
Layer 2: Smart Text Matching (Immediate)
Layer 1: Free-Form Collection (Day 1) ← Ship this first
```

---

## Phase 1: Free-Form Collection (Week 1-2)

### New Model

```dart
@JsonSerializable()
class CulturalProfile extends Equatable {
  final String id;
  final String userId;
  
  // User's own words - no dropdowns
  final String? heritageDescription;  // "Jamaican-American, Brooklyn"
  final List<String> communityTags;   // ["Caribbean diaspora", "hip-hop"]
  final String? generationalNotes;    // "Born 2005, TikTok generation"
  final List<String> culturalPractices; // ["dancehall", "Caribbean food"]
  final List<String> interests;       // ["music production", "fashion"]
  final String? regionalContext;      // "NYC, urban Northeast"
  
  final double profileRichness;  // Auto-calculated 0.0-1.0
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

### Database

```sql
CREATE TABLE cultural_profiles (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id) UNIQUE,
  heritage_description TEXT,
  community_tags TEXT[],
  generational_notes TEXT,
  cultural_practices TEXT[],
  interests TEXT[],
  regional_context TEXT,
  profile_richness DECIMAL(3,2),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP
);
```

### Onboarding UI

Open-ended questions with text fields:
- "Tell us about your heritage" → Text input
- "What communities do you connect with?" → Chip input
- "How would you describe your generation?" → Text input
- "What cultural traditions matter to you?" → Chip input
- "What interests resonate with you?" → Chip input

All optional, skippable.

---

## Phase 2: Keyword Matching (Week 3-4)

### Simple Similarity Service

```dart
class CulturalMatchingService {
  double calculateSimilarity(
    CulturalProfile user,
    CulturalProfile creator,
  ) {
    double score = 0.0;
    
    // Heritage text similarity (30%)
    score += _textSimilarity(
      user.heritageDescription,
      creator.heritageDescription,
    ) * 0.30;
    
    // Community tag overlap (25%)
    score += _listOverlap(
      user.communityTags,
      creator.communityTags,
    ) * 0.25;
    
    // Generation similarity (15%)
    score += _textSimilarity(
      user.generationalNotes,
      creator.generationalNotes,
    ) * 0.15;
    
    // Practices overlap (15%)
    score += _listOverlap(
      user.culturalPractices,
      creator.culturalPractices,
    ) * 0.15;
    
    // Interests overlap (15%)
    score += _listOverlap(
      user.interests,
      creator.interests,
    ) * 0.15;
    
    return score;
  }
  
  double _textSimilarity(String? text1, String? text2) {
    if (text1 == null || text2 == null) return 0.0;
    
    final keywords1 = _extractKeywords(text1);
    final keywords2 = _extractKeywords(text2);
    
    final overlap = keywords1.intersection(keywords2).length;
    final total = keywords1.union(keywords2).length;
    
    return total > 0 ? overlap / total : 0.0;
  }
  
  Set<String> _extractKeywords(String text) {
    final stopwords = {'the', 'a', 'and', 'or', 'in', 'on', 'at', 'to'};
    
    return text
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2 && !stopwords.contains(w))
        .toSet();
  }
  
  double _listOverlap(List<String> list1, List<String> list2) {
    final set1 = list1.map((s) => s.toLowerCase()).toSet();
    final set2 = list2.map((s) => s.toLowerCase()).toSet();
    
    final overlap = set1.intersection(set2).length;
    final total = set1.union(set2).length;
    
    return total > 0 ? overlap / total : 0.0;
  }
}
```

---

## Phase 3: ML Enhancement (Month 2-3)

### Backend Vector Service

```python
from sentence_transformers import SentenceTransformer

class CulturalVectorService:
    def __init__(self):
        self.model = SentenceTransformer('all-MiniLM-L6-v2')
    
    def generate_vector(self, profile):
        # Combine all text fields
        text = ' | '.join([
            profile.get('heritage_description', ''),
            ' '.join(profile.get('community_tags', [])),
            profile.get('generational_notes', ''),
            ' '.join(profile.get('cultural_practices', [])),
            ' '.join(profile.get('interests', [])),
        ])
        
        return self.model.encode(text).tolist()
    
    def cosine_similarity(self, vec1, vec2):
        dot = sum(a * b for a, b in zip(vec1, vec2))
        mag1 = sum(a * a for a in vec1) ** 0.5
        mag2 = sum(b * b for b in vec2) ** 0.5
        return dot / (mag1 * mag2) if mag1 * mag2 > 0 else 0.0
```

### Database Migration

```sql
ALTER TABLE cultural_profiles 
ADD COLUMN cultural_vector FLOAT8[];

CREATE INDEX idx_cultural_vector ON cultural_profiles 
USING ivfflat (cultural_vector vector_cosine_ops);
```

### Background Job

```python
def generate_vectors_job():
    """Run every 5 minutes"""
    profiles = db.query("""
        SELECT * FROM cultural_profiles
        WHERE cultural_vector IS NULL
        LIMIT 100
    """)
    
    for profile in profiles:
        vector = service.generate_vector(profile)
        db.execute("""
            UPDATE cultural_profiles
            SET cultural_vector = %s
            WHERE id = %s
        """, (vector, profile['id']))
```

---

## Migration: Coexist with Old System

```dart
class UserCulturalData {
  final CulturalIdentity? legacyEnums;  // Old dropdown system
  final CulturalProfile? freeFormProfile;  // New text system
  
  // Prioritize new, fallback to old
  CulturalProfile? get effectiveProfile {
    if (freeFormProfile != null && freeFormProfile.profileRichness > 0.2) {
      return freeFormProfile;
    }
    
    // Convert legacy enums to text for matching
    return _convertLegacyToText(legacyEnums);
  }
}
```

---

## Summary

**Week 1-2**: Ship free-form collection
**Week 3-4**: Add keyword matching (immediate value)
**Month 2-3**: Layer on ML vectors (future power)

Each layer works independently. Users never see complexity. System gets smarter over time.
