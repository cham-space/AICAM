---
description: "Emergency bug fix: skip Phase 1 planning, jump directly to implementation — TDD + Smoke Test + Code Review gates still apply"
argument-hint: "[bug description or issue reference]"
---

# Hotfix: Emergency Bug Fix

## Bug to Fix: $ARGUMENTS

## Mission

Apply a targeted fix for a production or critical bug without running a full Phase 1 planning cycle.

**What is skipped**: Phase 1 (plan-feature, Spec-Lite generation)  
**What is NOT skipped**: TDD gate, Smoke Test, Code Review, verify-phase, close-phase  

> Use hotfix only for bugs where the fix scope is clear and narrow. If investigation reveals significant scope (new features, DB migrations, multi-module changes), stop and run `/plan-feature` instead.

---

## Process

### Step 0: Scope Check

Before starting:
- State the bug in one sentence: what breaks, where, and what the expected behavior is
- Estimate impact: which file(s) will be touched?
- If more than **3 files** or the fix requires a **new API/DB migration** → STOP:
  > "⚠ This hotfix exceeds narrow scope. Run `/plan-feature` instead."

---

### Step 1: Create Hotfix Plan (inline — no separate plan file required)

Generate a minimal plan directly in the summary:

**Save path**: `.agents/plans/hotfix-{YYYY-MM-DD}-{slug}.summary.md`

```markdown
# Hotfix Summary: {bug description}

**Date**: {date}
**Type**: hotfix
**Bug**: {one-sentence description}
**Root Cause**: {identified root cause — fill after investigation}
**Fix Scope**: {list of files to change}

## Smoke Test Checklist
- [ ] {specific scenario that reproduces the bug — must pass after fix}
- [ ] {related adjacent scenarios that must not regress}

## TDD Log
(to be filled during implementation)

## Smoke Test Log
(to be filled after fix)
```

---

### Step 2: Reproduce and Root Cause

1. Write a failing test that **reproduces the bug**:
   - Unit test if the bug is in isolated logic
   - Integration test if it requires multiple components
2. Confirm the test fails for the right reason (bug present — not a test typo)
3. Read the failing code to identify root cause

**Iron Law**: Do not write any fix code before the reproducing test is red.

---

### Step 3: Destructive Operation Gate

Same as `/execute`. Before ANY command, scan for:

| High-Risk Operation | Action |
|---------|------|
| `DROP`, `TRUNCATE`, `DELETE` without WHERE, `rm -rf` | STOP, present to user, wait for "confirm" |

---

### Step 4: Implement the Fix

- Write **minimum code** to make the failing test green
- Do not refactor adjacent code
- Do not add features beyond fixing the bug
- After green: clean up duplication/names only — no new behavior

Record TDD log in the summary:
```
- Hotfix {bug-slug}:
  - Test: {test_file}#{test_name}
  - Red:  {test command} → FAILED ✅
  - Green: {test command} → PASSED ✅
```

---

### Step 5: Run Validation

Run all existing tests to verify no regressions:
```bash
# Run full test suite — no targeted-only testing for hotfixes
{unit-test-command}
{e2e-or-integration-command}
```

If any existing test breaks → fix the regression before proceeding. Max 3 attempts per broken test.

---

### Step 6: Smoke Test (Mandatory Gate)

Execute the `## Smoke Test Checklist` from the summary file:

| Action | Expected | Result |
|--------|----------|--------|
| {checklist item} | {expected behavior} | ✅ PASS / ❌ FAIL |

Any ❌ → fix and re-run full Smoke Test.

All ✅ → write `## Smoke Test Log` table to the summary file.

**Hard gate**: Smoke Test Log missing or any ❌/⏸️ = cannot proceed to Code Review.

---

### Step 7: Completion Prompt

> "Hotfix implementation complete.
> **⚠️ MANDATORY NEXT STEPS** (in order):
> 1. 🆕 Open new conversation → `/code-review .agents/plans/hotfix-{date}-{slug}.summary.md`
> 2. Fix all Critical issues from Code Review
> 3. `/verify-phase .agents/plans/hotfix-{date}-{slug}.summary.md`
> 4. `/close-phase hotfix-{date}-{slug}`
> 5. `/commit`"

---

## Safety Rules

1. **Narrow scope discipline**: If you discover the bug requires touching more than estimated, stop and report to the user before continuing
2. **TDD is non-negotiable**: No fix code before a failing test — this applies even under time pressure
3. **No silent refactoring**: Only change code directly related to the bug
4. **Archive as hotfix**: The CLAUDE.md iteration log entry must be tagged `[hotfix]` to distinguish from regular Phase iterations
