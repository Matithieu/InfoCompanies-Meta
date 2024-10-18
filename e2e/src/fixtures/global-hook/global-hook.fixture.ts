import { Page, test as base } from '@playwright/test'
import { config } from 'config/env.config'

class ErrorHandler {
  #errors: [string, string][] = []
  #consoleErrors: string[] = []
  #urlErrors: string[] = []

  constructor(page: Page) {
    this.#errors.push(['SyntaxError', `Unexpected token '<'`])

    this.#consoleErrors.push(
      'Failed to fetch', // mainly happens when the page is reloaded
    )

    page.on('pageerror', err => {
      // filter false positive errors
      if (this.#errors.some(([name, message]) => err.name === name && err.message === message)) {
        return
      }

      throw err
    })

    page.on('requestfinished', async request => {
      try {
        const statusCode = (await request.response())?.status()

        if (statusCode !== undefined && statusCode >= 400) {
          const url = request.url().replace(config.BASE_URL, '')
          throw new Error(`Failed request: ${url} - ${statusCode}`)
        }
      } catch (err) {
        // some responses might be received after the end of the test -- ignore them
        if (
          !(
            err instanceof Error &&
            err.message.match(/(Target page, context or )?browser has been closed/i)
          )
        ) {
          throw err
        }
      }
    })

    page.on('requestfailed', async request => {
      const errorMessage = request.failure()?.errorText ?? '-'

      if (errorMessage === 'net::ERR_ABORTED') {
        return
      }

      const url = request.url().replace(config.BASE_URL, '')
      throw new Error(`Failed request: ${url} - ${errorMessage}`)
    })

    page.on('console', async message => {
      if (message.type() === 'error') {
        const errorText = message.text()
        const errorUrl = message.location().url

        if (
          !this.#consoleErrors.some(msg => errorText.match(msg) !== null) &&
          !this.#urlErrors.some(url => errorUrl.includes(url))
        ) {
          throw new Error(`console error: ${errorText} - url: ${errorUrl}`)
        }
      }
    })
  }

  addExpectedPageError(name: string, message: string) {
    this.#errors.push([name, message])
  }
}

export type ErrorHandlerFixture = {
  errorHandler: ErrorHandler
}

export const test = base.extend<ErrorHandlerFixture>({
  errorHandler: [
    async ({ page }, use) => {
      await use(new ErrorHandler(page))
    },
    { auto: true },
  ],
})

export { expect, type Page } from '@playwright/test'
