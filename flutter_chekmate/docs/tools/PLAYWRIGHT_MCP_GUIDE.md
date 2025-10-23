# Playwright MCP - Visual Testing & Browser Automation Guide

**Last Updated:** October 17, 2025  
**Tool:** Microsoft Playwright  
**Status:** ✅ Enabled  
**Website:** https://playwright.dev

---

## 📋 OVERVIEW

Playwright is a powerful browser automation framework that enables visual testing, UI validation, and cross-browser testing. For ChekMate, we'll use it for end-of-phase visual validation and regression testing.

---

## 🎯 CAPABILITIES

### **1. Browser Automation**
- Chrome, Firefox, Safari support
- Headless and headed modes
- Mobile device emulation
- Network interception

### **2. Visual Testing**
- Screenshot capture
- Visual regression testing
- Pixel-perfect comparison
- Accessibility audits

### **3. UI Interaction**
- Click, type, hover, drag-and-drop
- Form filling
- File uploads
- Keyboard/mouse events

### **4. Testing Features**
- Automatic waiting
- Network request monitoring
- Console message capture
- Video recording

---

## 💡 CHEKMATE VISUAL TESTING STRATEGY

### **End-of-Phase Validation**

At the end of each phase, we'll use Playwright to:

1. **Capture baseline screenshots** of all new UI components
2. **Compare against previous baselines** to detect regressions
3. **Validate accessibility** (WCAG compliance)
4. **Test cross-platform** (iOS vs Android web views)
5. **Generate visual reports** for review

---

## 📸 PHASE-SPECIFIC TESTING PLAN

### **Phase 1: Foundation** ✅ COMPLETE

**Visual Baseline:**
- ✅ Login page
- ✅ Signup page
- ✅ Home screen (empty state)

**Test Files:**
```
test/visual/
├── phase1_baseline/
│   ├── login_page.png
│   ├── signup_page.png
│   └── home_empty.png
└── phase1_tests.spec.ts
```

**Playwright Tests:**
```typescript
// test/visual/phase1_tests.spec.ts
test('Login page visual baseline', async ({ page }) => {
  await page.goto('http://localhost:8080/#/login');
  await expect(page).toHaveScreenshot('login_page.png');
});

test('Signup page visual baseline', async ({ page }) => {
  await page.goto('http://localhost:8080/#/signup');
  await expect(page).toHaveScreenshot('signup_page.png');
});
```

---

### **Phase 2: Voice/Video Features** (NEXT)

**Visual Tests:**
- 📸 Voice message recording UI
- 📸 Voice message playback UI
- 📸 Video call initiation screen
- 📸 Video call active screen
- 📸 Camera permission dialog
- 📸 Microphone permission dialog

**Test Scenarios:**
```typescript
// Voice message UI
test('Voice message recording state', async ({ page }) => {
  await page.goto('http://localhost:8080/#/messages');
  await page.click('[data-testid="voice-record-button"]');
  await expect(page).toHaveScreenshot('voice_recording.png');
});

// Video call UI
test('Video call active state', async ({ page }) => {
  await page.goto('http://localhost:8080/#/video-call');
  await expect(page).toHaveScreenshot('video_call_active.png');
});
```

**Accessibility Tests:**
```typescript
test('Voice controls are keyboard accessible', async ({ page }) => {
  await page.goto('http://localhost:8080/#/messages');
  await page.keyboard.press('Tab'); // Focus voice button
  await page.keyboard.press('Enter'); // Activate
  // Verify recording started
});
```

---

### **Phase 3: Multi-Photo Posts**

**Visual Tests:**
- 📸 Photo picker UI (multiple selection)
- 📸 Photo grid layout
- 📸 Photo zoom view
- 📸 Photo editing UI
- 📸 Post creation with photos

---

### **Phase 4: FCM & Notifications**

**Visual Tests:**
- 📸 Notification permission dialog
- 📸 In-app notification banner
- 📸 Notification list
- 📸 Notification settings screen

---

### **Phase 5: Production Polish**

**Visual Tests:**
- 📸 Full app flow (end-to-end)
- 📸 Dark mode variants
- 📸 Tablet layouts
- 📸 Accessibility features

---

## 🔧 SETUP INSTRUCTIONS

### **Step 1: Install Playwright**

**For Flutter Web Testing:**
```bash
# Install Playwright
npm init playwright@latest

# Install browsers
npx playwright install
```

### **Step 2: Configure Playwright**

**Create `playwright.config.ts`:**
```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './test/visual',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  
  use: {
    baseURL: 'http://localhost:8080',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'Mobile Chrome',
      use: { ...devices['Pixel 5'] },
    },
    {
      name: 'Mobile Safari',
      use: { ...devices['iPhone 12'] },
    },
  ],

  webServer: {
    command: 'flutter run -d web-server --web-port=8080',
    url: 'http://localhost:8080',
    reuseExistingServer: !process.env.CI,
  },
});
```

### **Step 3: Create Test Directory**

```bash
mkdir -p test/visual/phase1_baseline
mkdir -p test/visual/phase2_baseline
mkdir -p test/visual/phase3_baseline
mkdir -p test/visual/phase4_baseline
mkdir -p test/visual/phase5_baseline
```

---

## 📝 WRITING VISUAL TESTS

### **Basic Screenshot Test**

```typescript
import { test, expect } from '@playwright/test';

test('Component visual baseline', async ({ page }) => {
  await page.goto('/component-route');
  await expect(page).toHaveScreenshot('component.png');
});
```

### **Element-Specific Screenshot**

```typescript
test('Button visual baseline', async ({ page }) => {
  await page.goto('/buttons');
  const button = page.locator('[data-testid="primary-button"]');
  await expect(button).toHaveScreenshot('primary_button.png');
});
```

### **Interaction Before Screenshot**

```typescript
test('Modal open state', async ({ page }) => {
  await page.goto('/home');
  await page.click('[data-testid="open-modal"]');
  await page.waitForSelector('[data-testid="modal"]');
  await expect(page).toHaveScreenshot('modal_open.png');
});
```

### **Responsive Testing**

```typescript
test('Mobile layout', async ({ page }) => {
  await page.setViewportSize({ width: 375, height: 667 });
  await page.goto('/home');
  await expect(page).toHaveScreenshot('home_mobile.png');
});

test('Tablet layout', async ({ page }) => {
  await page.setViewportSize({ width: 768, height: 1024 });
  await page.goto('/home');
  await expect(page).toHaveScreenshot('home_tablet.png');
});
```

---

## 🎨 VISUAL REGRESSION TESTING

### **How It Works**

1. **First run:** Captures baseline screenshots
2. **Subsequent runs:** Compares against baseline
3. **Differences detected:** Test fails with diff image
4. **Review diff:** Approve or fix

### **Updating Baselines**

```bash
# Update all baselines
npx playwright test --update-snapshots

# Update specific test
npx playwright test phase1_tests.spec.ts --update-snapshots
```

### **Reviewing Diffs**

```bash
# Open HTML report
npx playwright show-report
```

**Report includes:**
- Expected image (baseline)
- Actual image (current)
- Diff image (highlighted differences)

---

## ♿ ACCESSIBILITY TESTING

### **Automated Accessibility Audits**

```typescript
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test('Login page accessibility', async ({ page }) => {
  await page.goto('/login');
  
  const accessibilityScanResults = await new AxeBuilder({ page })
    .analyze();
  
  expect(accessibilityScanResults.violations).toEqual([]);
});
```

### **Keyboard Navigation Testing**

```typescript
test('Form is keyboard accessible', async ({ page }) => {
  await page.goto('/signup');
  
  // Tab through form
  await page.keyboard.press('Tab'); // Email field
  await page.keyboard.type('test@example.com');
  
  await page.keyboard.press('Tab'); // Password field
  await page.keyboard.type('password123');
  
  await page.keyboard.press('Tab'); // Submit button
  await page.keyboard.press('Enter');
  
  // Verify form submitted
  await expect(page).toHaveURL('/home');
});
```

---

## 🔄 CIRCLECI INTEGRATION

### **Add to `.circleci/config.yml`**

```yaml
jobs:
  visual_tests:
    docker:
      - image: mcr.microsoft.com/playwright:v1.40.0-focal
    steps:
      - checkout
      - run:
          name: Install dependencies
          command: npm ci
      - run:
          name: Install Playwright browsers
          command: npx playwright install --with-deps
      - run:
          name: Run visual tests
          command: npx playwright test
      - store_artifacts:
          path: playwright-report/
          destination: playwright-report
      - store_artifacts:
          path: test-results/
          destination: test-results

workflows:
  build_and_test:
    jobs:
      - analyze
      - test
      - visual_tests  # Add visual tests
      - build_android:
          requires:
            - test
            - visual_tests
```

---

## 📊 REPORTING

### **HTML Report**

```bash
# Generate and open report
npx playwright show-report
```

**Report includes:**
- Test results (pass/fail)
- Screenshots (expected, actual, diff)
- Test duration
- Error messages

### **CI/CD Artifacts**

CircleCI will store:
- `playwright-report/` - HTML report
- `test-results/` - Screenshots and videos

---

## ✅ BEST PRACTICES

### **1. Use Data Test IDs**

```dart
// Flutter widget
ElevatedButton(
  key: Key('primary-button'),
  child: Text('Submit'),
  onPressed: () {},
)
```

```typescript
// Playwright test
await page.click('[key="primary-button"]');
```

### **2. Wait for Stability**

```typescript
// Wait for animations to complete
await page.waitForTimeout(500);

// Wait for network idle
await page.waitForLoadState('networkidle');
```

### **3. Mask Dynamic Content**

```typescript
await expect(page).toHaveScreenshot({
  mask: [page.locator('[data-testid="timestamp"]')],
});
```

### **4. Use Descriptive Names**

```typescript
// ❌ Bad
await expect(page).toHaveScreenshot('test1.png');

// ✅ Good
await expect(page).toHaveScreenshot('login_page_empty_state.png');
```

### **5. Test Critical Paths Only**

Focus on:
- User-facing UI components
- Critical user flows
- High-risk areas (new features)

---

## 🚀 QUICK REFERENCE

### **Common Commands**

```bash
# Run all tests
npx playwright test

# Run specific test file
npx playwright test phase1_tests.spec.ts

# Run in headed mode (see browser)
npx playwright test --headed

# Update baselines
npx playwright test --update-snapshots

# Open HTML report
npx playwright show-report

# Debug mode
npx playwright test --debug
```

### **Test Structure**

```typescript
import { test, expect } from '@playwright/test';

test.describe('Feature Name', () => {
  test.beforeEach(async ({ page }) => {
    // Setup
  });

  test('Test case description', async ({ page }) => {
    // Test steps
  });
});
```

---

## 📅 IMPLEMENTATION TIMELINE

### **Before Phase 2:**
- ✅ Install Playwright
- ✅ Configure playwright.config.ts
- ✅ Create test directory structure
- ✅ Capture Phase 1 baselines

### **During Phase 2:**
- 🔄 Write visual tests for voice/video UI
- 🔄 Run tests after each feature
- 🔄 Update baselines as needed

### **End of Phase 2:**
- 🎯 Full visual regression suite
- 🎯 Accessibility audit
- 🎯 Cross-browser validation
- 🎯 Generate visual report

---

**Next Steps:**
1. Install Playwright
2. Capture Phase 1 baselines
3. Write Phase 2 test plan
4. Integrate with CircleCI

**Related Documentation:**
- `README.md` - Tool overview
- `CIRCLECI_MCP_GUIDE.md` - CI/CD integration
- `PHASE_TOOL_USAGE.md` - Phase-specific usage

