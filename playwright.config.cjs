const { defineConfig, devices } = require('@playwright/test');
const baseURL = process.env.MAKEEN_WEB_TEST_URL || 'http://127.0.0.1:8000';
if (!/^http:\/\/(localhost|127\.0\.0\.1):\d+$/.test(baseURL)) {
  throw new Error('Browser tests must run against local disposable app');
}
module.exports = defineConfig({
  testDir: './e2e',
  timeout: 90000,
  retries: process.env.CI ? 1 : 0,
  reporter: [['list'], ['html', { open: 'never' }]],
  use: { ...devices['Desktop Chrome'], baseURL, screenshot: 'only-on-failure', trace: 'retain-on-failure' },
});
