/**
 * Firebase Helper Functions for Playwright Tests
 * 
 * These helpers interact with Firebase services to verify test results
 */

import { Page } from '@playwright/test';

/**
 * Generate a unique test email address
 */
export function generateTestEmail(): string {
  const timestamp = Date.now();
  const random = Math.floor(Math.random() * 10000);
  return `chekmate-test-${timestamp}-${random}@test.com`;
}

/**
 * Generate a unique test username
 */
export function generateTestUsername(): string {
  const timestamp = Date.now();
  const random = Math.floor(Math.random() * 10000);
  return `testuser_${timestamp}_${random}`;
}

/**
 * Generate test user data
 */
export function generateTestUserData() {
  const email = generateTestEmail();
  const username = email.split('@')[0];
  
  return {
    email,
    username,
    displayName: `Test User ${Date.now()}`,
    password: 'TestPassword123!',
    phone: '+1234567890',
  };
}

/**
 * Wait for Firebase Auth to complete
 * Checks for redirect or auth state change
 */
export async function waitForAuthComplete(page: Page, timeout: number = 10000): Promise<boolean> {
  try {
    // Wait for either redirect to home or onboarding
    await page.waitForURL(/\/(onboarding|home|\/)/, { timeout });
    return true;
  } catch (error) {
    console.error('Auth completion timeout:', error);
    return false;
  }
}

/**
 * Check if user is authenticated by checking for auth state
 */
export async function isUserAuthenticated(page: Page): Promise<boolean> {
  try {
    // Check if we're on a protected route (not login/signup)
    const url = page.url();
    return !url.includes('/login') && !url.includes('/signup');
  } catch (error) {
    return false;
  }
}

/**
 * Wait for element to be visible with custom timeout
 */
export async function waitForElement(
  page: Page,
  selector: string,
  timeout: number = 10000
): Promise<boolean> {
  try {
    await page.waitForSelector(selector, { state: 'visible', timeout });
    return true;
  } catch (error) {
    console.error(`Element not found: ${selector}`, error);
    return false;
  }
}

/**
 * Fill form field and verify it was filled
 */
export async function fillFormField(
  page: Page,
  selector: string,
  value: string
): Promise<void> {
  await page.fill(selector, value);
  
  // Verify the field was filled
  const fieldValue = await page.inputValue(selector);
  if (fieldValue !== value) {
    throw new Error(`Failed to fill field ${selector}. Expected: ${value}, Got: ${fieldValue}`);
  }
}

/**
 * Take a screenshot with a descriptive name
 */
export async function takeScreenshot(
  page: Page,
  name: string,
  fullPage: boolean = false
): Promise<void> {
  const timestamp = Date.now();
  await page.screenshot({
    path: `test/e2e/screenshots/${name}-${timestamp}.png`,
    fullPage,
  });
}

/**
 * Wait for network idle (useful after form submissions)
 */
export async function waitForNetworkIdle(
  page: Page,
  timeout: number = 5000
): Promise<void> {
  await page.waitForLoadState('networkidle', { timeout });
}

/**
 * Check if an error message is displayed
 */
export async function hasErrorMessage(page: Page): Promise<boolean> {
  try {
    // Look for common error indicators
    const errorSelectors = [
      'text=/error/i',
      'text=/failed/i',
      '[role="alert"]',
      '.error',
      '.snackbar',
    ];
    
    for (const selector of errorSelectors) {
      const element = await page.locator(selector).first();
      if (await element.isVisible({ timeout: 1000 })) {
        return true;
      }
    }
    
    return false;
  } catch (error) {
    return false;
  }
}

/**
 * Get error message text if present
 */
export async function getErrorMessage(page: Page): Promise<string | null> {
  try {
    const errorSelectors = [
      '[role="alert"]',
      '.error',
      '.snackbar',
      'text=/error/i',
      'text=/failed/i',
    ];
    
    for (const selector of errorSelectors) {
      const element = await page.locator(selector).first();
      if (await element.isVisible({ timeout: 1000 })) {
        return await element.textContent();
      }
    }
    
    return null;
  } catch (error) {
    return null;
  }
}

/**
 * Clear browser storage (useful for test cleanup)
 */
export async function clearBrowserStorage(page: Page): Promise<void> {
  try {
    // Navigate to a blank page first to ensure we have access to storage
    await page.goto('about:blank');

    // Clear storage
    await page.evaluate(() => {
      try {
        localStorage.clear();
        sessionStorage.clear();
      } catch (e) {
        // Ignore storage access errors
        console.log('Storage clear skipped:', e);
      }
    });

    // Clear cookies
    const context = page.context();
    await context.clearCookies();
  } catch (error) {
    // Ignore errors - storage might not be accessible
    console.log('clearBrowserStorage error (ignored):', error);
  }
}

/**
 * Reload page and wait for it to be ready
 */
export async function reloadAndWait(page: Page): Promise<void> {
  await page.reload({ waitUntil: 'networkidle' });
  await page.waitForLoadState('domcontentloaded');
}

