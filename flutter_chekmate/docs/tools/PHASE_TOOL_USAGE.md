# Phase-Specific MCP Tool Usage Guide

**Last Updated:** October 17, 2025  
**Purpose:** Detailed tool usage recommendations for each development phase  
**Status:** Active

---

## 📋 TABLE OF CONTENTS

1. [Phase 1: Foundation](#phase-1-foundation)
2. [Phase 2: Voice/Video Features](#phase-2-voicevideo-features)
3. [Phase 3: Multi-Photo Posts](#phase-3-multi-photo-posts)
4. [Phase 4: FCM & Notifications](#phase-4-fcm--notifications)
5. [Phase 5: Production Polish](#phase-5-production-polish)
6. [End-of-Phase Visual Testing](#end-of-phase-visual-testing)

---

## PHASE 1: FOUNDATION ✅ COMPLETE

### **Tools Used**

| Tool | Usage | Frequency |
|------|-------|-----------|
| CircleCI | Pipeline setup, test automation | High |
| LangChain | Firebase documentation | Medium |
| Context7 | Package references | Medium |
| Exa | Not used | - |
| Playwright | Not used (planned) | - |

### **Key Activities**

1. **CircleCI Pipeline Setup**
   - Created `.circleci/config.yml`
   - Configured 7 jobs, 2 workflows
   - Set up coverage reporting (15% threshold)

2. **Documentation Access**
   - LangChain: Firebase setup guides
   - Context7: firebase_auth, cloud_firestore API references

3. **Testing Foundation**
   - 113 tests created
   - 15%+ coverage achieved
   - All tests passing

### **Tool Queries Used**

```
"Get Context7 documentation for firebase_auth"
"Get Context7 documentation for flutter_riverpod"
"Validate CircleCI config"
"Trigger CircleCI pipeline"
"Check CircleCI pipeline status"
```

### **Visual Testing Baseline**

**Playwright Setup (Completed):**
- ✅ Captured login page baseline
- ✅ Captured signup page baseline
- ✅ Captured home screen baseline

**Baseline Screenshots:**
```
test/visual/phase1_baseline/
├── login_page.png
├── signup_page.png
└── home_empty.png
```

---

## PHASE 2: VOICE/VIDEO FEATURES (NEXT)

### **Recommended Tool Usage**

| Tool | Primary Use Cases | Priority |
|------|------------------|----------|
| **Context7** | agora_rtc_engine, camera, record API docs | 🔴 Critical |
| **Exa** | Find iOS/Android permission issues | 🔴 Critical |
| **LangChain** | Flutter camera/microphone guides | 🟡 High |
| **CircleCI** | Automated testing for voice/video | 🔴 Critical |
| **Playwright** | Visual testing for UI components | 🟡 High |

### **Implementation Workflow**

#### **Week 1: Voice Messages**

**Day 1-2: Research & Planning**
```
1. Context7: "Get Context7 documentation for record"
2. Context7: "Get Context7 documentation for audioplayers"
3. Context7: "Get Context7 documentation for permission_handler focusing on microphone"
4. Exa: "Use Exa to search for Flutter audio recording best practices 2025"
5. Exa: "Use Exa to find Flutter voice message UI examples"
```

**Day 3-4: Implementation**
```
1. Codebase Retrieval: "Find existing permission handling"
2. Context7: "Get Context7 documentation for path_provider"
3. Implement voice recording
4. Implement voice playback
```

**Day 5: Testing**
```
1. Write unit tests for voice recording
2. Write widget tests for voice UI
3. CircleCI: "Trigger CircleCI pipeline"
4. Playwright: Capture voice UI screenshots
```

#### **Week 2: Video Calls**

**Day 1-2: Research & Planning**
```
1. Context7: "Get Context7 documentation for agora_rtc_engine"
2. Exa: "Use Exa to search GitHub for agora_rtc_engine Flutter examples"
3. Exa: "Use Exa to find agora_rtc_engine iOS permission issues from last 30 days"
4. LangChain: "Get Flutter camera plugin setup guide"
```

**Day 3-5: Implementation**
```
1. Context7: "Get Context7 documentation for camera"
2. Implement video call initiation
3. Implement video call UI
4. Handle permissions (iOS/Android)
```

**Day 6-7: Testing & Visual Validation**
```
1. Write integration tests
2. CircleCI: "Trigger CircleCI pipeline"
3. Playwright: Run visual regression tests
4. Fix any visual regressions
```

### **Expected Exa Queries**

```
"Use Exa to search for Flutter agora_rtc_engine iOS permission issues from last 30 days"
"Use Exa to find WebRTC Flutter implementation examples"
"Use Exa to search Stack Overflow for camera plugin Flutter 3.24 issues"
"Use Exa to find Flutter video compression best practices"
"Use Exa to search for Flutter audio recording UI examples"
"Use Exa to find agora_rtc_engine Android permission handling"
```

### **Expected Context7 Queries**

```
"Get Context7 documentation for agora_rtc_engine"
"Get Context7 documentation for camera focusing on iOS setup"
"Get Context7 documentation for record focusing on audio formats"
"Get Context7 documentation for audioplayers focusing on playback controls"
"Get Context7 documentation for permission_handler focusing on camera and microphone"
"Get Context7 documentation for path_provider"
```

### **CircleCI Integration**

**New Jobs to Add:**
```yaml
voice_tests:
  executor: flutter-executor
  steps:
    - setup_flutter
    - run:
        name: "Run Voice Feature Tests"
        command: flutter test test/features/voice/

video_tests:
  executor: flutter-executor
  steps:
    - setup_flutter
    - run:
        name: "Run Video Feature Tests"
        command: flutter test test/features/video/
```

### **Playwright Visual Tests**

**Test Scenarios:**
```typescript
// Voice message UI
test('Voice recording button', async ({ page }) => {
  await page.goto('/messages');
  await expect(page.locator('[data-testid="voice-record-button"]'))
    .toHaveScreenshot('voice_record_button.png');
});

test('Voice recording active state', async ({ page }) => {
  await page.goto('/messages');
  await page.click('[data-testid="voice-record-button"]');
  await expect(page).toHaveScreenshot('voice_recording_active.png');
});

// Video call UI
test('Video call initiation screen', async ({ page }) => {
  await page.goto('/video-call');
  await expect(page).toHaveScreenshot('video_call_init.png');
});

test('Video call active state', async ({ page }) => {
  await page.goto('/video-call/active');
  await expect(page).toHaveScreenshot('video_call_active.png');
});
```

---

## PHASE 3: MULTI-PHOTO POSTS

### **Recommended Tool Usage**

| Tool | Primary Use Cases | Priority |
|------|------------------|----------|
| **Context7** | image_picker, photo_view API docs | 🔴 Critical |
| **Exa** | Find image compression strategies | 🟡 High |
| **CircleCI** | Automated testing | 🔴 Critical |
| **Playwright** | Visual testing for photo grid | 🟡 High |

### **Expected Queries**

**Context7:**
```
"Get Context7 documentation for image_picker focusing on multiple selection"
"Get Context7 documentation for photo_view focusing on zoom gestures"
"Get Context7 documentation for flutter_image_compress"
"Get Context7 documentation for cached_network_image"
```

**Exa:**
```
"Use Exa to find Flutter image picker multiple selection examples"
"Use Exa to search for photo_view zoom animations performance"
"Use Exa to find Flutter image compression best practices"
"Use Exa to search GitHub for Flutter gallery implementations"
```

### **Playwright Visual Tests**

```typescript
test('Photo picker UI', async ({ page }) => {
  await page.goto('/create-post');
  await page.click('[data-testid="add-photos-button"]');
  await expect(page).toHaveScreenshot('photo_picker.png');
});

test('Photo grid layout', async ({ page }) => {
  await page.goto('/create-post');
  // Add 4 photos
  await expect(page.locator('[data-testid="photo-grid"]'))
    .toHaveScreenshot('photo_grid_4_photos.png');
});

test('Photo zoom view', async ({ page }) => {
  await page.goto('/post/123');
  await page.click('[data-testid="photo-0"]');
  await expect(page).toHaveScreenshot('photo_zoom.png');
});
```

---

## PHASE 4: FCM & NOTIFICATIONS

### **Recommended Tool Usage**

| Tool | Primary Use Cases | Priority |
|------|------------------|----------|
| **Context7** | firebase_messaging API docs | 🔴 Critical |
| **Exa** | Find FCM iOS setup issues | 🔴 Critical |
| **LangChain** | FCM setup guides | 🟡 High |
| **CircleCI** | Automated testing | 🔴 Critical |
| **Playwright** | Visual testing for notifications | 🟡 High |

### **Expected Queries**

**Context7:**
```
"Get Context7 documentation for firebase_messaging"
"Get Context7 documentation for flutter_local_notifications focusing on iOS setup"
```

**Exa:**
```
"Use Exa to find Firebase Cloud Messaging Flutter 2025 setup guide"
"Use Exa to search for FCM iOS notification not working Flutter solutions"
"Use Exa to find Flutter local notifications best practices"
"Use Exa to search for push notification testing strategies Flutter"
```

**LangChain:**
```
"Get Flutter FCM setup guide"
"Get iOS notification configuration guide"
```

### **Playwright Visual Tests**

```typescript
test('Notification permission dialog', async ({ page }) => {
  await page.goto('/settings/notifications');
  await page.click('[data-testid="enable-notifications"]');
  await expect(page).toHaveScreenshot('notification_permission.png');
});

test('In-app notification banner', async ({ page }) => {
  await page.goto('/home');
  // Trigger notification
  await expect(page.locator('[data-testid="notification-banner"]'))
    .toHaveScreenshot('notification_banner.png');
});
```

---

## PHASE 5: PRODUCTION POLISH

### **Recommended Tool Usage**

| Tool | Primary Use Cases | Priority |
|------|------------------|----------|
| **Exa** | Production deployment guides | 🔴 Critical |
| **CircleCI** | Full CI/CD pipeline | 🔴 Critical |
| **Playwright** | Full visual regression suite | 🔴 Critical |
| **Context7** | Performance monitoring packages | 🟡 High |

### **Expected Queries**

**Exa:**
```
"Use Exa to find Flutter production deployment checklist 2025"
"Use Exa to search for App Store review guidelines Flutter apps"
"Use Exa to find Flutter performance optimization techniques"
"Use Exa to search for Flutter app security best practices"
```

**Context7:**
```
"Get Context7 documentation for firebase_crashlytics"
"Get Context7 documentation for firebase_analytics"
"Get Context7 documentation for firebase_performance"
```

### **Playwright Full Suite**

```typescript
// End-to-end visual regression
test.describe('Full App Visual Regression', () => {
  test('Login flow', async ({ page }) => { /* ... */ });
  test('Signup flow', async ({ page }) => { /* ... */ });
  test('Create post flow', async ({ page }) => { /* ... */ });
  test('Voice message flow', async ({ page }) => { /* ... */ });
  test('Video call flow', async ({ page }) => { /* ... */ });
  test('Notification flow', async ({ page }) => { /* ... */ });
});
```

---

## END-OF-PHASE VISUAL TESTING

### **Standard Process**

**After completing each phase:**

1. **Capture Baselines**
   ```bash
   npx playwright test --update-snapshots
   ```

2. **Run Visual Tests**
   ```bash
   npx playwright test
   ```

3. **Review Results**
   ```bash
   npx playwright show-report
   ```

4. **CircleCI Integration**
   ```
   "Trigger CircleCI pipeline"
   ```

5. **Document Results**
   - Update PHASE_TRACKER.md
   - Store screenshots in phase baseline folder
   - Document any visual regressions

### **Checklist**

```
Phase Completion Checklist:
□ All features implemented
□ Unit tests written and passing
□ Integration tests written and passing
□ Visual baselines captured
□ Visual regression tests passing
□ CircleCI pipeline passing
□ Coverage threshold met (15%+)
□ Documentation updated
□ Phase summary created
```

---

## 🚀 QUICK REFERENCE

### **Tool Priority by Phase**

| Phase | Primary Tool | Secondary Tools |
|-------|-------------|-----------------|
| Phase 1 | CircleCI | Context7, LangChain |
| Phase 2 | Context7, Exa | CircleCI, Playwright |
| Phase 3 | Context7 | Exa, Playwright |
| Phase 4 | Exa, Context7 | LangChain, Playwright |
| Phase 5 | Playwright, Exa | CircleCI, Context7 |

---

**Next Steps:**
1. Review Phase 2 tool recommendations
2. Prepare Context7 queries for Phase 2 packages
3. Set up Playwright for Phase 2 visual testing
4. Plan Exa searches for common issues

**Related Documentation:**
- `README.md` - Tool overview
- `EXA_MCP_GUIDE.md` - Exa usage
- `CONTEXT7_MCP_GUIDE.md` - Context7 usage
- `PLAYWRIGHT_MCP_GUIDE.md` - Visual testing
- `CIRCLECI_MCP_GUIDE.md` - CI/CD automation

