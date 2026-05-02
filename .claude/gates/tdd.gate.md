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

## MCP Verification Mode (v1.4.0+)

For UI components with visual feedback, MCP browser interaction MAY serve as TDD evidence in place of script-based assertions, as a **supplement to** (not replacement for) L1 unit test assertions.

### Applicable Types (L2 visual verification)
- UI components with conditional rendering (disabled/enabled, visible/hidden)
- Page-level user flows (form submission, navigation, state transitions)
- Responsive layout verification
- Accessibility state changes (aria-*, focus, keyboard navigation)

### NOT Applicable (still requires script-based L1 test)
- Business logic without visual representation
- API contracts, data serialization, error handling paths
- Performance or timing assertions

### RED Evidence Requirements
1. `browser_navigate` to target page
2. `browser_snapshot` showing the ABSENCE of expected state
3. Explicit assertion statement (what SHOULD exist but DOESN'T)
4. Evidence file path: `.agents/reports/mcp-traces/{task-id}-red-snapshot.md`

### GREEN Evidence Requirements
1. `browser_navigate` to same page after implementation
2. `browser_snapshot` showing the PRESENCE of expected state
3. Same assertion statement, now confirmed passing
4. Evidence file path: `.agents/reports/mcp-traces/{task-id}-green-snapshot.md`

### TDD Log Format (extended)

| Task | Mode | RED Evidence | GREEN Evidence | Result |
|------|------|-------------|----------------|--------|
| 3 | unit | test/foo.spec.ts | - | PASS |
| 4 | mcp | task-4-red-snapshot.md | task-4-green-snapshot.md | PASS |

### Hard Rules
- L1 (expect() script) remains mandatory for all non-exempt Tasks
- L2 (MCP snapshot) is required for UI component Tasks as incremental visual verification
- MCP mode RED/GREEN is equivalent to script mode RED/GREEN — both require seeing "wrong" before "right"
- Missing L1 evidence → BLOCKED (same as before)
- Missing L2 evidence for UI Tasks → WARNING (non-blocking, but must be noted in summary.md Plan Deviations)
