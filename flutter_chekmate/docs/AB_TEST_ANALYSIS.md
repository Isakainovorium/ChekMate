# A/B Test Analysis Guide

**Test Name:** Feed Algorithm Test  
**Variants:** Control (Chronological Feed) vs Variant (Hybrid Feed)  
**Duration:** 1 week minimum  
**Target:** 100% of users (50/50 split)  
**Date Created:** 2025-10-22

---

## 📊 Overview

This document provides SQL queries and analysis methods for the Feed Algorithm A/B test. The test compares:

- **Control Group (50%):** Chronological feed (Following feed)
- **Variant Group (50%):** Hybrid feed (60% location + 40% interests)

**Success Metrics:**
- ✅ 20%+ increase in engagement rate
- ✅ 15%+ increase in session duration
- ✅ No decrease in user retention

---

## 🔧 Setup

### **1. Enable BigQuery Export**

1. Go to Firebase Console → Analytics → BigQuery Linking
2. Enable daily export of analytics data
3. Wait 24 hours for first export
4. Access BigQuery at: https://console.cloud.google.com/bigquery

### **2. Dataset Location**

Your analytics data will be in:
```
Project: chekmate-a0423
Dataset: analytics_XXXXXXXX
Table: events_YYYYMMDD (daily tables)
```

---

## 📈 Key Metrics & Queries

### **1. Engagement Rate by Variant**

**Definition:** Percentage of post views that result in engagement (like, comment, share)

**Firebase Analytics Query (Events Explorer):**
```
Event: post_engaged
Breakdown by: ab_test_variant
Date range: Last 7 days
```

**BigQuery SQL:**
```sql
-- Engagement Rate by Variant
WITH post_views AS (
  SELECT
    user_pseudo_id,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'ab_test_variant') AS variant,
    COUNT(*) AS total_views
  FROM `chekmate-a0423.analytics_*.events_*`
  WHERE event_name = 'post_viewed'
    AND _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY))
                          AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
  GROUP BY user_pseudo_id, variant
),
post_engagements AS (
  SELECT
    user_pseudo_id,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'ab_test_variant') AS variant,
    COUNT(*) AS total_engagements
  FROM `chekmate-a0423.analytics_*.events_*`
  WHERE event_name = 'post_engaged'
    AND _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY))
                          AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
  GROUP BY user_pseudo_id, variant
)
SELECT
  COALESCE(pv.variant, pe.variant) AS variant,
  SUM(COALESCE(pv.total_views, 0)) AS total_views,
  SUM(COALESCE(pe.total_engagements, 0)) AS total_engagements,
  ROUND(SUM(COALESCE(pe.total_engagements, 0)) / NULLIF(SUM(COALESCE(pv.total_views, 0)), 0) * 100, 2) AS engagement_rate_percent
FROM post_views pv
FULL OUTER JOIN post_engagements pe
  ON pv.user_pseudo_id = pe.user_pseudo_id
  AND pv.variant = pe.variant
GROUP BY variant
ORDER BY variant;
```

**Expected Output:**
| variant | total_views | total_engagements | engagement_rate_percent |
|---------|-------------|-------------------|------------------------|
| control | 10,000      | 1,200             | 12.00                  |
| variant | 10,000      | 1,500             | 15.00                  |

**Success Criteria:** Variant engagement rate ≥ Control + 20%

---

### **2. Average Session Duration by Variant**

**Definition:** Average time users spend in the app per session

**Firebase Analytics Query (Events Explorer):**
```
Event: session_duration
Breakdown by: ab_test_variant
Metric: Average duration_seconds
Date range: Last 7 days
```

**BigQuery SQL:**
```sql
-- Average Session Duration by Variant
SELECT
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'ab_test_variant') AS variant,
  COUNT(DISTINCT user_pseudo_id) AS unique_users,
  COUNT(*) AS total_sessions,
  ROUND(AVG((SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'duration_seconds')), 2) AS avg_session_duration_seconds,
  ROUND(AVG((SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'duration_seconds')) / 60, 2) AS avg_session_duration_minutes
FROM `chekmate-a0423.analytics_*.events_*`
WHERE event_name = 'session_duration'
  AND _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY))
                        AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
GROUP BY variant
ORDER BY variant;
```

**Expected Output:**
| variant | unique_users | total_sessions | avg_session_duration_seconds | avg_session_duration_minutes |
|---------|--------------|----------------|------------------------------|------------------------------|
| control | 5,000        | 15,000         | 180.50                       | 3.01                         |
| variant | 5,000        | 15,000         | 210.75                       | 3.51                         |

**Success Criteria:** Variant avg duration ≥ Control + 15%

---

### **3. Posts Viewed Per Session by Variant**

**Definition:** Average number of posts users view per session

**BigQuery SQL:**
```sql
-- Posts Viewed Per Session by Variant
WITH session_posts AS (
  SELECT
    user_pseudo_id,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'ab_test_variant') AS variant,
    DATE(TIMESTAMP_MICROS(event_timestamp)) AS session_date,
    COUNT(DISTINCT (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'post_id')) AS posts_viewed
  FROM `chekmate-a0423.analytics_*.events_*`
  WHERE event_name = 'post_viewed'
    AND _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY))
                          AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
  GROUP BY user_pseudo_id, variant, session_date
)
SELECT
  variant,
  COUNT(*) AS total_sessions,
  SUM(posts_viewed) AS total_posts_viewed,
  ROUND(AVG(posts_viewed), 2) AS avg_posts_per_session,
  MIN(posts_viewed) AS min_posts_per_session,
  MAX(posts_viewed) AS max_posts_per_session
FROM session_posts
GROUP BY variant
ORDER BY variant;
```

**Expected Output:**
| variant | total_sessions | total_posts_viewed | avg_posts_per_session | min | max |
|---------|----------------|--------------------|-----------------------|-----|-----|
| control | 15,000         | 120,000            | 8.00                  | 1   | 50  |
| variant | 15,000         | 150,000            | 10.00                 | 1   | 60  |

**Success Criteria:** Variant avg posts ≥ Control (higher is better)

---

### **4. User Retention by Variant**

**Definition:** Percentage of users who return after N days

**7-Day Retention BigQuery SQL:**
```sql
-- 7-Day Retention by Variant
WITH first_session AS (
  SELECT
    user_pseudo_id,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'ab_test_variant') AS variant,
    MIN(DATE(TIMESTAMP_MICROS(event_timestamp))) AS first_active_date
  FROM `chekmate-a0423.analytics_*.events_*`
  WHERE event_name = 'ab_test_assignment'
    AND _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 14 DAY))
                          AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
  GROUP BY user_pseudo_id, variant
),
returned_users AS (
  SELECT DISTINCT
    user_pseudo_id,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'ab_test_variant') AS variant
  FROM `chekmate-a0423.analytics_*.events_*`
  WHERE event_name IN ('feed_viewed', 'post_viewed')
    AND _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY))
                          AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
)
SELECT
  fs.variant,
  COUNT(DISTINCT fs.user_pseudo_id) AS total_users,
  COUNT(DISTINCT ru.user_pseudo_id) AS retained_users,
  ROUND(COUNT(DISTINCT ru.user_pseudo_id) / COUNT(DISTINCT fs.user_pseudo_id) * 100, 2) AS retention_rate_percent
FROM first_session fs
LEFT JOIN returned_users ru
  ON fs.user_pseudo_id = ru.user_pseudo_id
  AND fs.variant = ru.variant
WHERE DATE_DIFF(CURRENT_DATE(), fs.first_active_date, DAY) >= 7
GROUP BY fs.variant
ORDER BY fs.variant;
```

**30-Day Retention BigQuery SQL:**
```sql
-- 30-Day Retention by Variant (same as above, change interval to 30)
-- Change: DATE_DIFF(CURRENT_DATE(), fs.first_active_date, DAY) >= 30
-- And adjust date ranges accordingly
```

**Expected Output:**
| variant | total_users | retained_users | retention_rate_percent |
|---------|-------------|----------------|------------------------|
| control | 5,000       | 2,500          | 50.00                  |
| variant | 5,000       | 2,750          | 55.00                  |

**Success Criteria:** Variant retention ≥ Control (no decrease)

---

### **5. Feed Scroll Depth by Variant**

**Definition:** How far users scroll in the feed (percentage)

**BigQuery SQL:**
```sql
-- Average Scroll Depth by Variant
SELECT
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'ab_test_variant') AS variant,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'feed_type') AS feed_type,
  COUNT(*) AS total_scroll_events,
  ROUND(AVG((SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'scroll_depth_percent')), 2) AS avg_scroll_depth_percent,
  ROUND(AVG((SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'posts_viewed')), 2) AS avg_posts_viewed
FROM `chekmate-a0423.analytics_*.events_*`
WHERE event_name = 'feed_scroll_depth'
  AND _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY))
                        AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
GROUP BY variant, feed_type
ORDER BY variant, feed_type;
```

---

## 📊 Analysis Dashboard

### **Quick Comparison Table**

| Metric | Control | Variant | Change | Success? |
|--------|---------|---------|--------|----------|
| Engagement Rate | 12.00% | 15.00% | +25.00% | ✅ Yes |
| Avg Session Duration | 3.01 min | 3.51 min | +16.61% | ✅ Yes |
| Posts Per Session | 8.00 | 10.00 | +25.00% | ✅ Yes |
| 7-Day Retention | 50.00% | 55.00% | +10.00% | ✅ Yes |
| 30-Day Retention | 35.00% | 36.00% | +2.86% | ✅ Yes |

---

## 🎯 Decision Framework

### **Rollout Decision Matrix**

**Proceed with Full Rollout if:**
- ✅ Engagement rate increase ≥ 20%
- ✅ Session duration increase ≥ 15%
- ✅ Retention rate stable or improved
- ✅ No critical bugs reported
- ✅ Performance metrics acceptable

**Iterate and Re-test if:**
- ⚠️ Engagement rate increase < 20%
- ⚠️ Session duration increase < 15%
- ⚠️ Retention rate decreased
- ⚠️ Performance issues detected

**Rollback if:**
- ❌ Engagement rate decreased
- ❌ Session duration decreased significantly
- ❌ Retention rate decreased > 5%
- ❌ Critical bugs affecting user experience

---

## 🔍 Firebase Analytics Console (No BigQuery)

If you don't have BigQuery access, use Firebase Analytics Console:

### **1. Events Explorer**

**Path:** Firebase Console → Analytics → Events

**Steps:**
1. Select event name (e.g., `post_engaged`)
2. Add breakdown: `ab_test_variant`
3. Set date range: Last 7 days
4. View metrics: Count, Users, Value

### **2. Custom Reports**

**Path:** Firebase Console → Analytics → Custom Reports

**Create Report:**
1. Name: "A/B Test - Engagement by Variant"
2. Dimensions: `ab_test_variant`, `event_name`
3. Metrics: `Event count`, `Users`
4. Filter: `event_name` in (`post_engaged`, `post_viewed`)

### **3. Audience Comparison**

**Path:** Firebase Console → Analytics → Audiences

**Create Audiences:**
1. **Control Group:**
   - Name: "AB Test - Control"
   - Condition: `ab_test_variant` = `control`

2. **Variant Group:**
   - Name: "AB Test - Variant"
   - Condition: `ab_test_variant` = `variant`

**Compare:**
- Go to Analytics → Audiences
- Select both audiences
- Compare metrics side-by-side

---

## 📊 Visualization Tools

### **Google Data Studio**

**Setup:**
1. Go to: https://datastudio.google.com
2. Create new report
3. Add data source: Firebase Analytics or BigQuery
4. Create charts:
   - Line chart: Engagement rate over time
   - Bar chart: Metrics by variant
   - Table: Detailed comparison

### **Looker Studio Dashboard**

**Pre-built Template:**
```
1. Copy template: [Firebase Analytics Template]
2. Connect to your Firebase project
3. Filter by ab_test_variant
4. Customize metrics and date ranges
```

---

## 🚀 Automated Monitoring

### **Firebase Alerts**

**Setup Custom Alerts:**

**Path:** Firebase Console → Analytics → Custom Definitions → Custom Metrics

**Alert 1: Low Engagement Rate**
- Metric: `post_engaged` / `post_viewed`
- Condition: < 10%
- Notification: Email

**Alert 2: High Session Drop**
- Metric: `session_duration` average
- Condition: Decrease > 20%
- Notification: Email + Slack

### **Daily Summary Script**

**Google Apps Script (runs daily):**
```javascript
function sendDailyABTestSummary() {
  // Connect to BigQuery
  var projectId = 'chekmate-a0423';
  var query = `
    SELECT
      (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'ab_test_variant') AS variant,
      COUNT(*) AS events
    FROM \`chekmate-a0423.analytics_*.events_*\`
    WHERE event_name = 'post_engaged'
      AND _TABLE_SUFFIX = FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY))
    GROUP BY variant
  `;

  var results = BigQuery.Jobs.query({query: query}, projectId);

  // Send email with results
  MailApp.sendEmail({
    to: 'team@chekmate.com',
    subject: 'Daily A/B Test Summary',
    body: JSON.stringify(results, null, 2)
  });
}
```

---

## 📝 Notes

- All queries use 7-day rolling window by default
- Adjust `_TABLE_SUFFIX` date ranges as needed
- Replace `chekmate-a0423` with your actual project ID
- Run queries in BigQuery console or via API
- Export results to Google Sheets for visualization
- Use Firebase Analytics Console if BigQuery is not available
- Set up automated alerts for critical metrics
- Review data daily during first week of test

---

## 📚 Additional Resources

- **Firebase Analytics Documentation:** https://firebase.google.com/docs/analytics
- **BigQuery Documentation:** https://cloud.google.com/bigquery/docs
- **A/B Testing Best Practices:** https://firebase.google.com/docs/ab-testing
- **Statistical Significance Calculator:** https://www.optimizely.com/sample-size-calculator/

---

**Last Updated:** 2025-10-22
**Next Review:** After 1 week of data collection
**Owner:** ChekMate Engineering Team

