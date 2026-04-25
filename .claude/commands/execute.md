---
description: Execute an implementation plan
argument-hint: [path-to-plan]
---

# Execute: Implement from Plan

## Plan to Execute

Read plan file: `$ARGUMENTS`

## Execution Instructions

### 1. Read and Understand

- Read the corresponding Spec-Lite: `.agents/specs/{phase-name}.spec.md`
  - If Spec-Lite is missing → **STOP** and warn: `"⚠ Spec-Lite not found. Run /plan-feature first."`
- Read the ENTIRE plan carefully
- Understand all tasks and their dependencies
- Note the validation commands to run
- Review the testing strategy

**AC ↔ Task Mapping Check (warning only — does not block):**

Cross-check Spec-Lite AC list against plan Tasks:
- `⚠ AC-{N} has no corresponding Task` → potential feature gap; mention to user before proceeding
- `⚠ Task "{name}" is not linked to any AC` → scope creep risk; mention to user before proceeding

### Destructive Operation Gate

Execute gate from `.claude/gates/destructive-op.gate.md`:
- Scan all commands and SQL before executing any task
- On detection → STOP and present impact to user
- Wait for explicit "confirm" — no auto-advance

---

### TDD Gate (Node 2-A)

Execute gate from `.claude/gates/tdd.gate.md`:
- Red (failing test) → Green (minimal code) → Refactor
- Non-exemptible types: IPC/REST/events, conditional UI, serialization, error handling
- Exemption requires user approval with reason
- Iron Law: code written before test → delete and restart

### 2. Execute Tasks in Order

For EACH task in "Step by Step Tasks":

#### a. Navigate to the task
- Identify the file and action required
- Read existing related files if modifying

#### b. Implement the task
- Follow the detailed specifications exactly
- Maintain consistency with existing code patterns
- Include proper type hints and documentation
- Add structured logging where appropriate

#### c. Verify as you go
- After each file change, check syntax
- Ensure imports are correct
- Verify types are properly defined

#### d. TDD Declaration (mandatory)

Every non-exempt task must append the following record to `.agents/plans/{phase-name}.summary.md` under `## TDD Log`:

```
- Task {N} {task-name}:
  - Test: {test_file}#{test_name}
  - Red:  {test command} → FAILED ✅
  - Green: {test command} → PASSED ✅
```

Exempt tasks (user-confirmed) must record:

```
- Task {N} {task-name}: EXEMPT — {user-confirmed reason}
```

> If `## TDD Log` section does not exist in the summary file, create it.

### 3. Implement Testing Strategy

After completing implementation tasks:

- Create all test files specified in the plan
- Implement all test cases mentioned
- Follow the testing approach outlined
- Ensure tests cover edge cases

### 4. Run Validation Commands

Execute ALL validation commands from the plan in order:

```bash
# Run each command exactly as specified in plan
```

If any command fails:
- Capture the error output
- Load `systematic-debugging` Skill — complete Phase 1 (root cause investigation) **before** proposing any fix
- **Do not propose any fix before identifying the root cause**
- Attempt **one** fix based on the identified root cause
- Re-run the command
- If still failing, repeat: re-investigate → one fix → re-run (max 3 attempts total)
- **3 failed attempts → STOP**: Question the current architecture, present all attempted paths to the user, and wait for their decision before continuing — do not attempt a 4th fix automatically
- If a command passes, continue to next

**Hard gate (cannot skip):**
- Unit tests must pass
- Business workflow tests must pass (UI E2E or API workflow tests)
- If API was touched, contract/naming validation from the plan must pass

### 5. Smoke Test（Mandatory Gate — cannot skip）

Execute gate from `.claude/gates/smoke.gate.md`:

**5a. Read the checklist**

Read `## Smoke Test Checklist` from the plan file. Missing → STOP.

**5b. Start the application**

Start app/service; verify no crash. Crash → bug fix → re-run Smoke Test.

**5c. Execute each checklist item**

Record each item as ✅ PASS / ❌ FAIL.
Any ❌ → bug fix → re-run **entire** Smoke Test.

**5d. Write the log**

All ✅ → append `## Smoke Test Log` to `.agents/plans/{phase-name}.summary.md`.

**Runtime health checks**: verify app process alive, core endpoint responds, no ERROR logs during startup.

**Hard gate**: `## Smoke Test Log` missing, or any ❌/⏸️ entry = Phase cannot proceed to `/verify-phase`.

### 6. Final Verification

Before completing, load the `verification-before-completion` skill.
Run all verification commands fresh — evidence before assertions.

**Gate**: "NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE."

- ✅ All tasks from plan completed
- ✅ All tests created and passing
- ✅ All validation commands pass
- ✅ Unit + Business workflow gates both passed
- ✅ Code follows project conventions
- ✅ Documentation added/updated as needed

## Output Report

Provide a summary:

### Completed Tasks
- List of completed tasks
- Created files (with paths)
- Modified files (with paths)

### New Tests

| Type | Test File | Test Case Name | Covers AC | Result |
|------|----------|------------|----------|------|
| Unit | {path/to/test.ts} | {test name} | AC-{N} | ✅/❌ |
| Workflow | {path/to/e2e.ts} | {test name} | AC-{N} | ✅/❌ |

> Source: test files declared in plan file + test files created/modified this run. AC numbers correspond to acceptance criteria in Spec-Lite.

### Validation Results
```bash
# Output from each validation command
```

### Mandatory Gate Status
- Unit Tests: PASS/FAIL
- Business Feature Tests: PASS/FAIL
- API Contract/Naming (if applicable): PASS/FAIL

### Ready to Commit
- Confirm all tasks completed
- Confirm all validations passed
- Ready to execute `/commit`

### Phase Summary (auto-generated)

After all tasks and validations pass, generate a Phase summary file for `/close-phase` archival:

**Save path**: `.agents/plans/{plan-name}.summary.md`

**Format**:
```markdown
# Phase Summary: {feature name}

**Completion date**: {date}
**Plan file**: {path to the plan that was executed}

## Scope
{one-sentence description of what this Phase delivered}

## Output
- **New files**: {count} ({list key files})
- **Modified files**: {count}
- **New tests**: {count} tests across {count} test files
- **Database migrations**: {count, if any}

## Test Cases

### Unit Tests
| Test File | Test Case Name | Covers AC | Result |
|----------|------------|---------|------|
| {path/to/test.ts} | {describe > it name} | AC-{N} | ✅/❌ |

### Business Workflow Tests
| Test File | Test Case Name | Covers AC | Result |
|----------|------------|---------|------|
| {path/to/e2e.ts} | {scenario name} | AC-{N} | ✅/❌ |

> Test case names are extracted directly from describe/it/test function names in test files; AC numbers correspond to acceptance criteria in `.agents/specs/{phase}.spec.md`.

## Plan Deviations
{list differences between plan and actual implementation:
- File renames, additions, or skips
- Architecture changes during implementation
- Task reordering or merging}

## Bugs Found and Fixed
{list bugs found during implementation:
- BUG-N: {description} → {fix}}

## Unresolved Issues
{known issues deferred to future Phases}

## Lessons Learned
{process or technical insights for future Phases reference}
```

Then prompt:
> "Phase execution complete.  
> **⚠️ MANDATORY NEXT STEP**: **Open a NEW conversation**, then run `/code-review {plan-file-path}`.  
> Execute in a new session to ensure reviewer context is clean, avoiding implementation context pollution.  
> This is a **hard gate** — `/verify-phase` will warn and request confirmation if code review was skipped.
>
> **Steps (in order)**:  
> 1. 🆕 Open new conversation → `/code-review {plan-file-path}` — fix all Critical issues, review Important issues  
> 2. `/verify-phase {plan-file-path}` — compliance audit (requires code review passed)  
> 3. `/close-phase` → `/commit`"

## Notes

- If you encounter issues not addressed in the plan, document them
- If you need to deviate from the plan, explain why
- If tests fail, fix implementation until they pass
- Don't skip validation steps
