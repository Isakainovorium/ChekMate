import { defineConfig, devices } from '@playwright/test';

/**
 * ChekMate Web PWA - Playwright Test Configuration
 * 
 * This configuration is optimized for:
 * - Headless testing by default (non-intrusive)
 * - Flutter Web PWA testing
 * - CI/CD compatibility (CircleCI)
 * - Screenshot/video capture on failures only
 */
export default defineConfig({
  testDir: './test/e2e',
  
  /* Maximum time one test can run for */
  timeout: 60 * 1000,
  
  /* Run tests in files in parallel */
  fullyParallel: true,
  
  /* Fail the build on CI if you accidentally left test.only in the source code */
  forbidOnly: !!process.env.CI,
  
  /* Retry on CI only */
  retries: process.env.CI ? 2 : 0,
  
  /* Opt out of parallel tests on CI */
  workers: process.env.CI ? 1 : undefined,
  
  /* Reporter to use */
  reporter: [
    ['html', { outputFolder: 'test/e2e/reports/html' }],
    ['json', { outputFile: 'test/e2e/reports/results.json' }],
    ['list']
  ],
  
  /* Shared settings for all the projects below */
  use: {
    /* Base URL for the Flutter web app */
    baseURL: 'http://127.0.0.1:54577',
    
    /* Collect trace on failure only */
    trace: 'on-first-retry',
    
    /* Screenshot on failure only */
    screenshot: 'only-on-failure',
    
    /* Video on failure only */
    video: 'retain-on-failure',
    
    /* Maximum time each action can take */
    actionTimeout: 15 * 1000,
    
    /* Navigation timeout */
    navigationTimeout: 30 * 1000,
  },

  /* Configure projects for major browsers */
  projects: [
    {
      name: 'chromium',
      use: { 
        ...devices['Desktop Chrome'],
        /* Run in headless mode by default */
        headless: true,
        /* Viewport size for desktop testing */
        viewport: { width: 1280, height: 720 },
      },
    },

    /* Uncomment to test on other browsers
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },

    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
    */

    /* Mobile viewports for responsive testing */
    {
      name: 'Mobile Chrome',
      use: { 
        ...devices['Pixel 5'],
        headless: true,
      },
    },
  ],

  /* Run your local dev server before starting the tests */
  webServer: {
    command: 'flutter run -d chrome --web-port=54577',
    url: 'http://127.0.0.1:54577',
    reuseExistingServer: !process.env.CI,
    timeout: 120 * 1000,
    stdout: 'pipe',
    stderr: 'pipe',
  },
});

