# AICAM — AI-Assisted Development Workflow

> **v2.0.0** | 2026-05-03 | [cham](mailto:vccham@gmail.com)

**Cross-role AI Collaboration Framework** for [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) — serving PMs, designers, developers, and full-stack talents, covering the complete lifecycle from product definition to code delivery to release.

Every feature goes from idea to commit through a structured pipeline: **Discover → Plan → Execute (TDD) → Verify → Archive**. Each phase has automated gates — no skipped tests, no unverified contracts, no drifting context.

## Key Features

| Feature | Description |
|---------|-------------|
| **5-Phase Lifecycle** | Phase 0 (one-time init) → Phase 1 (plan) → Phase 2 (TDD + implement) → Phase 3 (verify) → Phase 4 (archive) → Phase 5 (commit) |
| **TDD Iron Rule** | Tests must fail before implementation; violations require code deletion and restart |
| **6 Quality Gates** | TDD, Smoke Test, Security (gitleaks + semgrep + SCA), API Contract, Destructive Op, Coverage — all automated |
| **Eco-Adaptive CI** | Auto-detects npm/Python/Go/Rust ecosystems; per-ecosystem build, test, and smoke commands |
| **Progressive Disclosure** | Context loaded on demand; archival compression keeps CLAUDE.md lean (< 150 lines) |
| **L0-L3 Enablement** | From zero-config `/hotfix` to full CI/CD + MCP — pick your level, upgrade anytime |
| **Four-Layer Architecture** | Product Definition + Development Quality + Release + Evolution, role-based activation |
| **Evolution System** | Hooks auto-capture feedback signals, frequency-driven rule upgrades, smarter with use |
| **Design-to-Code Pipeline** | Figma MCP-driven prototyping, design specs as highest-priority implementation reference |

## Four-Layer Architecture

```
┌──────────────────────────────────────────────────────────┐
│ Product Definition  PM/Design: discover → create-prd → design │
├──────────────────────────────────────────────────────────┤
│ Development Quality  Dev: plan → execute → verify → close    │
├──────────────────────────────────────────────────────────┤
│ Release              DevOps/Full-stack: release-builder       │
├──────────────────────────────────────────────────────────┤
│ Evolution            All (background): hooks → feedback → rules│
└──────────────────────────────────────────────────────────┘
```

## Quick Start

**Choose your role:**

| Role | Entry Point |
|------|-------------|
| PM / Designer | Run `/onboard`, select your role, AI guides subsequent workflow |
| Developer | `cp -r .claude/ .githooks/ .github/ .serena/ <your-project>/` → `/onboard` |
| Full-stack Independent | `/onboard` → select "Full-stack Independent", walk the full pipeline |

```bash
# 1. Core workflow (required)
cp -r .claude/ /path/to/your/project/

# 2. CI gates (only for projects using GitHub Actions)
cp -r .github/workflows/ /path/to/your/project/.github/

# 3. Git hooks + security config (optional, enable local gates)
cp -r .githooks/ .commitlintrc.yaml .gitleaks.toml /path/to/your/project/

# 4. Activate hooks
cd /path/to/your/project
git config core.hooksPath .githooks

# 5. Edit .githooks/config to enable/disable checks per project

# In Claude Code, start interactive setup:
/onboard
```

Or jump directly to `/discover [your idea]` if you know what you're building.

## Documentation

| Document | Language | Content |
|----------|----------|---------|
| [README.en.md](README.en.md) | English | Full workflow documentation — all 15 sections |
| [README.zh.md](README.zh.md) | 中文 | 完整工作流文档 — 全部 15 章节 |
| [WORKFLOW.md](.claude/WORKFLOW.md) | 中文 | Canonical workflow reference (source of truth) |

## System at a Glance

```
.claude/
├── commands/    15 slash commands    (/discover, /execute, /hotfix, /diagnose...)
├── skills/      9 domain skills      (frontend-design, api-contract-first, e2e-test+Playwright MCP, backend-test, design-brief-builder, design-maker, feedback-writer, evolution-engine, release-builder)
├── gates/       6 quality gates      (tdd, smoke, security, contract, destructive-op, coverage)
├── reference/   3+ docs + 6 test     (plan-template, spec-lite-template, test-strategies/*)
│                strategies
└── WORKFLOW.md  This workflow doc

.agents/         AI runtime artifacts (plans, specs, reviews, reports — auto-managed)
archive/         Historical records   (auto-archived by /close-phase)
```

## Version History

| Version | Date | Highlights |
|---------|------|------------|
| v2.0.0 | 2026-05-03 | 4-layer architecture, evolution system, Pencil/Figma MCP design pipeline, release-builder, 9 skills, 5 MCPs |
| v1.4.0 | 2026-05-02 | Playwright MCP interactive mode: e2e-test 3-path automation, MCP Trace archival, TDD Gate MCP verification |
| v1.3.3 | 2026-04-25 | Mandatory 3-layer security scan (gitleaks + semgrep + SCA) on commit |
| v1.3.2 | 2026-04-25 | Bug fixes: Python smoke fallback, /diagnose commit-msg hook check |
| v1.3.1 | 2026-04-25 | Eco-adaptive CI, oasdiff breaking change detection, anti-truncation gates |
| v1.3.0 | 2026-04-25 | Gate adapter layer, security trilogy, /diagnose + /onboard, M1-M5 metrics |
| v1.2.1 | 2026-04-24 | /hotfix command, Smoke Test gate, MCP setup guide |
| v1.0.0 | 2026-04-19 | Initial release: 5-Phase workflow + 12 commands + 5 skills |

See [README.en.md](README.en.md) or [README.zh.md](README.zh.md) for the full changelog.
