---
description: Diagnose workflow health — run one-click system integrity check
argument-hint: ""
---

# Diagnose: AICAM Workflow Health Check

## Mission

Run a non-destructive system audit: check file integrity, gate status, context budget, and metrics. Output a structured health report.

## Checks

### 1. CLAUDE.md Health

Read `CLAUDE.md` and check:
- File exists? ✅/❌
- Iteration log entry count? (count `### Phase N:` lines)
- Total line count? (warn if > 150)
- Last archive date? (extract from most recent Phase entry)

### 2. Phase Artifact Status

Scan `.agents/plans/` (exclude `archive/`):
- Active plan files (count)
- Unarchived summary files (count — warn if > 0)
- Orphaned plans (no matching Spec-Lite)
- Total `.md` size in KB

### 3. Spec-Lite Coverage

Compare plans vs specs:
- Plan count in `.agents/plans/` vs Spec-Lite count in `.agents/specs/`
- Missing Spec-Lite files (list)

### 4. Gate Configuration

| Gate File | Expected Path | Status |
|-----------|--------------|--------|
| TDD Gate | `.claude/gates/tdd.gate.md` | ✅/❌ |
| Smoke Gate | `.claude/gates/smoke.gate.md` | ✅/❌ |
| Security Gate | `.claude/gates/security.gate.md` | ✅/❌ |
| Contract Gate | `.claude/gates/contract.gate.md` | ✅/❌ |
| Destructive Op Gate | `.claude/gates/destructive-op.gate.md` | ✅/❌ |
| Coverage Gate | `.claude/gates/coverage.gate.md` | ✅/❌ |

### 5. Security Tooling

**Security Gate Viability** — can the gate actually execute?

| Condition | Status |
|-----------|--------|
| ≥1 native tool (gitleaks/semgrep) available | ✅ Gate functional |
| Docker available as fallback | ⚠️ Reduced — Docker-based scanning |
| No tools + no Docker | ❌ Gate non-functional — commits unprotected |

| Tool | Check | Status |
|------|-------|--------|
| gitleaks | `which gitleaks` | ✅ Installed / ❌ Missing |
| semgrep | `which semgrep` | ✅ Installed / ❌ Missing |
| Docker (fallback) | `which docker` | ✅ Available / ❌ Missing |
| Pre-commit hook | `.githooks/pre-commit` exists + executable | ✅/❌ |
| Commit-msg hook | `.githooks/commit-msg` exists + `.git/hooks/commit-msg` is symlink | ✅/❌ |
| CI pipeline | `.github/workflows/aicam-gates.yml` exists | ✅/❌ |

### 6. Skills Inventory

| Skill | Path | Loaded? |
|-------|------|--------|
| frontend-design | `.claude/skills/frontend-design/SKILL.md` | ✅/❌ |
| api-contract-first | `.claude/skills/api-contract-first/SKILL.md` | ✅/❌ |
| e2e-test | `.claude/skills/e2e-test/SKILL.md` | ✅/❌ |
| backend-test | `.claude/skills/backend-test/SKILL.md` | ✅/❌ |

### 6.5. Gate Execution Completeness (v1.3.1 — anti-truncation)

Read the most recent `.agents/plans/*.summary.md` and check:

- `## TDD Log` section exists and is non-empty? ✅/❌ (missing = gate truncated or bypassed)
- `## Smoke Test Log` section exists? ✅/❌ (missing = Smoke Gate not executed or truncated)
- Non-exempt tasks in plan vs TDD Log entries: {logged}/{total} (gap = gate truncated/skipped)

Output warnings:
- Any ❌ → `⚠ Gate execution evidence incomplete — possible context truncation or bypass`
- All ✅ → `✅ Gate execution evidence complete`

### 7. Metric Snapshot (if TEST_DASHBOARD exists)

Read `.agents/reports/TEST_DASHBOARD.md` and extract:
- Most recent Phase metric row
- Phase cycle time trend (last 3 phases)
- Test density trend (tests/AC)
- Any metrics below threshold? (list warnings)

## Output Format

```
╔══════════════════════════════════════════════════════════╗
║           AICAM Workflow Health Report                   ║
║           {date}                                         ║
╚══════════════════════════════════════════════════════════╝

📋 CLAUDE.md
   ✅ Exists · {N} phase entries · {N} lines · Last archive: {date}
   {warnings if any}

📦 Phase Artifacts
   ✅ Active plans: {N} · Unarchived: {N} · Total: {N}KB
   {warnings if any}

📐 Spec-Lite Coverage
   ✅ {N} plans / {N} specs · Coverage: {percent}%
   {missing specs list if any}

🔒 Security
   Gate viability: {✅ Functional / ⚠️ Docker fallback / ❌ Non-functional}
   gitleaks: {status} · semgrep: {status} · Docker: {status}
   Pre-commit hook: {status} · Commit-msg hook: {status} · CI pipeline: {status}

🚦 Gates
   {N}/{total} gate files present
   {missing gates list if any}

🛠️ Skills
   {N}/{total} skills present
   {missing skills list if any}

📊 Metrics (last 3 phases)
   Cycle time: {trend} · Test density: {trend} · Pass rate: {percent}%
   {warnings if any}

──────────────────────────────────────────────────────────
Overall Health: 🟢 Healthy / 🟡 Needs attention / 🔴 Critical
──────────────────────────────────────────────────────────

Recommended actions:
  {actionable items list}
```
