---
name: tdd-gate
description: TDD gate — red-green-refactor cycle enforcement for all business logic tasks
severity: blocking
applies_to: [execute, hotfix]
---

# TDD Gate: Test-Driven Development

## Rule

Every business logic task must follow the red-green-refactor cycle:

1. **Red**: Write a failing test first
2. **Green**: Implement minimal code until the test passes
3. **Refactor**: Clean up while keeping tests green — no new behavior

## Exemptible Cases (require user approval)

- Config file changes (`.env`, `pyproject.toml`, `package.json` metadata)
- Database migration scripts (schema-only)
- Pure CSS/style changes
- Annotation/doc comment updates
- Dependency version upgrades (no logic changes)

## Non-Exemptible (mandatory TDD)

- Cross-boundary integration layers (IPC commands, REST endpoints, event publishers/subscribers, message queue consumers)
- UI components containing conditional logic, state management, or data transformation
- Any serialization/deserialization logic
- Error handling paths

## Exemption Request Protocol

Agent must **pause** and present:

```
⚠️ TDD Exemption Request — Task {N}: {task-name}
Reason: {reason}
Type: {type}
Confirm to proceed? (y/n):
```

For non-exemptible type exemptions, must also describe the alternative verification method.
If the answer is "manually check at runtime" → reject the exemption.

## Compliance Check

Read `## TDD Log` in summary.md:
- Every non-exempt task must have a Red/Green record
- Exempt tasks must have user confirmation evidence
- Missing records → **BLOCKED**

## Iron Law

If implementation code is written before the test → **delete the code** and start from the failing test.
Applies to bug fixes too: reproduce with a failing test before any fix code.
