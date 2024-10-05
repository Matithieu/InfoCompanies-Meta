import { sleep, check } from 'k6'
import { Options } from 'k6/options'
import { browser } from 'k6/browser'

// pnpm test ./src/tests/login-test.ts

export const options: Options = {
  scenarios: {
    browser_scenario: {
      executor: 'constant-vus', // The executor that will be used
      vus: 30, // The number of virtual users, don't put too much or it will crash :)
      duration: '10s', // The test duration
      options: {
        browser: {
          // Specify that we are using the browser executor
          type: 'chromium', // Choose the browser type: 'chromium' or 'firefox'
        },
      },
    },
  },
}

export default async () => {
  const username = 'local-admin@mail.com'
  const password = 'password'
  const baseUrl = 'https://localhost:5173/ui'

  const page = await browser.newPage()

  try {
    // Navigate to the login page
    await page.goto(baseUrl)
    sleep(1)

    // Pass the 'Your navigation is not private' warning
    // Add in local :)
    // await page.click('#details-button')
    // await page.click('#proceed-link')
    // sleep(1)

    // Click on the "Essai gratuit" button
    await page.click('//button[contains(text(), "Essai gratuit")]')
    sleep(2)

    // Fill in the login form
    await page.fill('input[name="username"]', username)
    await page.fill('input[name="password"]', password)

    // Click on the "Se connecter" button
    await page.click('button[name="login"]')

    sleep(3)

    check(page.url() === `${baseUrl}/dashboard`, {
      'Login successful': (r) => r === true,
    })
    await page.screenshot({ path: 'screenshot.png' })
  } finally {
    // Close the page after execution
    await page.close()
  }
}
