---
description: Prime agent with codebase understanding
argument-hint: ""
---

# Prime: Load Project Context

## Objective

Build comprehensive understanding of the codebase by analyzing structure, documentation, and key files.

## Process

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

## 输出报告

提供简洁摘要：

### 项目概述
- 用途和应用类型
- 主要技术和框架
- 当前版本/状态

### 架构
- 整体结构和组织
- 关键架构模式
- 重要目录及其职责

### 技术栈
- 语言和版本
- 框架和主要库
- 构建工具和包管理器
- 测试框架

### 核心原则
- 代码风格和约定
- 文档标准
- 测试方法

### 可用自动化 Skill
- `api-contract-first`：API 合约一致性核验（涉及 API 时自动触发）
- `e2e-test`：业务功能端到端测试（有前端时自动执行）
- `ui-ux-pro-max`：UI/UX 设计智能（涉及前端 UI 时自动加载）
- `test-driven-development`：TDD 强制门禁（Phase 2 每个 Task 自动加载）
- `systematic-debugging`：系统化调试（bug/测试失败时加载）
- `requesting-code-review`：独立 Code Review（Phase 3 建议执行）

### 当前状态
- 活跃分支
- 近期变更或开发重点
- 任何值得注意的观察或问题

**使用要点和清晰标题，便于快速浏览。**
