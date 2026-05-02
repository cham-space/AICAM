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

## MCP Browser Verification (Playwright MCP interactive mode)

Use Playwright MCP for real-time browser verification with trace-level records. This mode complements script-based Playwright tests by generating human-readable snapshots, screenshots, and logs suitable for QA review and archival.

### When to Use

| Use MCP Mode | Use Script Mode |
|-------------|-----------------|
| Dev-time visual verification | CI regression pipeline |
| Trace-level QA evidence | Reproducible test automation |
| Exploratory testing | Pre-commit test gates |
| UI state snapshot comparison | Code coverage tracking |

### Tool Call Templates

**Navigation and Snapshot:**
```
mcp__playwright__browser_navigate → url: "{base_url}{path}"
mcp__playwright__browser_snapshot → captures accessibility tree of current page
```

**Interaction:**
```
mcp__playwright__browser_click → target: "{element description}"
mcp__playwright__browser_type → target: "{input}", text: "{value}"
mcp__playwright__browser_select_option → target: "{select}", values: ["{option}"]
mcp__playwright__browser_fill_form → fields: [{target, name, type, value}, ...]
```

**Evidence Collection:**
```
mcp__playwright__browser_take_screenshot → filename: ".agents/reports/mcp-traces/{phase}-{ac}-{step}.png"
mcp__playwright__browser_network_requests → filter: "/api/.*" (verify API calls)
mcp__playwright__browser_console_messages → level: "error" (check for JS errors)
```

### Smoke Test via MCP

For MCP-based Smoke Test, replace the static checklist with interactive verification:

1. Start dev server in background
2. `browser_navigate` to home page → `browser_snapshot` → verify core elements visible
3. `browser_console_messages` → confirm no errors at level "error"
4. `browser_navigate` to each key route → `browser_snapshot` → verify content
5. `browser_take_screenshot` for QA evidence

### Trace Storage

All MCP traces stored under `.agents/reports/mcp-traces/`:
- `{phase}-{ac-id}-{step}.snapshot.md` — accessibility snapshots
- `{phase}-{ac-id}-{step}.png` — screenshots
- `{phase}-{ac-id}-network.md` — network request logs
- `{phase}-{ac-id}-console.md` — console message logs
- `{phase}-index.md` — per-phase trace index

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
