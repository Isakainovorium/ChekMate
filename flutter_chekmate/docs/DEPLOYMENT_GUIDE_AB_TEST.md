# A/B Test Deployment Guide

**Test Name:** Feed Algorithm A/B Test  
**Status:** Ready for Deployment  
**Target Date:** TBD  
**Duration:** 1 week minimum  

---

## 📋 Pre-Deployment Checklist

### **1. Code Review** ✅

- [x] All Sprint 6 tasks completed
- [x] Hybrid feed algorithm implemented
- [x] A/B testing infrastructure ready
- [x] Analytics tracking integrated
- [x] Session tracking implemented
- [x] Scroll tracking implemented
- [x] All diagnostics passing

### **2. Testing** ⏳

**Required Tests:**

- [ ] **Unit Tests**
  - [ ] GetHybridFeedUseCase tests
  - [ ] ABTestingService tests
  - [ ] AnalyticsService tests
  - [ ] SessionTrackingService tests
  - [ ] FeedScrollTrackingService tests

- [ ] **Integration Tests**
  - [ ] Feed page with hybrid algorithm
  - [ ] A/B test assignment flow
  - [ ] Analytics event logging
  - [ ] Firestore persistence

- [ ] **Manual Testing**
  - [ ] Create 2 test accounts
  - [ ] Verify different variants assigned
  - [ ] Test all feed types (Hybrid, Following, Nearby, For You)
  - [ ] Verify analytics events in Firebase Console
  - [ ] Test session tracking
  - [ ] Test scroll tracking

### **3. Firebase Configuration** ⏳

- [ ] **Firebase Analytics**
  - [ ] Verify Firebase Analytics enabled
  - [ ] Check event logging in DebugView
  - [ ] Verify custom parameters tracked

- [ ] **BigQuery Export** (Optional but Recommended)
  - [ ] Enable BigQuery linking
  - [ ] Configure daily export
  - [ ] Test query access

- [ ] **Firestore Indexes**
  - [ ] Deploy firestore.indexes.json
  - [ ] Verify indexes created
  - [ ] Test query performance

### **4. Monitoring Setup** ⏳

- [ ] **Firebase Alerts**
  - [ ] Set up engagement rate alert
  - [ ] Set up session duration alert
  - [ ] Configure notification channels

- [ ] **Dashboard**
  - [ ] Create Google Data Studio dashboard
  - [ ] Connect to Firebase Analytics
  - [ ] Add key metrics charts

---

## 🚀 Deployment Steps

### **Step 1: Deploy to Staging (Day 0)**

**1.1 Build and Deploy**
```bash
# Navigate to project directory
cd flutter_chekmate

# Run tests
flutter test

# Build release version
flutter build apk --release  # Android
flutter build ios --release  # iOS

# Deploy to staging environment
# (Your deployment process here)
```

**1.2 Verify Staging**
- [ ] App launches successfully
- [ ] Hybrid feed displays correctly
- [ ] A/B test assignment works
- [ ] Analytics events logged
- [ ] No crashes or errors

**1.3 Staging Test (24 hours)**
- [ ] Monitor Firebase Crashlytics
- [ ] Check Firebase Analytics events
- [ ] Verify A/B test assignments in Firestore
- [ ] Test with 10-20 internal users

---

### **Step 2: Production Deployment (Day 1)**

**2.1 Configure A/B Test Rollout**

**Option A: Gradual Rollout (Recommended)**
```dart
// lib/core/constants/ab_test_variants.dart
static const ABTestConfig feedAlgorithmTest = ABTestConfig(
  testName: ABTestNames.feedAlgorithm,
  isActive: true,
  rolloutPercentage: 25,  // Start with 25% of users
  description: 'Tests chronological feed vs hybrid feed...',
);
```

**Option B: Full Rollout**
```dart
// lib/core/constants/ab_test_variants.dart
static const ABTestConfig feedAlgorithmTest = ABTestConfig(
  testName: ABTestNames.feedAlgorithm,
  isActive: true,
  rolloutPercentage: 100,  // All users in test
  description: 'Tests chronological feed vs hybrid feed...',
);
```

**2.2 Deploy to Production**
```bash
# Build production release
flutter build apk --release
flutter build ios --release

# Deploy to app stores or internal distribution
# (Your deployment process here)
```

**2.3 Verify Production**
- [ ] App available to users
- [ ] Firebase Analytics receiving events
- [ ] A/B test assignments working
- [ ] No critical errors in Crashlytics

---

### **Step 3: Monitor (Days 1-7)**

**Daily Monitoring Tasks:**

**Day 1:**
- [ ] Check Firebase Analytics DebugView
- [ ] Verify events: feed_viewed, post_viewed, post_engaged
- [ ] Check A/B test assignment distribution (should be ~50/50)
- [ ] Monitor Crashlytics for errors
- [ ] Review user feedback

**Days 2-7:**
- [ ] Run daily analytics queries (see AB_TEST_ANALYSIS.md)
- [ ] Update comparison table with latest metrics
- [ ] Monitor engagement rate trend
- [ ] Monitor session duration trend
- [ ] Check retention metrics
- [ ] Review Firebase Crashlytics
- [ ] Check app store reviews

**Daily Query Checklist:**
```bash
# Run these queries daily in BigQuery
1. Engagement Rate by Variant
2. Average Session Duration by Variant
3. Posts Viewed Per Session by Variant
4. Feed Scroll Depth by Variant

# Run these queries on Day 7
5. 7-Day Retention by Variant
```

---

### **Step 4: Analysis (Day 8)**

**4.1 Collect Final Metrics**

Run all queries from `docs/AB_TEST_ANALYSIS.md`:
- [ ] Engagement rate by variant
- [ ] Session duration by variant
- [ ] Posts viewed per session by variant
- [ ] 7-day retention by variant
- [ ] Feed scroll depth by variant

**4.2 Fill Comparison Table**

| Metric | Control | Variant | Change | Success? |
|--------|---------|---------|--------|----------|
| Engagement Rate | __%  | __%  | __% | ☐ |
| Avg Session Duration | __ min | __ min | __% | ☐ |
| Posts Per Session | __ | __ | __% | ☐ |
| 7-Day Retention | __%  | __%  | __% | ☐ |
| Avg Scroll Depth | __%  | __%  | __% | ☐ |

**4.3 Statistical Significance**

Use online calculator: https://www.optimizely.com/sample-size-calculator/

- [ ] Calculate p-value for engagement rate
- [ ] Calculate p-value for session duration
- [ ] Verify statistical significance (p < 0.05)

---

### **Step 5: Decision (Day 8-9)**

**Decision Framework:**

**✅ PROCEED WITH FULL ROLLOUT IF:**
- Engagement rate increase ≥ 20% AND statistically significant
- Session duration increase ≥ 15% AND statistically significant
- Retention rate stable or improved
- No critical bugs reported
- Performance metrics acceptable
- Positive user feedback

**⚠️ ITERATE AND RE-TEST IF:**
- Engagement rate increase 10-19%
- Session duration increase 5-14%
- Mixed results across metrics
- Minor bugs reported
- Performance concerns

**❌ ROLLBACK IF:**
- Engagement rate decreased
- Session duration decreased > 10%
- Retention rate decreased > 5%
- Critical bugs affecting UX
- Significant performance degradation
- Negative user feedback

---

### **Step 6: Rollout or Rollback (Day 9+)**

**If PROCEED:**

**6.1 Increase Rollout to 100%**
```dart
// lib/core/constants/ab_test_variants.dart
static const ABTestConfig feedAlgorithmTest = ABTestConfig(
  testName: ABTestNames.feedAlgorithm,
  isActive: true,
  rolloutPercentage: 100,  // All users
  description: 'Tests chronological feed vs hybrid feed...',
);
```

**6.2 Deploy Update**
```bash
flutter build apk --release
flutter build ios --release
# Deploy to production
```

**6.3 Monitor for 3 Days**
- [ ] Verify metrics remain positive
- [ ] Monitor for any issues
- [ ] Collect user feedback

**6.4 Make Hybrid Feed Default**
```dart
// lib/features/feed/pages/feed_page.dart
// Already set to FeedType.hybrid by default ✅
```

**If ROLLBACK:**

**6.1 Disable A/B Test**
```dart
// lib/core/constants/ab_test_variants.dart
static const ABTestConfig feedAlgorithmTest = ABTestConfig(
  testName: ABTestNames.feedAlgorithm,
  isActive: false,  // Disable test
  rolloutPercentage: 0,
  description: 'Tests chronological feed vs hybrid feed...',
);
```

**6.2 Revert to Chronological Feed**
```dart
// lib/features/feed/pages/feed_page.dart
class _FeedPageState extends ConsumerState<FeedPage> {
  FeedType _feedType = FeedType.following; // Revert to chronological
  // ...
}
```

**6.3 Deploy Rollback**
```bash
flutter build apk --release
flutter build ios --release
# Deploy to production
```

**6.4 Analyze Failure**
- [ ] Review all metrics
- [ ] Identify root causes
- [ ] Plan improvements
- [ ] Schedule re-test

---

## 📊 Success Metrics Summary

**Primary Metrics:**
- **Engagement Rate:** Target ≥ 20% increase
- **Session Duration:** Target ≥ 15% increase
- **User Retention:** Target no decrease

**Secondary Metrics:**
- Posts viewed per session
- Feed scroll depth
- User feedback sentiment

**Technical Metrics:**
- App crash rate
- API response time
- Feed load time

---

## 📝 Post-Deployment Report Template

```markdown
# A/B Test Results Report

**Test Period:** [Start Date] - [End Date]
**Total Users:** [Number]
**Control Group:** [Number] users
**Variant Group:** [Number] users

## Results

| Metric | Control | Variant | Change | Significant? |
|--------|---------|---------|--------|--------------|
| Engagement Rate | __% | __% | __% | Yes/No |
| Session Duration | __ min | __ min | __% | Yes/No |
| Posts Per Session | __ | __ | __% | Yes/No |
| 7-Day Retention | __% | __% | __% | Yes/No |

## Decision

☐ Proceed with full rollout
☐ Iterate and re-test
☐ Rollback

**Rationale:** [Explanation]

## Next Steps

1. [Action item 1]
2. [Action item 2]
3. [Action item 3]

**Prepared by:** [Name]
**Date:** [Date]
```

---

## 🔗 Resources

- **Analytics Queries:** `docs/AB_TEST_ANALYSIS.md`
- **Firebase Console:** https://console.firebase.google.com/project/chekmate-a0423
- **BigQuery Console:** https://console.cloud.google.com/bigquery
- **Statistical Calculator:** https://www.optimizely.com/sample-size-calculator/

---

**Last Updated:** 2025-10-22  
**Owner:** ChekMate Engineering Team  
**Status:** Ready for Deployment

