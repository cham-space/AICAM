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

### Destructive Operation Gate

Before executing ANY task, scan all commands and SQL in that task.
If any of the following patterns are detected, **STOP immediately** and present to the user before proceeding:

| High-Risk Operation | Example |
|---------|------|
| `TRUNCATE TABLE` | Wipes entire table, irreversible |
| `DROP TABLE` / `DROP DATABASE` | Deletes table/database structure and data |
| `DROP COLUMN` / `ALTER TABLE ... DROP` | Drops column, data loss |
| `DELETE` without WHERE | Deletes all rows in table |
| Column type change (may truncate data) | `ALTER TABLE ... MODIFY COLUMN` |
| `rm -rf` / batch file deletion | Irreversible file deletion |

**On detection, show the user:**
```
⚠ High-risk operation detected: `{command}`
Operation type: {TRUNCATE / DROP / unconditional DELETE, etc.}
Impact: {table/file path} — {estimated row count or description}
Is a backup in place? Please reply "confirm" to proceed, or explain why to skip.
```

**No auto-advance**: Must wait for explicit user confirmation before proceeding.

---

### TDD Gate (Node 2-A)

Before implementing each task:
1. Write the failing test first (unit or integration, as appropriate)
2. Confirm the test fails for the **right reason** (feature missing — not a typo, not testing existing behavior)
3. Implement **minimal** code until the test passes — do not add features beyond what the test requires
4. **REFACTOR**: After green, clean up duplication/names/helpers while keeping all tests green — do not add new behavior in this phase

**Iron Law**: If you discover implementation code was written before the test → **delete it**. Do not keep it as "reference". Start over from a failing test.  
**Applies to bug fixes too**: Before fixing any bug, you must first write a failing test that reproduces it.

**TDD Exemption Request (mandatory pause)**: The following cases may request an exemption, but the Agent must NOT decide on its own — must pause and present to the user:

```
⚠️ TDD Exemption Request — Task {N}: {task-name}
Reason: {reason}
Exemption type: config change / migration script / pure style / annotation update / dependency upgrade / other: {detail}
Confirm to proceed? (y/n):
```

User replies `n` → must re-execute using TDD flow.

**Exemptible cases**: config file changes, database migration scripts, pure style/CSS changes, annotation/doc comment updates, dependency version upgrades (no business logic changes).

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

### 5. Final Verification

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
