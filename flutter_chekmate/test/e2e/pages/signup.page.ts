/**
 * Page Object Model for Signup Page
 * 
 * This class encapsulates all interactions with the signup page
 */

import { Page, Locator } from '@playwright/test';
import { fillFormField, waitForElement } from '../helpers/firebase-helpers';

export class SignupPage {
  readonly page: Page;
  
  // Locators
  readonly profilePhotoButton: Locator;
  readonly nameInput: Locator;
  readonly emailInput: Locator;
  readonly phoneInput: Locator;
  readonly passwordInput: Locator;
  readonly signupButton: Locator;
  readonly loginLink: Locator;
  readonly passwordToggle: Locator;

  constructor(page: Page) {
    this.page = page;
    
    // Initialize locators using Flutter semantics or text content
    // Note: Flutter web uses canvas rendering, so we need to be creative with selectors
    this.profilePhotoButton = page.locator('flt-semantics[role="button"]').filter({ hasText: /photo|camera/i }).first();
    this.nameInput = page.locator('input[type="text"]').first();
    this.emailInput = page.locator('input[type="email"], input[type="text"]').nth(1);
    this.phoneInput = page.locator('input[type="tel"], input[type="text"]').nth(2);
    this.passwordInput = page.locator('input[type="password"]');
    this.signupButton = page.locator('button, flt-semantics[role="button"]').filter({ hasText: /sign up/i });
    this.loginLink = page.locator('a, flt-semantics').filter({ hasText: /log in here/i });
    this.passwordToggle = page.locator('button, flt-semantics[role="button"]').filter({ hasText: /visibility/i });
  }

  /**
   * Navigate to signup page
   */
  async goto() {
    await this.page.goto('/signup');
    await this.page.waitForLoadState('networkidle');
  }

  /**
   * Fill signup form with user data
   */
  async fillSignupForm(userData: {
    displayName: string;
    email: string;
    phone: string;
    password: string;
  }) {
    // Wait for form to be ready
    await waitForElement(this.page, 'input[type="text"]', 10000);
    
    // Fill name field
    await this.nameInput.fill(userData.displayName);
    await this.page.waitForTimeout(500);
    
    // Fill email field
    await this.emailInput.fill(userData.email);
    await this.page.waitForTimeout(500);
    
    // Fill phone field
    await this.phoneInput.fill(userData.phone);
    await this.page.waitForTimeout(500);
    
    // Fill password field
    await this.passwordInput.fill(userData.password);
    await this.page.waitForTimeout(500);
  }

  /**
   * Upload profile photo
   */
  async uploadProfilePhoto(filePath: string) {
    // Click the profile photo button to trigger file picker
    await this.profilePhotoButton.click();
    
    // Wait for file input to appear
    const fileInput = this.page.locator('input[type="file"]');
    await fileInput.setInputFiles(filePath);
    
    // Wait for image to be processed
    await this.page.waitForTimeout(1000);
  }

  /**
   * Click signup button
   */
  async clickSignup() {
    await this.signupButton.click();
  }

  /**
   * Complete signup process
   */
  async signup(userData: {
    displayName: string;
    email: string;
    phone: string;
    password: string;
  }) {
    await this.fillSignupForm(userData);
    await this.clickSignup();
    
    // Wait for navigation or error
    await this.page.waitForTimeout(2000);
  }

  /**
   * Complete signup with profile photo
   */
  async signupWithPhoto(
    userData: {
      displayName: string;
      email: string;
      phone: string;
      password: string;
    },
    photoPath: string
  ) {
    await this.uploadProfilePhoto(photoPath);
    await this.fillSignupForm(userData);
    await this.clickSignup();
    
    // Wait for upload and navigation
    await this.page.waitForTimeout(5000);
  }

  /**
   * Navigate to login page
   */
  async goToLogin() {
    await this.loginLink.click();
    await this.page.waitForLoadState('networkidle');
  }

  /**
   * Check if on signup page
   */
  async isOnSignupPage(): Promise<boolean> {
    const url = this.page.url();
    return url.includes('/signup');
  }

  /**
   * Get validation error message
   */
  async getValidationError(): Promise<string | null> {
    try {
      const errorElement = this.page.locator('text=/please enter|required|invalid/i').first();
      if (await errorElement.isVisible({ timeout: 2000 })) {
        return await errorElement.textContent();
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  /**
   * Check if signup button is disabled
   */
  async isSignupButtonDisabled(): Promise<boolean> {
    return await this.signupButton.isDisabled();
  }

  /**
   * Toggle password visibility
   */
  async togglePasswordVisibility() {
    await this.passwordToggle.click();
    await this.page.waitForTimeout(300);
  }

  /**
   * Check if password is visible
   */
  async isPasswordVisible(): Promise<boolean> {
    const type = await this.passwordInput.getAttribute('type');
    return type === 'text';
  }

  /**
   * Wait for signup to complete
   */
  async waitForSignupComplete(timeout: number = 15000): Promise<boolean> {
    try {
      // Wait for redirect to onboarding or home
      await this.page.waitForURL(/\/(onboarding|home|\/)/, { timeout });
      return true;
    } catch (error) {
      console.error('Signup did not complete:', error);
      return false;
    }
  }

  /**
   * Take screenshot of signup page
   */
  async screenshot(name: string) {
    await this.page.screenshot({
      path: `test/e2e/screenshots/signup-${name}-${Date.now()}.png`,
      fullPage: true,
    });
  }
}

