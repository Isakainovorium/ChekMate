# Phase 5 Smart Content Intelligence - Firebase Functions

This document describes the Firebase Cloud Functions required to power the three Phase 5 features: Reading Pattern Analysis, Serendipity Mode, and Contextual Follow Suggestions.

## Overview

These functions run server-side aggregation and scoring logic on Firestore data, implementing heuristic "ML-like" behavior that improves as more user data accumulates. They are designed to be deployed as scheduled Firebase Functions that process data periodically.

---

## 1. Reading Pattern Analysis Function

### Function: `aggregateUserBehaviorProfiles`

**Trigger:** Scheduled (runs daily at 2:00 AM UTC)

**Purpose:** Aggregates raw reading events into user behavior profiles with category affinities, emotional intelligence scores, and personalized recommendations.

### Input Collections
- `userReadingEvents/{userId}/events/{eventId}`

### Output Collections
- `userBehaviorProfiles/{userId}`

### Logic

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');

exports.aggregateUserBehaviorProfiles = functions.pubsub
  .schedule('0 2 * * *')
  .timeZone('UTC')
  .onRun(async (context) => {
    const db = admin.firestore();
    const usersSnapshot = await db.collection('users').get();
    
    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;
      
      // Fetch recent reading events (last 90 days)
      const cutoffDate = new Date();
      cutoffDate.setDate(cutoffDate.getDate() - 90);
      
      const eventsSnapshot = await db
        .collection('userReadingEvents')
        .doc(userId)
        .collection('events')
        .where('timestamp', '>=', cutoffDate)
        .get();
      
      if (eventsSnapshot.empty) continue;
      
      const events = eventsSnapshot.docs.map(doc => doc.data());
      
      // Calculate category weights
      const categoryWeights = {};
      const tagDwellTimes = {};
      
      events.forEach(event => {
        const dwellWeight = event.timeSpentMs / 1000; // Convert to seconds
        event.tags.forEach(tag => {
          tagDwellTimes[tag] = (tagDwellTimes[tag] || 0) + dwellWeight;
        });
      });
      
      // Normalize weights
      const totalDwell = Object.values(tagDwellTimes).reduce((a, b) => a + b, 0);
      Object.keys(tagDwellTimes).forEach(tag => {
        categoryWeights[tag] = tagDwellTimes[tag] / totalDwell;
      });
      
      // Get top categories
      const topCategories = Object.entries(categoryWeights)
        .sort((a, b) => b[1] - a[1])
        .slice(0, 5)
        .map(([tag]) => tag);
      
      // Calculate emotional affinity (average sentiment on EI-tagged content)
      const eiEvents = events.filter(e => 
        e.tags.some(tag => tag.toLowerCase().includes('emotional') || 
                          tag.toLowerCase().includes('intelligence'))
      );
      const emotionalAffinity = eiEvents.length > 0
        ? eiEvents.reduce((sum, e) => sum + (e.sentiment || 0), 0) / eiEvents.length
        : 0;
      
      // Calculate learning pace (median session length)
      const sessionLengths = events.map(e => e.timeSpentMs);
      sessionLengths.sort((a, b) => a - b);
      const medianIndex = Math.floor(sessionLengths.length / 2);
      const learningPaceScore = sessionLengths.length > 0
        ? sessionLengths[medianIndex] / 60000 // Convert to minutes
        : 0;
      
      // Recommend tags with low exposure but high category weight
      const recommendedTags = Object.entries(categoryWeights)
        .filter(([tag]) => !topCategories.includes(tag))
        .sort((a, b) => b[1] - a[1])
        .slice(0, 5)
        .map(([tag]) => tag);
      
      // Write profile
      await db.collection('userBehaviorProfiles').doc(userId).set({
        userId,
        topCategories,
        categoryWeights,
        emotionalAffinity: Math.max(0, Math.min(1, emotionalAffinity)),
        learningPaceScore: Math.max(0, Math.min(1, learningPaceScore / 10)),
        recommendedTags,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    
    console.log('User behavior profiles aggregated successfully');
  });
```

---

## 2. Serendipity Recommendations Function

### Function: `generateSerendipityRecommendations`

**Trigger:** Scheduled (runs daily at 3:00 AM UTC)

**Purpose:** Generates diverse content recommendations by scoring posts based on diversity metrics and user behavior profiles.

### Input Collections
- `userBehaviorProfiles/{userId}`
- `posts/{postId}`

### Output Collections
- `serendipityRecommendations/{userId}`

### Logic

```javascript
exports.generateSerendipityRecommendations = functions.pubsub
  .schedule('0 3 * * *')
  .timeZone('UTC')
  .onRun(async (context) => {
    const db = admin.firestore();
    const usersSnapshot = await db.collection('users').get();
    
    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;
      
      // Get user behavior profile
      const profileDoc = await db.collection('userBehaviorProfiles').doc(userId).get();
      if (!profileDoc.exists) continue;
      
      const profile = profileDoc.data();
      const userTopCategories = profile.topCategories || [];
      
      // Fetch candidate posts (recent, high engagement)
      const postsSnapshot = await db
        .collection('posts')
        .orderBy('createdAt', 'desc')
        .limit(500)
        .get();
      
      const posts = postsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
      }));
      
      // Score posts for diversity
      const scoredPosts = posts.map(post => {
        const postTags = post.tags || [];
        
        // Diversity score: penalize overlap with user's top categories
        const overlapCount = postTags.filter(tag => 
          userTopCategories.includes(tag)
        ).length;
        const diversityScore = 1 - (overlapCount / Math.max(postTags.length, 1));
        
        // Boost contrasting attributes
        const contrastBoost = postTags.some(tag => 
          tag.toLowerCase().includes('alternative') || 
          tag.toLowerCase().includes('different')
        ) ? 0.2 : 0;
        
        return {
          postId: post.id,
          score: diversityScore + contrastBoost,
        };
      });
      
      // Sort by diversity score and select top 20
      scoredPosts.sort((a, b) => b.score - a.score);
      const recommendedContentIds = scoredPosts.slice(0, 20).map(p => p.postId);
      
      // Select curated education modules (posts tagged with "education")
      const educationPosts = posts.filter(p => 
        (p.tags || []).some(tag => tag.toLowerCase().includes('education'))
      );
      const curatedModuleIds = educationPosts
        .slice(0, 5)
        .map(p => p.id);
      
      // Calculate overall diversity score
      const avgDiversityScore = scoredPosts.length > 0
        ? scoredPosts.slice(0, 20).reduce((sum, p) => sum + p.score, 0) / 20
        : 0;
      
      // Write recommendations
      await db.collection('serendipityRecommendations').doc(userId).set({
        userId,
        contentIds: recommendedContentIds,
        diversityScore: avgDiversityScore,
        curatedModuleIds,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    
    console.log('Serendipity recommendations generated successfully');
  });
```

---

## 3. Contextual Follow Suggestions Function

### Function: `generateContextualFollowSuggestions`

**Trigger:** Scheduled (runs daily at 4:00 AM UTC)

**Purpose:** Generates smart follow suggestions based on journey matching, topic clustering, and experience correlation.

### Input Collections
- `users/{userId}`
- `posts/{postId}`
- `userBehaviorProfiles/{userId}`

### Output Collections
- `contextualFollowSuggestions` (collection of suggestions)

### Logic

```javascript
exports.generateContextualFollowSuggestions = functions.pubsub
  .schedule('0 4 * * *')
  .timeZone('UTC')
  .onRun(async (context) => {
    const db = admin.firestore();
    const usersSnapshot = await db.collection('users').get();
    const users = usersSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));
    
    for (const user of users) {
      const userId = user.id;
      const userInterests = user.interests || [];
      const userLocation = user.location || '';
      
      // Get user behavior profile
      const profileDoc = await db.collection('userBehaviorProfiles').doc(userId).get();
      const userProfile = profileDoc.exists ? profileDoc.data() : null;
      const userTopCategories = userProfile?.topCategories || [];
      
      // Calculate similarity with other users
      const suggestions = [];
      
      for (const otherUser of users) {
        if (otherUser.id === userId) continue;
        
        const otherInterests = otherUser.interests || [];
        const otherLocation = otherUser.location || '';
        
        // Journey match: shared interests
        const sharedInterests = userInterests.filter(interest => 
          otherInterests.includes(interest)
        );
        
        if (sharedInterests.length >= 2) {
          const similarityScore = sharedInterests.length / 
            Math.max(userInterests.length, otherInterests.length);
          
          suggestions.push({
            userId,
            suggestedUserId: otherUser.id,
            reason: `Shares ${sharedInterests.length} interests with you`,
            similarityScore,
            matchType: 'journeyMatch',
            sharedAttributes: sharedInterests,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
        
        // Topic cluster: similar reading patterns
        const otherProfileDoc = await db.collection('userBehaviorProfiles')
          .doc(otherUser.id).get();
        if (otherProfileDoc.exists) {
          const otherProfile = otherProfileDoc.data();
          const otherTopCategories = otherProfile.topCategories || [];
          
          const sharedCategories = userTopCategories.filter(cat => 
            otherTopCategories.includes(cat)
          );
          
          if (sharedCategories.length >= 2) {
            const topicSimilarity = sharedCategories.length / 
              Math.max(userTopCategories.length, otherTopCategories.length);
            
            suggestions.push({
              userId,
              suggestedUserId: otherUser.id,
              reason: `Similar reading interests in ${sharedCategories[0]}`,
              similarityScore: topicSimilarity,
              matchType: 'topicCluster',
              sharedAttributes: sharedCategories,
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
          }
        }
        
        // Experience correlation: same location
        if (userLocation && otherLocation && userLocation === otherLocation) {
          suggestions.push({
            userId,
            suggestedUserId: otherUser.id,
            reason: `From the same area: ${userLocation}`,
            similarityScore: 0.7,
            matchType: 'experienceCorrelation',
            sharedAttributes: [userLocation],
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
      }
      
      // Sort by similarity score and write top 20
      suggestions.sort((a, b) => b.similarityScore - a.similarityScore);
      const topSuggestions = suggestions.slice(0, 20);
      
      // Delete old suggestions for this user
      const oldSuggestionsSnapshot = await db
        .collection('contextualFollowSuggestions')
        .where('userId', '==', userId)
        .get();
      
      const batch = db.batch();
      oldSuggestionsSnapshot.docs.forEach(doc => batch.delete(doc.ref));
      
      // Write new suggestions
      topSuggestions.forEach(suggestion => {
        const docRef = db.collection('contextualFollowSuggestions').doc();
        batch.set(docRef, suggestion);
      });
      
      await batch.commit();
    }
    
    console.log('Contextual follow suggestions generated successfully');
  });
```

---

## Deployment Instructions

### Prerequisites
1. Firebase CLI installed: `npm install -g firebase-tools`
2. Firebase project initialized with Functions enabled
3. Node.js 18+ runtime configured

### Deployment Steps

1. **Initialize Firebase Functions** (if not already done):
   ```bash
   cd flutter_chekmate
   firebase init functions
   ```

2. **Copy the function code** to `functions/index.js`

3. **Install dependencies**:
   ```bash
   cd functions
   npm install firebase-functions@latest firebase-admin@latest
   ```

4. **Deploy functions**:
   ```bash
   firebase deploy --only functions
   ```

5. **Verify deployment**:
   ```bash
   firebase functions:log
   ```

### Testing

Test functions locally before deployment:

```bash
cd functions
npm run serve
```

### Monitoring

Monitor function execution in Firebase Console:
- Go to Firebase Console → Functions
- Check execution logs and error rates
- Set up alerts for function failures

---

## Performance Considerations

1. **Batch Processing**: Functions process users in batches to avoid timeouts
2. **Indexing**: Ensure Firestore indexes exist for:
   - `userReadingEvents/{userId}/events` ordered by `timestamp`
   - `posts` ordered by `createdAt`
   - `contextualFollowSuggestions` filtered by `userId` and ordered by `similarityScore`

3. **Cost Optimization**:
   - Functions run once daily during low-traffic hours
   - Limit query results to prevent excessive reads
   - Use batch writes to reduce write operations

---

## Future Enhancements

Once real ML models are ready, these functions can be replaced with:
- TensorFlow.js models for behavioral analysis
- Vertex AI endpoints for recommendation generation
- Real-time streaming analytics with Firebase Extensions

The Firestore schema remains unchanged, making the transition seamless.
