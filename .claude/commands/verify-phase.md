---
description: "Verify a completed phase: compare plan vs implementation → run validation commands → produce structured report"
argument-hint: "[phase-name or plan-file-path]"
---

# Verify Phase: Implementation Audit

## Phase to Verify: $ARGUMENTS

## Mission

Systematically audit a completed implementation phase by comparing the **plan** against the **actual codebase**, running all validation commands, and producing a structured `PHASE{N}_VERIFICATION_REPORT.md` that enables `/close-phase` to archive and distill lessons.

**Core Principle**: Evidence over assumption. Every finding must be backed by a file read, command output, or diff — not guesswork.

> **Pre-requisite (Node 3-A)**: Code Review should be completed before running this command.  
> If not done, run `/requesting-code-review` first, or explicitly acknowledge and proceed.

---

## Process

### Step 1: Locate Artifacts

**Step 1a: Find the plan file**

If `$ARGUMENTS` is a file path, read it directly.
If `$ARGUMENTS` is a phase name (e.g., `phase3`), scan:
```
.agents/plans/{phase-name}*.md
.agents/plans/archive/{phase-name}*.md
```

If no plan is found, stop with:
> "Cannot verify without a plan file. Provide a path or phase name."

**Step 1b: Locate project context root**

Find the nearest `CLAUDE.md`. Its directory is `{PROJECT_ROOT}`.

**Step 1c: Check if already verified**

Look for `.agents/reports/PHASE{N}_VERIFICATION_REPORT.md`.
If found, warn: `"⚠ Verification report already exists. Proceeding will overwrite. Continue? (yes/no)"`

---

### Step 2: Parse the Plan

Read the plan file and extract:

1. **Expected deliverables** — Every file listed under "New Files to Create", "Files to Create", or "FILES TO CREATE"
2. **Validation commands** — Every command under "VALIDATION COMMANDS" or "VALIDATE:" blocks
3. **Acceptance criteria** — Every checkbox `- [ ]` item under "ACCEPTANCE CRITERIA" or "COMPLETION CHECKLIST"
4. **Testing strategy** — Test files and coverage targets
5. **Plan deviations already noted** — Any "Plan Deviations" section in the plan/summary
6. **Mandatory gates** — Unit tests, business workflow tests, and API naming consistency check (if applicable)
7. **Project Type** — Read the plan file's `## Project Type` section to get the detected project type.  
   If present, read the corresponding `.claude/reference/test-strategies/{type}.md` and use its "Business Workflow Verification" approach as the standard for the Business Workflow Tests Gate;  
   if the section is missing, fall back to default strategy (API workflow test / IPC direct call).

---

### Step 3: File Existence Audit

For each expected file from Step 2:

```
✅ EXISTS   — file found at expected path
⚠  MOVED    — not at expected path, but found elsewhere in workspace (note actual path)
❌ MISSING  — not found anywhere
```

Output a table:
```
| Expected Path | Status | Actual Path (if moved) |
|---------------|--------|------------------------|
| src/...       | ✅     | —                      |
| src/...       | ⚠      | src/other/path.ts      |
| src/...       | ❌     | —                      |
```

Count: `{X} ✅ found, {Y} ⚠ moved, {Z} ❌ missing out of {total} expected`

---

### Step 4: Run Validation Commands

Execute each validation command from the plan **in order**. For each:

```bash
# Command: {command}
# Purpose: {what the plan says it validates}
```

After running:
- **PASS** ✅ — Command exits 0, output matches expectations
- **FAIL** ❌ — Command exits non-zero or output shows errors
- **WARN** ⚠ — Command passes but with warnings

If a command fails:
1. Capture the error output
2. Load `systematic-debugging` Skill — complete Phase 1 root cause investigation before proposing any fix
3. Attempt **one** fix if the root cause is clear (e.g., missing import, typo)
4. Re-run once
5. If still failing, log it as a bug — **do not retry indefinitely**; verify-phase is a read-only audit — hand complex fixes back to the user

---

### Step 5: Acceptance Criteria Audit

**Before writing status conclusions**, load `verification-before-completion`.
Run verification commands in this step — do not rely on prior execution output.

For each acceptance criterion from the plan, determine status:
- ✅ **PASS** — verifiable from file existence + command output
- ❌ **FAIL** — missing file or failed validation command
- ⚠ **PARTIAL** — code exists but not fully functional / untested
- ⏭ **SKIP** — explicitly deferred or marked N/A in the plan

Additionally enforce gate outcomes:
- Unit tests must be evidenced by command output
- Business workflow tests must be evidenced by command output/artifacts
- If API is involved, naming mapping consistency must be evidenced

**⏸️ Hard Rule**:
- `⏸️ pending manual verification` in any Gate is treated as ❌ — not allowed to pass
- Business Workflow Tests status is ⏸️ → must provide an executable automated script (using mock/fixture), or user must explicitly confirm in writing: "Business workflow verification for this Phase is deferred to the next Phase" — note this as a risk in the report
- Smoke Test Log missing or contains ⏸️ entries → Smoke Test Gate status is ❌, blocking Phase close

---

### Step 6: Bug Catalogue

List every bug encountered during this verification (Step 4), plus any pre-existing bugs found by reading code:

For each bug:
```
### BUG-{N}: {short title} — {severity: Critical/High/Medium/Low}

**Symptom**: {what was observed}
**Root cause**: {why it happened}
**Fix**: {what was changed, or "not fixed"}
**Status**: ✅ Fixed | ❌ Unfixed | ⏭ Known/Deferred
```

**Bug Fix Path**:  
If the bug catalogue is non-empty, each fix requires, before the user proceeds:  
1. Complete root cause investigation using the `systematic-debugging` Skill (Phase 1)  
2. Write a failing test that reproduces the bug first (the TDD Iron Law applies to bug fixes too)  
3. Only after the fix is complete and tests are green may you proceed to `/close-phase`  
Do not close the Phase after directly patching code without a confirmed root cause.

---

### Step 7: Generate Verification Report

Write the report to `.agents/reports/PHASE{N}_VERIFICATION_REPORT.md`:

```markdown
# Phase {N} Verification Report

> Verified: {YYYY-MM-DD}
> Scope: {phase scope from plan, N tasks}
> Status: ✅ PASS | ⚠ CONDITIONAL | ❌ FAIL

---

## I. Environment & Dependency Check

| Check | Status | Notes |
|--------|------|------|
| {dependency} | ✅/❌ | {detail} |

---

## II. Task Completion

### Overview: {N} files ({M} planned + {extra} extra)

| Task Group | Task | Files | Status | Notes |
|--------|------|--------|------|------|

### Changes / Deviations

| Planned | Actual | Type |
|------|------|------|

---

## III. Validation Command Results

### Level 1: {command name}

```
{command output snippet — first 20 lines}
```

Result: ✅/❌ | {summary}

### Mandatory Gates

| Gate | Status | Evidence |
|------|--------|----------|
| Unit Tests | ✅/❌ | {command + short output} |
| Business Workflow Tests | ✅/❌ | {command/artifact path — ⏸️ not acceptable} |
| Smoke Test | ✅/❌ | Read `## Smoke Test Log` from summary.md; any ❌ entry or ⏸️ status counts as overall ❌ |
| Runtime Verified | ✅/❌ | Evidence that app/service was actually started (startup entry in Smoke Test Log is ✅) |
| API Naming Consistency (if applicable) | ✅/❌/N/A | {mapping/check evidence} |
| TDD Compliance | ✅/❌/N/A | {Read `## TDD Log` from summary.md — verify non-exempt task count matches TDD records; flag any missing entries or EXEMPT-without-user-confirmation entries} |

---

## IV. Bugs Found

{Bug catalogue from Step 6}

---

## V. Acceptance Criteria Audit

| Acceptance Criterion | Status | Notes |
|----------|------|------|

---

## VI. AC-Test Coverage Matrix

> Source: Spec-Lite AC list × test files declared in the plan (no full-repo scan).

| AC ID | Criterion | Covered By | Test File | Test Result | Status |
|-------|----------|------------|---------|---------|------|
| AC-1 | {description} | {describe > it name} | {path/to/test.ts} | PASS/FAIL | ✅/❌ |
| AC-2 | {description} | — | — | — | ⚠ No coverage |

> ACs with ⚠ No coverage are treated as PARTIAL and must be listed in fix priorities.

---

## VII. Fix Priority Recommendations

| Priority | ID | Issue | Fix Effort |
|--------|------|------|------------|
| P0 Blocking | | | |
| P1 High | | | |
| P2 Medium | | | |
| P3 Low | | | |
```

---

### Step 8: Present Summary

After writing the report, output a brief terminal summary:

```
## Phase {N} Verification Complete

Overall Status: ✅ PASS | ⚠ CONDITIONAL | ❌ FAIL

Files:     {X}/{total} present  ({Y} moved, {Z} missing)
Commands:  {P}/{total} passed   ({Q} failed, {R} warned)
Criteria:  {A}/{total} met      ({B} partial, {C} failed)
Bugs:      {blocking} blocking, {non_blocking} non-blocking
Mandatory Gates: Unit={PASS/FAIL}, Workflow={PASS/FAIL}, Smoke={PASS/FAIL}, Runtime={PASS/FAIL}, API Naming={PASS/FAIL/N/A}, TDD={PASS/FAIL/N/A}

Report written to: .agents/reports/PHASE{N}_VERIFICATION_REPORT.md

Next step:
- If Code Review not yet done → **strongly recommended** to run it first:  
  `BASE_SHA=$(git rev-parse HEAD~1)` + `HEAD_SHA=$(git rev-parse HEAD)`  
  Dispatch `superpowers:code-reviewer` subagent using the `code-reviewer.md` template; fix Critical/Important issues before archiving  
- Run `/close-phase {phase-name}` to archive and distill to CLAUDE.md
```

---

## Safety Rules

1. **Read before writing** — always read a file before concluding it exists and is correct
2. **Do not auto-fix unless trivial** — fixing bugs requires judgment; prefer logging over blind patching
3. **Never delete files** — verification is read-only except for the report file written in Step 7
4. **Command timeouts** — if a build/test command runs > 5 minutes without output, stop it and mark as TIMEOUT
5. **Scope discipline** — only verify what the plan specifies; do not audit unrelated code
