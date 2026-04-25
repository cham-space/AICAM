---
name: smoke-gate
description: Smoke Test gate — runtime verification before Phase completion
severity: blocking
applies_to: [execute, hotfix]
---

# Smoke Test Gate: Runtime Verification

## Rule

After all validation commands pass, execute the Smoke Test Checklist from the plan file and verify the application works at runtime.

## Prerequisites

Plan file must contain `## Smoke Test Checklist` section.
- Missing → **STOP**: `"⚠ Plan is missing ## Smoke Test Checklist."`

## Execution Steps

1. Start application/service using the startup command from plan
2. Verify startup without crash
3. Execute each checklist item: Action → Expected Result → ✅/❌
4. Any ❌ → enter bug fix flow → re-run **full** Smoke Test
5. All ✅ → write `## Smoke Test Log` to summary.md

## Required Log Format

```markdown
## Smoke Test Log

**Date**: {date}
**All items passed**: ✅

| Action | Expected | Result |
|--------|----------|--------|
| {item} | {expected behavior} | ✅ PASS |
```

## Hard Rules

- `## Smoke Test Log` missing → Phase cannot proceed to /verify-phase
- Any ❌ or ⏸️ entry → Smoke Test Gate = ❌
- `⏸️ pending manual verification` → treated as ❌

## Runtime Health Checks (v1.3.0+)

In addition to checklist items, verify:
- App process is alive (not crashed silently)
- Core endpoint/route responds (HTTP 200 / equivalent)
- No `ERROR` level logs during startup
