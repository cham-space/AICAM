# Test Strategy: Mobile App (React Native / Flutter / Native)

## Project Type Identifier
`mobile` — iOS / Android native or cross-platform mobile apps (React Native, Flutter, SwiftUI, Kotlin)

---

## Smoke Test Checklist

- [ ] App installs and launches on simulator/device without crash
- [ ] First screen core elements are visible (App bar / Tab bar / Login page)
- [ ] Network requests reach backend (or mock server responds correctly)
- [ ] Navigate to main screens without blank screen or errors

---

## Business Workflow Verification

Use **Detox (React Native) / Maestro (cross-framework) / XCUITest (iOS) / Espresso (Android)**:

1. Start a real simulator
2. Execute core user journey (from launch to completing key action)
3. Assert: target page elements exist / text content is correct
4. Record screenshots or screen recording throughout

### Typical Journey Template
```
Step 1: Cold start → first screen loaded (element assertion)
Step 2: Core action (form fill / tap / swipe) → result screen appears
Step 3: Exit → restart → state persistence verified (cache/local storage)
```

---

## Unit Test Focus

| Layer | Test Subject | Assertions |
|----|---------|------|
| Business logic | ViewModel / BLoC / Store | Pure functions, no UI dependency |
| Data layer | Repository / API client | Mock HTTP responses |
| Local storage | SQLite / SharedPreferences | CRUD correctness |
| Utility functions | Formatting / validation / transformation | Boundary value coverage |

---

## Mock Strategy

| External Dependency | Mock Approach |
|---------|---------|
| Backend API | `msw` (RN) / `Mockito` (Android) / `OHHTTPStubs` (iOS) |
| Device capabilities (camera/GPS/push) | Platform-provided Mock APIs |
| Local database | In-memory SQLite / fake SharedPreferences |
| Native modules | Jest mock (RN) / XCTest stub |

---

## Evidence Requirements

- Smoke Test: Simulator launch screenshot + first screen elements mounted screenshot
- Business workflow: Screenshot sequence of key steps (or .gif / screen recording clip)
- State persistence: Before/after restart screenshot comparison
