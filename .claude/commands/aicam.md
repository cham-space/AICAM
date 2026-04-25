---
description: Interactive workflow guide — navigate AICAM phases, commands, skills, and gates
argument-hint: "[topic: phases|commands|skills|gates|levels|command-name]"
---

# AICAM: Interactive Workflow Guide

## Usage

Call `/aicam` without arguments for the interactive menu, or pass a topic or command name directly:
- `/aicam` — interactive menu
- `/aicam phases` — show phase overview
- `/aicam commands` — show command catalog
- `/aicam skills` — show skill catalog
- `/aicam gates` — show gate catalog
- `/aicam levels` — show progressive enablement paths (L0-L3)
- `/aicam /execute` — show details for a specific command

---

## Entry (no arguments)

Present this menu:

```
AICAM Workflow Guide — How can I help?

  1. Workflow Overview — What Phases 0-5 do, flow diagram, typical scenarios
  2. Command Reference — 16 commands, when to trigger, one-line purpose
  3. Navigate by Phase — "I'm at Phase 2, what command comes next?"
  4. Skill Reference — Auto-trigger conditions, applicable scenarios
  5. Gate Reference — Blocking conditions, exemption rules
  6. Enablement Paths — L0/L1/L2/L3: which to choose, what each needs

  Or type a command name for details (e.g., /execute, /hotfix, /aicam)

  Enter option (1-6) or command name:
```

---

## Option 1: Workflow Overview

Output:

```
═══════════════════════════════════════════════════════════════
                  AICAM 5-Phase Workflow Overview
═══════════════════════════════════════════════════════════════

Phase 0 — Project Init (one-time)
  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
  │ /discover │ → │/create-prd│→ │/ref-research│→ │/create-rules│→ │/init-project│→ │  /prime  │
  │ Reqs+Arch │   │ Gen PRD   │   │ Tech Rsch │   │ Gen Rules  │   │Env Setup  │   │Reload Ctx│
  └──────────┘   └──────────┘   └──────────┘   └──────────┘   └──────────┘   └──────────┘
  Existing projects can skip Phase 0, start directly from Phase 1.

Phase 1 — Feature Planning
  ┌─────────────────────────────────────────┐
  │  /plan-feature → outputs plan.md + spec.md │
  │  No code written — only plan + Spec-Lite   │
  └─────────────────────────────────────────┘

Phase 2 — Feature Implementation
  ┌────────┐   ┌──────────┐   ┌──────────────┐   ┌──────────┐   ┌───────────┐
  │TDD First│ → │ /execute  │ → │api-contract   │ → │Biz Tests │ → │Smoke Test │
  │Red→Green│  │Per-Task   │   │API Contract   │   │ E2E/API  │   │Runtime Ver│
  └────────┘   └──────────┘   └──────────────┘   └──────────┘   └───────────┘
  Emergency fixes: use /hotfix to skip Phase 1 and jump directly here.

Phase 3 — Verification
  ┌─────────────┐   ┌──────────────┐
  │ /code-review │ → │/verify-phase  │
  │Required·NewSess│ │Evidence-Driven│
  └─────────────┘   └──────────────┘

Phase 4 — Archive
  ┌──────────────┐
  │ /close-phase  │
  │Distill+Archive│
  └──────────────┘

Phase 5 — Commit
  ┌─────────┐
  │ /commit  │
  │ Atomic   │
  └─────────┘

═══════════════════════════════════════════════════════════════

Quick jump by scenario:
  New project      → /onboard (interactive setup) or /aicam levels (choose path)
  New feature      → /plan-feature → /execute → /code-review → /verify-phase → /close-phase → /commit
  Emergency bugfix → /hotfix
  Health check     → /diagnose
  Command details  → /aicam <command-name>

Type b to return to main menu, q to quit.
```

---

## Option 2: Command Reference

List all 16 commands grouped by Phase:

```
═══════════════════════════════════════════════════════════════
                 Command Reference (16 commands)
═══════════════════════════════════════════════════════════════

Phase 0 — Project Init (6 commands)
  /discover      Requirements gathering + architecture research; Path A (clear) / Path B (needs clarification)
  /create-prd    Generate PRD.md from requirements
  /ref-research  Research frontend components + API best practices → reference docs
  /create-rules  Analyze codebase → generate CLAUDE.md project rules
  /init-project  Init local environment (install deps, start DB, run migrations)
  /prime         Restart session with full project context loaded

Phase 1 — Feature Planning (1 command)
  /plan-feature  Codebase research → architecture thinking → plan + Spec-Lite + AC list

Phase 2 — Implementation (1 command + 4 Skills)
  /execute       Execute plan task by task (with TDD + Smoke Test mandatory gates)

Phase 3 — Verification (2 commands)
  /code-review   Implementation-independent code review; MUST run in **new session**
  /verify-phase  Evidence-driven audit: compare plan vs actual implementation + validation commands

Phase 4 — Archive (1 command)
  /close-phase   Distill knowledge into CLAUDE.md + move detailed artifacts into archive/

Phase 5 — Commit (1 command)
  /commit        Security scan + conventional commit message + atomic commit

Special Channel (1 command)
  /hotfix        Emergency bug fix: skip Phase 1, TDD + Smoke + Review gates still apply

Tool Commands (3 commands)
  /aicam         This guide — interactive workflow navigation
  /diagnose      Workflow health check — one-click system integrity audit
  /onboard       Interactive setup — step-by-step AICAM configuration for new developers

═══════════════════════════════════════════════════════════════

Type a command name for details (e.g., /execute), b to return, q to quit.
```

---

## Option 3: Navigate by Phase

Ask user which Phase they are in:

```
Which phase are you in?

  0 — Project Init (new project / just joined)
  1 — Feature Planning (existing project, starting new feature)
  2 — Implementation (actively writing code)
  3 — Verification (code done, ready for audit)
  4 — Archive (verification passed, ready to wrap up)
  5 — Commit (ready to commit)
  H — Emergency Fix (production bug)

Enter Phase number (0/1/2/3/4/5/H):
```

Then based on user selection, show guidance. Example for Phase 2:

```
Phase 2 — Feature Implementation

  You should have:
  □ Completed /plan-feature → plan.md + spec.md (pre-condition)
  □ User confirmed the plan

  Execution order:
  1. TDD (auto) — before each business logic task, write failing test → confirm red
  2. /execute [plan-file-path] — implement task by task, verify after each
  3. api-contract-first (auto-trigger) — if API involved, check frontend-backend field consistency
  4. e2e-test / backend-test — business workflow tests
  5. Smoke Test (auto) — start app + execute checklist items

  ⚠️ Gate rules:
  - Unit Tests + Business Workflow Tests: either fails → blocks Phase completion
  - Skipping TDD red phase → Iron Law violation: delete implementation code, start over
  - Destructive ops (DROP/TRUNCATE/rm -rf) → must get user confirmation

  Next step → Phase 3: /code-review (MUST be in **new session**)

  Want /execute details? Just type the command name.
```

---

## Option 4: Skill Reference

```
═══════════════════════════════════════════════════════════════
                  Skill Reference (4 + 4)
═══════════════════════════════════════════════════════════════

Workspace Skills (.claude/skills/, in-project)

  api-contract-first  API Contract-First
    Trigger: editing API controller/service/DTO dirs, or mentions "API contract", "OpenAPI"
    Role: backend defines first → generate OpenAPI → frontend mirrors → verify field naming
    Common trap: @JsonNaming only affects body serialization, NOT URL query params

  frontend-design     Frontend Design
    Trigger: touching UI components/pages/styles/colors/layout/animations
    Role: production-grade frontend, avoiding generic AI aesthetics

  e2e-test            E2E Testing (includes browser automation)
    Trigger: web type with frontend detected → auto-suggested
    Role: Playwright (web) / agent-browser (fallback) / test-strategies (other types)

  backend-test        Backend Testing
    Trigger: creating backend test files, API integration tests, DB test fixtures
    Role: REST API integration tests + database validation + mock strategies

Superpowers Skills (discipline checks, auto-loaded)

  test-driven-development         TDD red-green-refactor cycle
  systematic-debugging            No fix proposals before root cause identified
  verification-before-completion  Must re-verify before claiming completion
  requesting-code-review          Code review workflow

═══════════════════════════════════════════════════════════════

Type b to return, q to quit.
```

---

## Option 5: Gate Reference

```
═══════════════════════════════════════════════════════════════
                    Gate System (6 gates)
═══════════════════════════════════════════════════════════════

  tdd.gate.md              TDD Red-Green-Refactor Gate
    Blocks: implementation before test / non-exempt task missing Red-Green record
    Exempt: config files, migrations, pure styles, annotation updates (requires user confirm)

  smoke.gate.md            Smoke Test Runtime Verification
    Blocks: plan missing ## Smoke Test Checklist / any ❌ or ⏸️ entries
    Requires: start app → no crash → execute checklist items → all ✅

  security.gate.md         Security Scan Gate
    Blocks: all scan tools unavailable with no resolution / secrets found / SAST errors / high CVE
    Three layers: gitleaks(Secrets) + semgrep(SAST) + dependency audit(SCA)
    Docker fallback: available when native tools are missing

  contract.gate.md         API Contract Consistency
    Blocks: frontend param names mismatch backend / enum value inconsistency / oasdiff breaking change
    Covers: Java Spring / Python / Go / Node.js / Rust

  destructive-op.gate.md   Destructive Operation Detection
    Blocks: DROP / TRUNCATE / unconditional DELETE / rm -rf / git reset --hard
    CRITICAL: must STOP and wait for explicit user "confirm"
    HIGH/MEDIUM: warn + confirm

  coverage.gate.md         Test Coverage
    Blocks: below per-type threshold (rest-api≥80%, web≥75%, cli≥72%...)
    AC with no coverage → ⚠️ warning, does not block

═══════════════════════════════════════════════════════════════

Type b to return, q to quit.
```

---

## Option 6: Progressive Enablement Paths

```
═══════════════════════════════════════════════════════════════
                Progressive Enablement Paths (L0-L3)
═══════════════════════════════════════════════════════════════

L0 — Zero Config (< 5 min)
  For: emergency fixes, single-file changes
  Commands: /hotfix, /aicam
  Dependencies: none
  "Five minutes, no config needed."

L1 — Minimal (< 15 min)
  For: MVP, prototype, < 1 week small projects
  Commands: /plan-feature → /execute → /commit
  Dependencies: CLAUDE.md (default template rules)
  Skip: Phase 0-C, 0-D

L2 — Standard (< 1 hr) ← recommended for most projects
  For: production projects, ongoing iteration
  Commands: full 5-Phase + 4 Skills + 6 Gates
  Dependencies: complete CLAUDE.md + PRD.md + reference docs

L3 — Advanced (< 2 hr)
  For: team collaboration, production environments
  Commands: L2 + CI/CD + security scanning + MCP
  Dependencies: GitHub Actions + gitleaks + semgrep + serena + typescript-lsp

═══════════════════════════════════════════════════════════════

First time? Run /onboard for interactive guided setup.
Not sure which to choose? Start with L1, upgrade anytime.
Just exploring the framework? Choose L0 then run /aicam phases.

Type b to return, q to quit.
```

---

## Direct Command Lookup

When user passes a command name (e.g., `/aicam /execute`), look up and display its details.

Read the corresponding `.claude/commands/{name}.md` file header and extract:

- `description` from frontmatter
- `argument-hint` from frontmatter
- Phase association (from WORKFLOW.md)
- Pre-conditions (what must be done before using it)
- Next step (what command typically follows)
- Key gates applied during/after this command

Output format:

```
═══════════════════════════════════════════════════════════════
  Command: /{name}
═══════════════════════════════════════════════════════════════

  Description: {description}
  Arguments: {argument-hint}
  Phase: Phase {N} — {phase name}
  Pre-conditions: {pre-conditions}
  Trigger: {manual / auto / both}
  Next step: {next command in workflow}

  Related Skills: {skills if any}
  Related Gates: {gates if any}
  Artifacts: {artifacts}

  Typical usage: {example}

═══════════════════════════════════════════════════════════════

Type b to return to main menu, q to quit.
```

### Command Reference Table (for lookups)

| Command | Phase | Trigger | Pre-condition | Next Step |
|---------|-------|---------|---------------|-----------|
| /discover | 0-A | Manual | None | /create-prd |
| /create-prd | 0-B | Manual | /discover consensus | /ref-research |
| /ref-research | 0-C | Manual | PRD.md exists | /create-rules |
| /create-rules | 0-D | Manual | reference docs ready | /init-project |
| /init-project | 0-E | Manual | CLAUDE.md exists | /prime |
| /prime | 0-F | Manual | Phase 0 done | /plan-feature |
| /plan-feature | 1 | Manual | Context clean | /execute |
| /execute | 2 | Manual | plan + spec confirmed | /code-review |
| /code-review | 3-A | Manual (mandatory) | /execute done | /verify-phase |
| /verify-phase | 3-B | Manual | /code-review (recommended) | /close-phase |
| /close-phase | 4 | Manual | verification PASSED | /commit |
| /commit | 5 | Manual | Phase archived | next /plan-feature |
| /hotfix | — | Manual | Bug scope ≤3 files | /code-review |
| /diagnose | — | Manual | None | (informational) |
| /onboard | — | Manual | None | (setup complete) |
| /aicam | — | Manual | None | (informational) |

---

## Protocol

- **Output language**: All content in English.
- **Nesting**: After showing detail for any topic, always offer "Type b to return to main menu, q to quit."
- **Quick exit**: User can type `q` at any prompt to exit the guide.
- **Error handling**: If user enters an unrecognized option or command name, show: `"Unrecognized option or command. Type ? to return to the main menu, q to quit."` and wait for input.
