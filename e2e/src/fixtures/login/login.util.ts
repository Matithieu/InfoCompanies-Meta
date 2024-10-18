import { Page } from '@playwright/test'

import { asserts } from 'utils/assertion.util'
import { config } from 'config/env.config'

export async function login(page: Page, username: string, password: string) {
  const loginResponse = await page.request.get('/')

  if (loginResponse.status() !== 200) {
    throw new Error(`Got ${loginResponse.status()} from ${loginResponse.url()}`)
  }

  if (config.BASE_URL === 'http://localhost:5173') {
    return
  }

  const loginBody = await loginResponse.text()
  const action = loginBody
    .replace(/^[\s\S]+action="(https?:[^"]+)"[\s\S]+$/m, '$1')
    .replace(/&amp;/g, '&')
  const authenticateResponse = await page.request.post(action, {
    form: { username: username, password: password },
    maxRedirects: 0,
  })

  let location = authenticateResponse.headers().location

  if (location && location.includes('required-action')) {
    const actionResponse = await page.request.get(location)

    if (actionResponse.status() !== 200) {
      throw new Error(`Got ${actionResponse.status()} from ${actionResponse.url()}`)
    }

    const actionBody = await actionResponse?.text()
    const action2 = actionBody
      .replace(/^[\s\S]+action="(https?:[^"]+)"[\s\S]+$/m, '$1')
      .replace(/&amp;/g, '&')
    const actionPostResponse = await page.request.post(action2, {
      form: { accept: 'Accept' },
      maxRedirects: 0,
    })
    location = actionPostResponse.headers().location
  }

  asserts(location !== undefined, 'Location header is not defined')

  await page.request.get(location, { maxRedirects: 0 })
}

export async function logout(page: Page) {
  await page.click('#user-menu')
  await page.getByText('Logout').click()
}
