/**
 * Page Object Model for Login Page
 * 
 * This class encapsulates all interactions with the login page
 */

import { Page, Locator } from '@playwright/test';
import { waitForElement } from '../helpers/firebase-helpers';

export class LoginPage {
  readonly page: Page;
  
  // Locators
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly loginButton: Locator;
  readonly signupLink: Locator;
  readonly forgotPasswordLink: Locator;
  readonly passwordToggle: Locator;

  constructor(page: Page) {
    this.page = page;
    
    // Initialize locators
    this.emailInput = page.locator('input[type="email"], input[type="text"]').first();
    this.passwordInput = page.locator('input[type="password"]');
    this.loginButton = page.locator('button, flt-semantics[role="button"]').filter({ hasText: /log in/i });
    this.signupLink = page.locator('a, flt-semantics').filter({ hasText: /create new account/i });
    this.forgotPasswordLink = page.locator('a, flt-semantics').filter({ hasText: /forgot password/i });
    this.passwordToggle = page.locator('button, flt-semantics[role="button"]').filter({ hasText: /visibility/i });
  }

  /**
   * Navigate to login page
   */
  async goto() {
    await this.page.goto('/login');
    await this.page.waitForLoadState('networkidle');
  }

  /**
   * Fill login form
   */
  async fillLoginForm(email: string, password: string) {
    await waitForElement(this.page, 'input[type="email"], input[type="text"]', 10000);
    
    await this.emailInput.fill(email);
    await this.page.waitForTimeout(500);
    
    await this.passwordInput.fill(password);
    await this.page.waitForTimeout(500);
  }

  /**
   * Click login button
   */
  async clickLogin() {
    await this.loginButton.click();
  }

  /**
   * Complete login process
   */
  async login(email: string, password: string) {
    await this.fillLoginForm(email, password);
    await this.clickLogin();
    
    // Wait for navigation or error
    await this.page.waitForTimeout(2000);
  }

  /**
   * Navigate to signup page
   */
  async goToSignup() {
    await this.signupLink.click();
    await this.page.waitForLoadState('networkidle');
  }

  /**
   * Click forgot password link
   */
  async clickForgotPassword() {
    await this.forgotPasswordLink.click();
    await this.page.waitForTimeout(1000);
  }

  /**
   * Check if on login page
   */
  async isOnLoginPage(): Promise<boolean> {
    const url = this.page.url();
    return url.includes('/login');
  }

  /**
   * Get error message
   */
  async getErrorMessage(): Promise<string | null> {
    try {
      const errorElement = this.page.locator('text=/login failed|invalid|error/i').first();
      if (await errorElement.isVisible({ timeout: 2000 })) {
        return await errorElement.textContent();
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  /**
   * Check if login button is disabled
   */
  async isLoginButtonDisabled(): Promise<boolean> {
    return await this.loginButton.isDisabled();
  }

  /**
   * Toggle password visibility
   */
  async togglePasswordVisibility() {
    await this.passwordToggle.click();
    await this.page.waitForTimeout(300);
  }

  /**
   * Wait for login to complete
   */
  async waitForLoginComplete(timeout: number = 10000): Promise<boolean> {
    try {
      // Wait for redirect to home
      await this.page.waitForURL(/\/(home|\/)/, { timeout });
      return true;
    } catch (error) {
      console.error('Login did not complete:', error);
      return false;
    }
  }

  /**
   * Take screenshot of login page
   */
  async screenshot(name: string) {
    await this.page.screenshot({
      path: `test/e2e/screenshots/login-${name}-${Date.now()}.png`,
      fullPage: true,
    });
  }
}

