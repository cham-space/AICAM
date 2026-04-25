# AICAM v1.3.3 Release Notes

> **Release Date**: 2026-04-25
> **Since**: v1.3.2
> **Type**: Minor — security hardening + new command

---

## 🔐 Security

### Anti-Silent-Bypass Gate (P0-1 Fix)

**security.gate.md** gains **Layer 0: Tool Availability Pre-check** — executed before any scan:

| Condition | Action |
|-----------|--------|
| ≥1 native tool (gitleaks/semgrep) available | Proceed to actual scan |
| All native tools missing + Docker available | Use Docker fallback commands |
| All tools missing + no Docker | Present user with install options or `CONFIRM-SKIP` |
| No resolution achieved | **❌ BLOCKED** — commit refused |

**Docker fallback commands**:
- gitleaks: `docker run --rm -v "$(pwd)":/src zricethezav/gitleaks detect --source /src --no-git`
- semgrep: `docker run --rm -v "$(pwd)":/src returntocorp/semgrep semgrep scan --config=auto --error`

**commit.md** security scan restructured from advisory step to 3-step mandatory hard gate:
1. Tool Availability Check (Layer 0)
2. Execute Available Scans (run whichever layers are actually executable)
3. Gate Decision (read Gate Status Determination table → act on result)

**diagnose.md** Section 5 adds **Security Gate Viability** row:

| Condition | Status |
|-----------|--------|
| ≥1 native tool available | ✅ Gate functional |
| Docker available as fallback | ⚠️ Reduced — Docker-based scanning |
| No tools + no Docker | ❌ Gate non-functional — commits unprotected |

Tool table expanded: +Docker (fallback) row, +Commit-msg hook symlink check.

### .gitleaks.toml Fix

Removed unsupported top-level `title` key that caused gitleaks 8.x to fail config parsing (`toml: expected character =`). Replaced with comment to preserve the label.

---

## 🚀 New Command

### `/aicam` — Interactive Workflow Guide

In-app reference manual with 6 entry points, callable anytime without arguments for an interactive menu:

| Option | Content |
|--------|---------|
| 1. Workflow Overview | 5-Phase ASCII diagram + typical scenarios + quick-jump paths |
| 2. Command Reference | 16 commands grouped by Phase, one-line purpose each |
| 3. Navigate by Phase | "I'm at Phase X, what next?" — guidance per phase with gate rules and next-step prompts |
| 4. Skill Reference | 4 workspace skills + 4 superpowers skills, auto-trigger conditions, common traps |
| 5. Gate Reference | 6 gates with blocking conditions, exemption rules, and tool coverage |
| 6. Enablement Paths | L0-L3 with prerequisites, command sets, and guidance ("start with L1, upgrade anytime") |

**Direct command lookup**: `/aicam /execute`, `/aicam hotfix` — shows description, arguments, phase, pre-conditions, trigger type, related skills/gates, artifacts, and typical usage.

**16-command reference table** in the guide file provides phase association, trigger type, pre-condition, and next-step for every command in the system.

---

## 📝 Documentation

### WORKFLOW.md
- Version header updated to v1.3.3
- Version history: +v1.3.3 entry (security anti-bypass + /aicam)
- System components table: commands 15→16, `/aicam` added to command list
- Progressive enablement L0: `/hotfix` → `/hotfix, /aicam`
- Directory structure comment: 15→16 commands
- New principle #19: **Security scanning must not be silently skipped**

### README.md / README.en.md / README.zh.md
- All three variants synced to v1.3.3
- Version headers, history tables, system composition tables, L0 enablement paths updated
- Command count: 15→16 across all three files

### diagnose.md
- Section 5: +Security Gate Viability assessment, +Docker availability check
- Section 6.5: Chinese annotations translated to English
- Output format: Security section expanded with viability + Docker status

---

## 📁 Files Changed

| File | Action | Lines |
|------|--------|-------|
| `.claude/gates/security.gate.md` | Modified | +52 lines — Layer 0 pre-check + Docker fallback + resolution protocol |
| `.claude/commands/commit.md` | Modified | +36 / −14 — 3-step mandatory security scan flow |
| `.claude/commands/diagnose.md` | Modified | +20 / −14 — Security Gate Viability + English localization |
| `.claude/commands/aicam.md` | **New** | 387 lines — Interactive workflow guide |
| `.claude/WORKFLOW.md` | Modified | +10 / −8 — v1.3.3 sync + principle #19 |
| `README.md` | Modified | +4 / −2 — v1.3.3 sync |
| `README.en.md` | Modified | +16 / −2 — v1.3.3 sync |
| `README.zh.md` | Modified | +16 / −2 — v1.3.3 sync |
| `RELEASE-v1.3.3.md` | **New** | This file |
| `.gitleaks.toml` | Fixed | 1 line — removed unsupported `title` key |

---

## 📊 Commit History (since v1.3.2)

| Commit | Message |
|--------|---------|
| `d8025ad` | feat(workflow): update to v1.3.3 — security gate anti-silent-bypass + /aicam interactive guide |
| `81239af` | docs: add AICAM maturity assessment v1.3.2 |
| `6fe78a6` | fix: remove unsupported 'title' key from .gitleaks.toml |
| `c0dd6b7` | docs: release v1.3.3 — update README and create release notes |

---

## ⬆️ Upgrade from v1.3.2

```bash
# Copy changed files to your project
cp .claude/gates/security.gate.md /path/to/project/.claude/gates/
cp .claude/commands/commit.md /path/to/project/.claude/commands/
cp .claude/commands/diagnose.md /path/to/project/.claude/commands/
cp .claude/commands/aicam.md /path/to/project/.claude/commands/
cp .claude/WORKFLOW.md /path/to/project/.claude/

# Install at least one security tool (recommended):
brew install gitleaks

# Verify:
/diagnose
```

No breaking changes. All existing commands and gates continue to work as before.
