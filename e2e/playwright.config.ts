import type { PlaywrightTestConfig } from '@playwright/test'
import { devices } from '@playwright/test'
require('dotenv').config()

/**
 * Read environment variables from file.
 * https://github.com/motdotla/dotenv
 */
// require('dotenv').config();

const BASE_URL = process.env.BASE_URL
const CLIENT_ID = process.env.CLIENT_ID || '1001'
const PW_DEFAULT_TIMEOUT = process.env.PW_DEFAULT_TIMEOUT
  ? parseInt(process.env.PW_DEFAULT_TIMEOUT)
  : 0

if (BASE_URL === undefined) {
  throw new Error(
    'BASE_URL is not defined! Please set the environment variable to the URL to reach the server.',
  )
}

const reporters: PlaywrightTestConfig['reporter'] = [
  ['html', { outputFolder: 'test-results/report', open: 'never' }],
  ['list'],
]

/**
 * See https://playwright.dev/docs/test-configuration.
 */
const config: PlaywrightTestConfig = {
  testDir: './src',
  /* Maximum time one test can run for. */
  timeout: PW_DEFAULT_TIMEOUT ? PW_DEFAULT_TIMEOUT * 3 : 30 * 1000,
  expect: {
    /**
     * Maximum time expect() should wait for the condition to be met.
     * For example in `await expect(locator).toHaveText();`
     */
    timeout: PW_DEFAULT_TIMEOUT ? PW_DEFAULT_TIMEOUT : 5 * 1000,
  },
  /* Run tests in files in parallel */
  fullyParallel: false,
  /* Fail the build on CI if you accidentally left test.only in the source code. */
  forbidOnly: !!process.env.CI,
  /* Retry on CI only */
  retries: process.env.CI ? 2 : 0,
  /* Retry on CI only */
  maxFailures: process.env.CI ? 6 : 0,
  /* Opt out of parallel tests on CI. */
  ...(process.env.CI ? { workers: 1 } : undefined),
  /* Reporter to use. See https://playwright.dev/docs/test-reporters */
  reporter: reporters,
  /* Shared settings for all the projects below. See https://playwright.dev/docs/api/class-testoptions. */
  use: {
    /* Maximum time each action such as `click()` can take. Defaults to 0 (no limit). */
    actionTimeout: 0,
    /* Base URL to use in actions like `await page.goto('/')`. */
    // baseURL: 'http://localhost:3000',

    /* Collect trace when retrying the failed test. See https://playwright.dev/docs/trace-viewer */
    trace: 'retain-on-first-failure',
    video: 'on-first-retry',
    baseURL: BASE_URL,
  },

  /**
   * include tests tagged with the CLIENT_ID, or with any feature flag, or tests not tagged at all
   * but without the bump on the client id, nor another CLIENT_ID
   */
  grep: [
    // include tests without any tag
    /^[^@]*$/,
  ],
  grepInvert: [
    // exclude tests with the !CLIENT_ID
    new RegExp(`@!${CLIENT_ID}`),
  ],

  /* Configure projects for major browsers */
  projects: [
    {
      name: 'chromium',
      use: {
        ...devices['Desktop Chrome'],
        /**
         * use the user-agent string used by the browser for downloads
         *   -- might need to be updated when updating the browsers
         *   -- at that time, looking also if the user-agent string is still needed or if it is the same as the default one
         */
        userAgent: 'App e2e tests Agent',
        viewport: { width: 1920, height: 1080 },

        launchOptions: {
          args: ['--user-agent=App e2e tests Agent'],

          /* settings to enable a proxy to watch the requests made by the browser */
          // proxy: {
          //   server: '127.0.0.1:8888',
          // },
        },
        // contextOptions: {
        //   /* settings to bypass certificate issues */
        //   ignoreHTTPSErrors: true,
        // },
      },
    },
    //
    // {
    //   name: 'firefox',
    //   use: {
    //     ...devices['Desktop Firefox'],
    //   },
    // },
    //
    // {
    //   name: 'webkit',
    //   use: {
    //     ...devices['Desktop Safari'],
    //   },
    // },

    /* Test against mobile viewports. */
    // {
    //   name: 'Mobile Chrome',
    //   use: {
    //     ...devices['Pixel 5'],
    //   },
    // },
    // {
    //   name: 'Mobile Safari',
    //   use: {
    //     ...devices['iPhone 12'],
    //   },
    // },

    /* Test against branded browsers. */
    // {
    //   name: 'Microsoft Edge',
    //   use: {
    //     channel: 'msedge',
    //   },
    // },
    // {
    //   name: 'Google Chrome',
    //   use: {
    //     channel: 'chrome',
    //   },
    // },
  ],

  /* Folder for test artifacts such as screenshots, videos, traces, etc. */
  outputDir: 'test-results/traces',

  /* Run your local dev server before starting the tests */
  // webServer: {
  //   command: 'npm run start',
  //   port: 3000,
  // },
}

export default config
