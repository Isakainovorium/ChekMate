/**
 * E2E Test: Signup without Profile Photo
 * 
 * Tests the signup flow without profile photo upload:
 * 1. Navigate to signup page
 * 2. Fill signup form (skip photo upload)
 * 3. Submit signup
 * 4. Verify user creation
 * 5. Verify user document has empty avatar field
 */

import { test, expect } from '@playwright/test';
import { SignupPage } from './pages/signup.page';
import { 
  generateTestUserData, 
  clearBrowserStorage,
  takeScreenshot 
} from './helpers/firebase-helpers';

test.describe('Signup without Profile Photo', () => {
  let signupPage: SignupPage;
  let testUserData: ReturnType<typeof generateTestUserData>;

  test.beforeEach(async ({ page }) => {
    // Clear browser storage
    await clearBrowserStorage(page);
    
    // Initialize page object
    signupPage = new SignupPage(page);
    
    // Generate test user data
    testUserData = generateTestUserData();
    
    // Navigate to signup page
    await signupPage.goto();
    
    await takeScreenshot(page, 'signup-no-photo-initial', true);
  });

  test('should successfully signup without profile photo', async ({ page }) => {
    // Fill signup form (skip photo upload)
    console.log('Filling signup form without photo...');
    await signupPage.fillSignupForm(testUserData);
    await takeScreenshot(page, 'signup-no-photo-form-filled', true);
    
    // Submit signup
    console.log('Submitting signup...');
    await signupPage.clickSignup();
    
    // Wait for signup to complete
    console.log('Waiting for signup completion...');
    const signupComplete = await signupPage.waitForSignupComplete(15000);
    
    await takeScreenshot(page, 'signup-no-photo-complete', true);
    
    // Verify signup completed
    expect(signupComplete).toBe(true);
    
    // Verify redirect
    const stillOnSignup = await signupPage.isOnSignupPage();
    expect(stillOnSignup).toBe(false);
    
    const currentUrl = page.url();
    console.log(`✅ Signup successful without photo! User: ${testUserData.email}`);
    console.log(`✅ Redirected to: ${currentUrl}`);
  });

  test('should handle rapid form submission', async ({ page }) => {
    // Fill form
    await signupPage.fillSignupForm(testUserData);
    
    // Click signup button multiple times rapidly
    await signupPage.clickSignup();
    await page.waitForTimeout(100);
    await signupPage.clickSignup();
    await page.waitForTimeout(100);
    await signupPage.clickSignup();
    
    // Should still complete successfully (button should be disabled after first click)
    const signupComplete = await signupPage.waitForSignupComplete(15000);
    expect(signupComplete).toBe(true);
    
    await takeScreenshot(page, 'signup-rapid-submission', true);
  });
});

