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
- `e2e-test`: End-to-end business feature testing (auto-executes when frontend is present)
- `frontend-design`: Frontend UI design intelligence (auto-loads when frontend UI is involved)
- `test-driven-development`: TDD enforcement gate (auto-loads for every Task in Phase 2)
- `systematic-debugging`: Systematic debugging (loads on bug/test failure)
- `requesting-code-review`: Independent Code Review (recommended in Phase 3)

### Current State
- Active branch
- Recent changes or development focus
- Any notable observations or issues

**Use bullet points and clear headings for quick scanning.**
