# AICAM v1.3.3 Release Notes

> **Release date**: 2026-04-25
> **Previous version**: v1.3.2
> **Type**: Minor — feature enhancement + security hardening

---

## Summary

v1.3.3 addresses the P0-1 security vulnerability (silent bypass of security gate when scan tools are uninstalled) identified in the maturity assessment, and introduces `/aicam`, an interactive workflow guide command to lower the learning curve for new users.

---

## Changes

### Security — Anti-Silent-Bypass Gate

**security.gate.md** gains **Layer 0: Tool Availability Pre-check** that runs before any scan. When all three layers (gitleaks, semgrep, dependency audit) are unavailable:

1. Docker fallback is attempted
2. If Docker is also unavailable, user is presented with install options or a `CONFIRM-SKIP` acknowledgment
3. Without resolution → **commit is blocked**

**commit.md** security scan section is restructured into a 3-step mandatory flow (Tool Availability → Execute Available Scans → Gate Decision).

**diagnose.md** Section 5 adds **Security Gate Viability** assessment — at a glance visibility into whether the security gate can actually protect commits.

### New Command — /aicam

An interactive workflow guide with 6 entry points:

- Workflow overview (5-Phase diagram + typical scenarios)
- Command reference (16 commands grouped by phase)
- Per-phase navigation ("I'm at Phase X, what next?")
- Skill reference (auto-trigger conditions, traps)
- Gate reference (blocking conditions, exemptions)
- Progressive enablement paths (L0-L3)

Supports direct command lookup: `/aicam /execute`, `/aicam hotfix`, etc.

### Documentation

- New principle #19: Security scanning must not be silently skipped
- WORKFLOW.md, README.md, README.en.md, README.zh.md all synced to v1.3.3
- Command count: 15 → 16

---

## Files Changed

| File | Action | Description |
|------|--------|-------------|
| `.claude/gates/security.gate.md` | Modified | +Layer 0 tool availability pre-check + Docker fallback + resolution protocol |
| `.claude/commands/commit.md` | Modified | Security scan upgraded from advisory to 3-step mandatory hard gate |
| `.claude/commands/diagnose.md` | Modified | Section 5: +Security Gate Viability, +Docker status, English localization |
| `.claude/commands/aicam.md` | **New** | Interactive workflow guide with 6 entry points + command reference table |
| `.claude/WORKFLOW.md` | Modified | v1.3.3 header, version history, system composition (16 commands), principle #19 |
| `README.md` | Modified | v1.3.3 header, command count, version history |
| `README.en.md` | Modified | v1.3.3 header, version history, system composition, L0 path |
| `README.zh.md` | Modified | v1.3.3 header, version history (Chinese), system composition, L0 path |
| `.gitleaks.toml` | Fixed | Removed unsupported `title` key breaking gitleaks 8.x config parser |

---

## Upgrade Notes

```bash
# To upgrade from v1.3.2:
# 1. Copy the changed .claude/ files
cp .claude/gates/security.gate.md /path/to/project/.claude/gates/
cp .claude/commands/commit.md /path/to/project/.claude/commands/
cp .claude/commands/diagnose.md /path/to/project/.claude/commands/
cp .claude/commands/aicam.md /path/to/project/.claude/commands/
cp .claude/WORKFLOW.md /path/to/project/.claude/

# 2. Update README files if you maintain them
# 3. Verify: run /diagnose
# 4. Install at least one security tool if not present:
brew install gitleaks
```

No breaking changes. All existing commands and gates continue to work as before.
