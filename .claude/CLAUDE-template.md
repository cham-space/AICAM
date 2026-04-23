# CLAUDE.md Template

A flexible template for creating global rules. Adapt sections based on your project type.

---

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

<!-- What is this project? One paragraph description -->

{Project description and purpose}

---

## Tech Stack

<!-- List FRAMEWORKS only. Do not enumerate individual libraries/crates -- those live in Cargo.toml / package.json. -->

| Technology | Purpose |
|------------|---------|
| {framework} | {why it's used} |

---

## Commands

<!-- Common commands for this project. Adjust based on your package manager and setup -->

```bash
# Development
{dev-command}

# Build
{build-command}

# Test
{test-command}

# Lint
{lint-command}
```

---

## Project Structure

<!-- Summarize in ≤15 lines. Do not list every file. -->

```
{root}/
├── {dir}/     # {description}
├── {dir}/     # {description}
└── {dir}/     # {description}
```

---

## Architecture

<!-- 1-2 paragraphs max. Link to design doc for full details. -->

{High-level approach: layered, event-driven, etc. Key data flow.}

For detailed component specs, see `docs/specs/*-design.md`.

---

## Code Patterns

<!-- 1-2 lines per convention. Do not write code examples here. -->

### Naming
- {convention}

### Error Handling
- {approach summary}

### Streaming / Real-Time
- {approach summary}

### Simplicity First（适用于实施阶段 Phase 2）
- Write minimum code to meet the current Spec-Lite AC — no speculative features
- No abstractions unless reused in ≥2 places within this Phase
- No error handling for scenarios the Spec-Lite doesn't define
- If the task can be done in 50 lines, don't write 200

### Surgical Changes
- Touch only what the request requires — do not "improve" adjacent code, comments, or formatting
- Match existing style even if you would do it differently; do not refactor things that aren't broken
- If you notice unrelated dead code, mention it — never delete it silently
- Remove imports/variables/functions that YOUR changes made unused; leave pre-existing dead code alone
- Every changed line must trace directly to the user's request

> For detailed patterns, read `.claude/reference/components.md` (frontend) or `.claude/reference/api.md` (backend/API).

---

## Testing

<!-- 3-4 lines max. Do not include test pyramids, mock examples, or detailed strategies. -->

- **Unit tests**: `{unit-test-command}`
- **Business workflow tests**: `{e2e-or-integration-command}`
- **Single file / targeted**: `{targeted-test-command}`
- **Pattern**: {1-sentence approach}

> For detailed testing strategy, read `.claude/reference/test-strategies/{type}.md`.

---

## Key Files

<!-- ≤10 entries. Only files that define the project's shape. -->

| File | Purpose |
|------|---------|
| `{path}` | {1-line description} |

---

## On-Demand Context

<!-- Reference docs for deeper context. These are NEVER loaded into the conversation automatically -- read them only when the task specifically requires. -->

| Topic | File | When to Read |
|-------|------|-------------|
| Frontend Component Guidelines | `.claude/reference/components.md` | When building or modifying React components |
| API Endpoint Guidelines | `.claude/reference/api.md` | When defining or calling Tauri IPC commands / external APIs |

**Hard isolation rule**: Do NOT read these reference files unless the current task explicitly requires them. They exist for on-demand lookup only.

**Skill 激活规则**（强制执行，不依赖自动匹配）：
- 构建或修改前端组件/页面 → 明确加载 `frontend-design`
- 涉及 API 定义或前后端字段联调 → 明确加载 `api-contract-first`
- 执行业务功能测试（E2E）→ 明确加载 `e2e-test`

---

## Safety Rules

<!-- Cross-project guardrails. Remove or adapt any section that doesn't apply -->

### Secrets & Credentials
- Never commit files that may contain secrets: `.env*`, `*.key`, `*.pem`, `*.secret`, credential or token files
- When in doubt, check `.gitignore` and ask the user before staging unfamiliar files

### Git Operations
- Confirm with the user before `git push`
- Avoid destructive commands (`git reset --hard`, `git push --force`, `git checkout .`, `git clean -fd`) unless explicitly asked
- If a safer alternative exists (e.g., `git revert` instead of `git reset --hard`), prefer it and explain why

### Data & Schema Changes
- Before running migrations or bulk data operations, summarize what will change and wait for confirmation
- Flag any operation that could cause data loss or is hard to reverse

### Dependency Changes
- Before adding, removing, or upgrading packages, briefly explain the reason and note any breaking-change risks
- For major version bumps, call out migration steps if known

### Override
- Any rule above can be skipped if the user explicitly requests it — but the risk should always be stated first

---

## Notes

<!-- Any special instructions, constraints, or gotchas -->

- {note}