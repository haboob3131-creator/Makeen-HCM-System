const { test, expect } = require('@playwright/test');
// Flutter renders its UI through a canvas; these browser smoke tests
// do not replace the Flutter widget and device integration tests.
test('web runtime starts with no uncaught JavaScript errors', async ({ page }) => {
  const errors = [];
  page.on('pageerror', error => errors.push(error.message));
  const response = await page.goto('/', { waitUntil: 'domcontentloaded' });
  expect(response.status()).toBe(200);
  await expect(page.locator('flutter-view')).toBeVisible({ timeout: 60000 });
  await page.waitForTimeout(3500);
  expect(errors).toEqual([]);
});
test('mobile browser viewport shows the Flutter runtime', async ({ page }) => {
  await page.setViewportSize({ width: 390, height: 844 });
  const response = await page.goto('/', { waitUntil: 'domcontentloaded' });
  expect(response.status()).toBe(200);
  await expect(page.locator('flutter-view')).toBeVisible({ timeout: 60000 });
});
