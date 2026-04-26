---
description: Create an atomic commit for current changes
argument-hint: "[optional: commit scope or message hint]"
---

# Commit: Create Atomic Commit

## Pre-Commit Verification

Before committing, verify the workspace is clean:

```bash
git status
git diff HEAD
```

Check that no unintended files are staged:
- Exclude `.agents/` intermediate artifacts unless intentional
- Exclude `.env`, secrets, or local-only config files
- Verify `.gitignore` covers generated/temp files

**Security scan (mandatory)** — execute gate from `.claude/gates/security.gate.md`:

1. **gitleaks**: `gitleaks detect --source . --no-git --verbose`
2. **semgrep**: `semgrep scan --config=auto --error --quiet`
3. **Dependency audit**: detect ecosystem → run corresponding audit command

### Gate Decision

Read gate status from `.claude/gates/security.gate.md` Gate Status Determination table.
- ❌ BLOCKED → fix findings before proceeding
- ⚠️ PASS → log and continue
- ✅ PASS → continue to commit

If tests exist, confirm they pass before proceeding:
```bash
# Run whatever test command is defined in CLAUDE.md Commands section
```

## Change Classification

Analyze the staged/unstaged changes and classify using Conventional Commits:

| Type | When to use |
|------|-------------|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `refactor` | Code restructure, no behavior change |
| `test` | Adding or fixing tests |
| `chore` | Build, tooling, dependency updates |
| `style` | Formatting, whitespace (no logic change) |

## Atomic Commit Strategy

- **One logical change per commit** — if changes span multiple unrelated concerns, stage and commit separately
- If changes are interdependent (e.g., model + migration + service), they belong in one commit
- If changes are independent (e.g., feature + unrelated refactor), split into two commits

## Commit Message Format

```
<type>(<scope>): <short summary>

[optional body: what changed and why, not how]

[optional footer: references, breaking changes]
```

**Rules:**
- Summary line: ≤ 72 characters, imperative mood ("add X", not "added X")
- Scope: the affected module, layer, or feature (e.g., `auth`, `user-api`, `db`)
- Body: only when the "why" is non-obvious

**Example:**
```
feat(user-api): add email verification endpoint

Adds POST /users/verify-email that validates token and activates account.
Required for onboarding flow defined in Phase 2 spec.
```

## Execute Commit

```bash
git add <files>
git commit -m "<message>"
```

## Post-Commit

After committing, confirm:
- `git log --oneline -3` shows the new commit

Then prompt based on context:
- If this is a mid-phase checkpoint: `"Commit complete. Continue with next task or run /verify-phase when ready."`
- If this is a post-archive final commit: `"Commit complete. This phase is fully archived and committed. Next: /plan-feature for the next phase."`

