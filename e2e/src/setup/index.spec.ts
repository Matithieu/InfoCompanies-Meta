import fs from 'node:fs'
import { test, expect } from '@playwright/test'
import { chromium, ConsoleMessage, LaunchOptions } from '@playwright/test'

// Launch options.
// const options: LaunchOptions = {
//   headless: false,
//   // slowMo: 1000,
//   args: [
//     // enable chromium logs
//     // '--enable-logging=stderr',
//     // '--v=1',

//     // enable clipboard read on unsecure hosts
//     ...('localhost'.startsWith('http://')
//       ? [`--unsafely-treat-insecure-origin-as-secure=$localhost`]
//       : []),
//   ],
// }

// Create a global browser for the test session.
test.beforeAll(async function () {})

test.afterAll(async () => {})
