---
name: coverage-gate
description: Test coverage gate — minimum coverage thresholds per project type
severity: blocking
applies_to: [execute, verify-phase, commit]
---

# Coverage Gate: Test Coverage Thresholds

## Rule

Unit tests and business workflow tests must achieve minimum coverage thresholds.
Tests must assert behavior, not implementation details.

## Per-Type Thresholds

| Project Type | Unit Test Coverage | Business Workflow Test |
|-------------|-------------------|----------------------|
| `web` (SPA) | ≥ 75% line coverage | ≥ 1 flow per user story |
| `tauri` | ≥ 70% line coverage | IPC command coverage ≥ 80% |
| `rest-api` | ≥ 80% line coverage | API endpoint coverage ≥ 100% |
| `cli` | ≥ 72% line coverage | Subcommand coverage ≥ 80% |
| `worker` | ≥ 75% line coverage | Message type coverage ≥ 80% |
| `mobile` | ≥ 68% line coverage | ≥ 1 flow per screen |

## Covered: What Tests Must Validate

- ✅ Core happy path per function
- ✅ At least one failure/error path per function
- ✅ Edge cases: nulls, empty collections, zero values, max values
- ✅ Assertions on behavior (what the code does), not implementation (how it does it)

## Not Covered: Reduced Thresholds For

- Pure data classes / POJOs / structs without logic
- Generated code (protobuf, OpenAPI codegen)
- Framework boilerplate (route registrations, config wiring)

## Coverage-to-AC Mapping

Each acceptance criterion in Spec-Lite must be covered by at least one test case.
Uncovered ACs → `⚠ No coverage` in AC-Test Coverage Matrix → auto-listed in fix priorities.

## Hard Rules

- Coverage below threshold → **BLOCK** Phase completion
- Business Workflow Test missing entirely → **BLOCK**
- AC with no coverage → ⚠️ warn, log in iteration journal, does not block

## Coverage Measurement Tools (v1.3.1)

Use the appropriate tool for your ecosystem. Results feed into CI and `/verify-phase`:

| Ecosystem | Tool | Command |
|-----------|------|---------|
| npm (Vitest) | `@vitest/coverage-v8` | `npx vitest run --coverage` |
| npm (Jest) | `jest --coverage` / `@jest/coverage-istanbul` | `npx jest --coverage` |
| cargo | `cargo-tarpaulin` / `cargo-llvm-cov` | `cargo tarpaulin --out Html --out Json` |
| python | `pytest-cov` / `coverage.py` | `pytest --cov --cov-report=term-missing` |
| go | built-in `go test -cover` | `go test ./... -cover -coverprofile=coverage.out` |

**CI integration**: The `unit-tests` job in `.github/workflows/aicam-gates.yml` runs the ecosystem-appropriate coverage command. Coverage output is compared against the thresholds defined above. If the tool is not installed, coverage check falls back to AI manual estimation in `/verify-phase`.
