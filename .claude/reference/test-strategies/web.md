# Test Strategy: Web Frontend / SPA

## Project Type Identifier
`web` — Web frontend, SPA, Next.js, Nuxt, Vite + React/Vue/Svelte, etc.

### Detection Signals
| File | Signal |
|------|---------|
| `package.json` (without `src-tauri/`) | Web project |
| `next.config.*` | Next.js |
| `vite.config.*` | Vite |
| `nuxt.config.*` | Nuxt |
| `playwright.config.*` | Playwright already configured |

---

## Smoke Test Checklist

- [ ] `npm run dev` / `npm start` starts without compile errors
- [ ] Browser opens home page with no console Errors (warnings acceptable)
- [ ] Core routes are navigable (no 404 / blank screen)
- [ ] Network requests work normally (or MSW mock responds correctly)
- [ ] Production build `npm run build` completes without errors

---

## Business Workflow Verification

Use **Playwright** end-to-end tests:

### Setup
```bash
npm init playwright@latest
# Choose TypeScript, optionally enable GitHub Actions
```

### Base Config (`playwright.config.ts`)
```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  retries: process.env.CI ? 2 : 0,
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

### Typical Journey Template (`e2e/core-workflow.spec.ts`)
```typescript
import { test, expect } from '@playwright/test';

test('core user journey', async ({ page }) => {
  // Step 1: Navigate to home
  await page.goto('/');
  await expect(page).toHaveTitle(/App Name/);

  // Step 2: Core action
  await page.getByRole('button', { name: 'Start' }).click();
  await expect(page.getByTestId('result')).toBeVisible();

  // Step 3: Verify persistence
  await page.reload();
  await expect(page.getByTestId('result')).toContainText('expected content');
});
```

### Run Commands
```bash
npx playwright test          # All tests
npx playwright test --ui     # Interactive UI mode
npx playwright show-report   # View HTML report
```

---

## Unit Test Focus

| Layer | Test Subject | Approach |
|----|---------|---------|
| Component rendering | React/Vue components | Vitest + Testing Library |
| Store/state | Zustand / Pinia / Redux | Vitest pure function tests |
| Utility functions | Formatting, validation, transformation | Vitest |
| API Client | fetch/axios wrapper | Vitest + MSW |

---

## Mock Strategy

| External Dependency | Mock Approach |
|---------|---------|
| Backend REST API | **MSW** (`msw` + `setupServer`) — works in both unit tests and Playwright |
| Authentication (OAuth/JWT) | MSW mock token response |
| Browser APIs (localStorage, geolocation) | Vitest `vi.stubGlobal()` |
| Third-party SDKs | `vi.mock('library-name')` |

---

## Environment Variable Isolation

- Use `vi.stubEnv('NAME', 'value')` instead of directly modifying `process.env`
- Stub in `beforeEach`, call `vi.unstubAllEnvs()` in `afterEach`
- To simulate an unset variable, use an empty string: `vi.stubEnv('NAME', '')`
- Violating this rule causes state leakage between tests

---

## Evidence Requirements

- Smoke Test: `npm run dev` terminal + browser home page screenshot (no console Errors)
- Playwright tests: `npx playwright show-report` HTML report screenshot (with timeline)
- Key actions: Playwright trace key frame screenshots
