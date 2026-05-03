---
description: Prime agent with codebase understanding
argument-hint: ""
---

# Prime: Load Project Context

## Objective

Build comprehensive understanding of the codebase by analyzing structure, documentation, and key files.

## Process

### 0. 检测 Active Layers（新增）

读取 CLAUDE.md 中的 `## Active Layers` 声明（若存在）：

```markdown
若 Active Layers 声明存在：
  - 产品定义层 ✅ 完成 → 加载 PRD.md + Design-Brief.md（若存在）
  - 产品定义层 🔄 进行中 → 加载 PRD.md，提示"产品定义层未完成"
  - 开发质量层 🔄 进行中（Phase N/M）→ 加载当前 Phase 的 spec/plan
  - 发布层未激活 → 不加载 release 相关文档
  
若 Active Layers 声明不存在：
  - 使用原有逻辑（读取所有标准文档），不改变行为
```

**触发进化层扫描（仅在有 feedback/ 目录时）**:

```
检查 .agents/feedback/ 是否存在：
  存在 → 在 Output Report 输出完成后，后台调用 evolution-engine skill 扫描
         （M4 修正: 完全非阻塞 — prime 主流程不等待扫描结果，扫描独立完成）
         → 若有毕业候选，在 Output Report 末尾轻提示（不超过 1 行）
  不存在 → 跳过，不输出任何信息
```

### 1. Analyze Project Structure

List all tracked files:
!`git ls-files`

Show directory structure:
On Linux, run: `tree -L 3 -I 'node_modules|__pycache__|.git|dist|build'`

### 2. Read Core Documentation

- Read the PRD.md or similar spec file
- Read CLAUDE.md or similar global rules file
- Read README files at project root and major directories
- Read any architecture documentation

**Reference documents — index only (do not read full content):**
- List `.claude/reference/` directory to see available references
- Read `.claude/reference/index.md` if it exists (a short table of contents)
- Full reference content is loaded on-demand during specific Tasks, not during prime

- Read active Spec-Lite files (`.agents/specs/*.spec.md`) if they exist — current phase's single source of truth for feature scope

### 3. Identify Key Files

Based on the structure, identify and read:
- Main entry points (main.py, index.ts, app.py, etc.)
- Core configuration files (pyproject.toml, package.json, tsconfig.json)
- Key model/schema definitions
- Important service or controller files
- Check for active implementation plans (`.agents/plans/*.md`, excluding `archive/`)

### 4. Understand Current State

Check recent activity:
!`git log -10 --oneline`

Check current branch and status:
!`git status`

## Output Report

Provide a concise summary:

### Project Overview
- Purpose and application type
- Primary technologies and frameworks
- Current version/status

### Architecture
- Overall structure and organization
- Key architectural patterns
- Important directories and their responsibilities

### Tech Stack
- Languages and versions
- Frameworks and major libraries
- Build tools and package managers
- Testing frameworks

### Core Principles
- Code style and conventions
- Documentation standards
- Testing approach

### Available Automation Skills
- `api-contract-first`: API contract consistency validation (auto-triggers when API is involved)
- `e2e-test`: End-to-end business feature testing — includes merged agent-browser capabilities and Playwright MCP interactive mode (v1.4.0+). For web projects, uses Playwright scripts (CI regression), Playwright MCP (trace-level QA records), or agent-browser (quick exploration). For other types, follows test-strategies/{type}.md. Use after /execute before /code-review.
- `backend-test`: Backend test execution — unit/integration/DB tests with per-language templates (auto-triggers for backend-only work)
- `frontend-design`: Frontend UI design intelligence (auto-loads when frontend UI is involved)

### Key Commands
- `/diagnose` — Health check: CLAUDE.md, artifacts, gates, security tools, skills, metrics
- `/onboard` — Interactive setup guide with L0-L3 progressive path selection
- `/plan-feature` → `/execute` → `/code-review` → `/verify-phase` → `/close-phase` → `/commit`

### Current State
- Active branch
- Recent changes or development focus
- Any notable observations or issues

**Use bullet points and clear headings for quick scanning.**

### Active Layers 状态

```
[产品定义层] {状态图标} — {PRD/设计图完成情况}
[开发质量层] {状态图标} — {Phase N/M 或 N个Phase已完成}
[发布层]     {状态图标} — {未激活/已完成}
[进化层]     ✅ 后台运行 — {N}条反馈已记录{若有候选: · 💡{N}条进化建议待查看}
```

### 当前层级的可用命令

```
{根据 Active Layers 只展示当前相关的命令，其他层的命令不展示}

示例（开发质量层进行中）:
  /plan-feature  [功能规划]
  /execute       [实施]  
  /code-review   [代码审查]
  /verify-phase  [核验]
  /close-phase   [归档]
  /commit        [提交]
  /hotfix        [紧急修复]
```
