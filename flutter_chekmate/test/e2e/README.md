# ChekMate Web PWA - E2E Test Suite

## Overview

This directory contains end-to-end (E2E) tests for the ChekMate Web PWA using Playwright. The tests are designed to run in headless mode by default for non-intrusive automated testing.

## Test Structure

```
test/e2e/
├── auth-signup-with-photo.spec.ts    # Signup with profile photo tests
├── auth-signup-without-photo.spec.ts # Signup without photo tests
├── auth-login.spec.ts                # Login flow tests
├── pages/                            # Page Object Models
│   ├── signup.page.ts
│   └── login.page.ts
├── helpers/                          # Test utilities
│   └── firebase-helpers.ts
├── fixtures/                         # Test data (images, etc.)
├── screenshots/                      # Test screenshots (gitignored)
└── reports/                          # Test reports (gitignored)
```

## Running Tests

### Prerequisites

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Install Playwright browsers:**
   ```bash
   npx playwright install chromium
   ```

3. **Start Flutter web app:**
   The tests will automatically start the Flutter web server, but you can also run it manually:
   ```bash
   flutter run -d chrome --web-port=54577
   ```

### Test Commands

**Run all tests (headless mode - default):**
```bash
npm test
```

**Run tests with visible browser:**
```bash
npm run test:headed
```

**Run tests in UI mode (interactive):**
```bash
npm run test:ui
```

**Run tests in debug mode:**
```bash
npm run test:debug
```

**Run specific test suites:**
```bash
npm run test:signup   # Run signup tests only
npm run test:login    # Run login tests only
```

**View test report:**
```bash
npm run test:report
```

**Run tests for CI/CD:**
```bash
npm run test:ci
```

## Test Coverage

### Authentication Tests

#### Signup with Profile Photo (`auth-signup-with-photo.spec.ts`)
- ✅ Successfully signup with profile photo upload
- ✅ Show validation errors for empty fields
- ✅ Show error for invalid email format
- ✅ Show error for short password
- ✅ Toggle password visibility
- ✅ Navigate to login page

#### Signup without Profile Photo (`auth-signup-without-photo.spec.ts`)
- ✅ Successfully signup without profile photo
- ✅ Handle rapid form submission

#### Login Flow (`auth-login.spec.ts`)
- ✅ Successfully login with valid credentials
- ✅ Show error for invalid credentials
- ✅ Show validation errors for empty fields
- ✅ Toggle password visibility
- ✅ Navigate to signup page
- ✅ Persist login after page reload

## Configuration

The test configuration is in `playwright.config.ts` at the project root. Key settings:

- **Headless Mode:** Enabled by default (`headless: true`)
- **Base URL:** `http://127.0.0.1:54577`
- **Timeout:** 60 seconds per test
- **Retries:** 2 retries on CI, 0 locally
- **Screenshots:** Only on failure
- **Videos:** Only on failure
- **Browsers:** Chromium (desktop and mobile)

## Page Object Model

Tests use the Page Object Model (POM) pattern for maintainability:

- **SignupPage** (`pages/signup.page.ts`): Encapsulates signup page interactions
- **LoginPage** (`pages/login.page.ts`): Encapsulates login page interactions

## Helper Functions

The `helpers/firebase-helpers.ts` file provides utilities for:

- Generating unique test user data
- Waiting for authentication completion
- Clearing browser storage
- Taking screenshots
- Checking for error messages
- Network idle detection

## Best Practices

1. **Headless by Default:** All tests run in headless mode to avoid disrupting development workflow
2. **Unique Test Data:** Each test generates unique user data to avoid conflicts
3. **Clean State:** Tests clear browser storage before each run
4. **Screenshots:** Captured automatically on failures for debugging
5. **Page Objects:** All page interactions go through Page Object Models
6. **Timeouts:** Generous timeouts for Firebase operations
7. **Error Handling:** Tests gracefully handle expected errors

## CI/CD Integration

These tests are designed to run in CircleCI:

```yaml
# Example CircleCI config
- run:
    name: Run E2E Tests
    command: npm run test:ci
```

The tests will:
- Run in headless mode
- Generate JSON and HTML reports
- Capture screenshots/videos on failures
- Exit with proper status codes

## Troubleshooting

### Tests fail with "Element not found"

Flutter web uses canvas rendering, which can make element selection challenging. The tests use flexible selectors that work with Flutter's semantics tree.

### File upload doesn't work in headless mode

Profile photo upload tests may skip the upload step in headless mode. This is expected behavior and the test will continue.

### Tests timeout

Increase the timeout in `playwright.config.ts` if Firebase operations are slow:

```typescript
timeout: 120 * 1000, // 2 minutes
```

### Web server doesn't start

Make sure Flutter is installed and the web platform is enabled:

```bash
flutter config --enable-web
flutter doctor
```

## Adding New Tests

1. Create a new spec file in `test/e2e/`
2. Import necessary page objects and helpers
3. Follow the existing test structure
4. Use descriptive test names
5. Add screenshots for debugging
6. Update this README with new test coverage

## Example Test

```typescript
import { test, expect } from '@playwright/test';
import { SignupPage } from './pages/signup.page';
import { generateTestUserData } from './helpers/firebase-helpers';

test('should signup successfully', async ({ page }) => {
  const signupPage = new SignupPage(page);
  const userData = generateTestUserData();
  
  await signupPage.goto();
  await signupPage.signup(userData);
  
  const success = await signupPage.waitForSignupComplete();
  expect(success).toBe(true);
});
```

## Resources

- [Playwright Documentation](https://playwright.dev/)
- [Flutter Web Testing](https://docs.flutter.dev/testing/integration-tests)
- [Firebase Testing Best Practices](https://firebase.google.com/docs/rules/unit-tests)

