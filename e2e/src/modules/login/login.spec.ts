import { expect, test } from '@playwright/test'
import { config } from '../../config/env.config'

test('TS-1: Login with valid credentials', async ({ page }) => {
  await page.goto(config.BASE_URL)
  await page.getByLabel('Email').fill(config.USERNAME)
  await page.getByLabel('Password').fill(config.PASSWORD)
  await page.getByRole('button', { name: 'Sign In' }).click()

  await expect(page).toHaveURL(`${config.BASE_URL}/ui/dashboard`, {
    timeout: config.PW_DEFAULT_TIMEOUT,
  })
})
