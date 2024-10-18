
import { test as base } from 'fixtures/global-hook'
import { config } from 'config/env.config'
import { login } from './login.util'

export const test = base.extend({
  page: async ({ page }, use) => {
    await login(page, config.USERNAME, config.PASSWORD)
    await use(page)
  },
})

export { expect, type Page } from '@playwright/test'
