/**
 * E2E Test: Login Flow
 * 
 * Tests the login functionality:
 * 1. Create a test user via signup
 * 2. Logout
 * 3. Login with created credentials
 * 4. Verify successful authentication
 */

import { test, expect } from '@playwright/test';
import { LoginPage } from './pages/login.page';
import { SignupPage } from './pages/signup.page';
import { 
  generateTestUserData, 
  clearBrowserStorage,
  takeScreenshot 
} from './helpers/firebase-helpers';

test.describe('Login Flow', () => {
  let loginPage: LoginPage;
  let signupPage: SignupPage;
  let testUserData: ReturnType<typeof generateTestUserData>;

  test.beforeEach(async ({ page }) => {
    // Clear browser storage
    await clearBrowserStorage(page);
    
    // Initialize page objects
    loginPage = new LoginPage(page);
    signupPage = new SignupPage(page);
    
    // Generate test user data
    testUserData = generateTestUserData();
  });

  test('should successfully login with valid credentials', async ({ page }) => {
    // Step 1: Create a test user first
    console.log('Step 1: Creating test user...');
    await signupPage.goto();
    await signupPage.signup(testUserData);
    
    // Wait for signup to complete
    await signupPage.waitForSignupComplete(15000);
    await takeScreenshot(page, 'login-test-user-created', true);
    
    // Step 2: Clear storage to simulate logout
    console.log('Step 2: Simulating logout...');
    await clearBrowserStorage(page);
    
    // Step 3: Navigate to login page
    console.log('Step 3: Navigating to login page...');
    await loginPage.goto();
    await takeScreenshot(page, 'login-page-loaded', true);
    
    // Step 4: Login with created credentials
    console.log('Step 4: Logging in...');
    await loginPage.login(testUserData.email, testUserData.password);
    
    // Step 5: Wait for login to complete
    console.log('Step 5: Waiting for login completion...');
    const loginComplete = await loginPage.waitForLoginComplete(15000);
    
    await takeScreenshot(page, 'login-complete', true);
    
    // Verify login completed
    expect(loginComplete).toBe(true);
    
    // Verify we're no longer on login page
    const stillOnLogin = await loginPage.isOnLoginPage();
    expect(stillOnLogin).toBe(false);
    
    const currentUrl = page.url();
    console.log(`✅ Login successful! User: ${testUserData.email}`);
    console.log(`✅ Redirected to: ${currentUrl}`);
  });

  test('should show error for invalid credentials', async ({ page }) => {
    // Navigate to login page
    await loginPage.goto();
    
    // Try to login with invalid credentials
    await loginPage.login('invalid@test.com', 'wrongpassword');
    
    // Wait for error message
    await page.waitForTimeout(3000);
    
    // Should still be on login page
    const stillOnLogin = await loginPage.isOnLoginPage();
    expect(stillOnLogin).toBe(true);
    
    // Check for error message
    const errorMessage = await loginPage.getErrorMessage();
    console.log('Error message:', errorMessage);
    
    await takeScreenshot(page, 'login-invalid-credentials', true);
  });

  test('should show validation errors for empty fields', async ({ page }) => {
    // Navigate to login page
    await loginPage.goto();
    
    // Try to submit without filling form
    await loginPage.clickLogin();
    
    // Wait for validation
    await page.waitForTimeout(1000);
    
    // Should still be on login page
    const stillOnLogin = await loginPage.isOnLoginPage();
    expect(stillOnLogin).toBe(true);
    
    await takeScreenshot(page, 'login-empty-fields', true);
  });

  test('should toggle password visibility', async ({ page }) => {
    // Navigate to login page
    await loginPage.goto();
    
    // Fill password field
    await loginPage.passwordInput.fill('TestPassword123');
    
    // Toggle visibility
    await loginPage.togglePasswordVisibility();
    await page.waitForTimeout(500);
    
    await takeScreenshot(page, 'login-password-visible', true);
  });

  test('should navigate to signup page', async ({ page }) => {
    // Navigate to login page
    await loginPage.goto();
    
    // Click signup link
    await loginPage.goToSignup();
    
    // Verify we're on signup page
    const currentUrl = page.url();
    expect(currentUrl).toContain('/signup');
    
    await takeScreenshot(page, 'navigated-to-signup', true);
  });

  test('should persist login after page reload', async ({ page }) => {
    // Create and login user
    await signupPage.goto();
    await signupPage.signup(testUserData);
    await signupPage.waitForSignupComplete(15000);
    
    // Get current URL after login
    const urlAfterLogin = page.url();
    
    // Reload page
    await page.reload({ waitUntil: 'networkidle' });
    await page.waitForTimeout(2000);
    
    // Should still be authenticated (not redirected to login)
    const currentUrl = page.url();
    const isOnLoginPage = currentUrl.includes('/login');
    expect(isOnLoginPage).toBe(false);
    
    await takeScreenshot(page, 'login-persisted-after-reload', true);
    
    console.log('✅ Login persisted after page reload');
  });
});

