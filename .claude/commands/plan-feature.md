---
description: "Create comprehensive feature plan with deep codebase analysis and research"
argument-hint: "[feature description]"
---

# Plan a new task

## Feature: $ARGUMENTS

## Mission

Transform a feature request into a **comprehensive implementation plan** through systematic codebase analysis, external research, and strategic planning.

**Core Principle**: We do NOT write code in this phase. Our goal is to create a context-rich implementation plan that enables one-pass implementation success for ai agents.

**Key Philosophy**: Context is King. The plan must contain ALL information needed for implementation - patterns, mandatory reading, documentation, validation commands - so the execution agent succeeds on the first attempt.

**Progressive Disclosure Rule**: Keep planning artifacts minimal and executable. Besides the plan, generate only a one-page `Spec-Lite` (bounded scope, contract mapping, test gates) to avoid context bloat.

## Planning Process

### Stage 0: Context Hygiene Check (Auto)

Before planning, verify workspace context is clean and budget-efficient:

**1. Stale Phase Artifacts**

Scan `.agents/plans/` for completed plans and project root for `*REPORT*.md` / `*VERIFICATION*.md` files that have no corresponding entry in CLAUDE.md's "Migration Journal" section.

- If found → **WARN**: `"⚠ Detected N unarchived Phase artifact(s). Run /close-phase before planning to keep context clean and free up budget."`
- List the files and their sizes

**2. Duplicate References**

Check if both `.agents/reference/` and `.claude/reference/` exist with overlapping filenames.

- If found → **WARN**: `"⚠ Duplicate reference files detected between .agents/ and .claude/. Consider deduplicating."`

**3. Context Budget Estimate**

Count total `.md` content size (excluding `.git/`, `node_modules/`, `target/`, `archive/`):

- If > 300KB → **WARN**: `"⚠ Workspace markdown content is {X}KB. Historical docs may consume planning context budget. Run /close-phase to archive completed phases."`
- If > 500KB → **CRITICAL WARNING**: `"🚨 CRITICAL: Workspace markdown is {X}KB — exceeds safe planning threshold. Planning quality will degrade significantly. Run /close-phase NOW before continuing."`

> **This phase only warns. It does not auto-archive.**
> Archiving is a destructive action handled by the dedicated `/close-phase` command.

If all checks pass, output: `"✓ Context hygiene check passed. Proceeding to planning."`

---

### Stage 1: Feature Understanding

**First, read the project scope:**
1. Read `PRD.md` (if exists) to understand overall project scope, MVP goals, and existing architecture decisions
2. When feature involves frontend → also read `.claude/reference/components.md`
3. When feature involves API → also read `.claude/reference/api.md`

**Deep Feature Analysis:**

- Extract the core problem being solved
- Identify user value and business impact
- Determine feature type: New Capability/Enhancement/Refactor/Bug Fix
- Assess complexity: Low/Medium/High
- Map affected systems and components

**Create User Story Format Or Refine If Story Was Provided By The User:**

```
As a <type of user>
I want to <action/goal>
So that <benefit/value>
```

### Stage 2: Codebase Intelligence Gathering

**Use specialized agents and parallel analysis:**

When dispatching 2+ research sub-agents, load `dispatching-parallel-agents`
for prompt construction guidance. Each agent must receive: specific scope,
clear goal, constraints, and expected output format.

**Fault tolerance rules for parallel sub-agents:**
- **Timeout**: Each sub-agent has a 5-minute timeout. If exceeded, mark the research area as `⚠ UNKNOWN — manual investigation needed`, do not block the plan.
- **Empty result**: If a sub-agent returns no findings, treat as neutral (not an error). Mark the research area as `∅ No findings`.
- **Offline degradation**: If external research (Stage 3) fails due to network issues, skip external references and proceed with codebase-only analysis. Note the degradation in the plan's `## NOTES` section.
- **Partial results**: A failed or timed-out sub-agent does not block the overall plan. Consolidate available results and flag missing areas for manual follow-up.

**1. Project Structure Analysis**

- Detect primary language(s), frameworks, and runtime versions
- Map directory structure and architectural patterns
- Identify service/component boundaries and integration points
- Locate configuration files (pyproject.toml, package.json, etc.)
- Find environment setup and build processes

**Project Type Detection (required)**

Scan the following feature files to determine the project type, and write the result to the plan file's `## Project Type` section:

| Project Type | Detection Signal | Strategy File |
|---------|---------|---------|
| `tauri` | `src-tauri/Cargo.toml` exists | `.claude/reference/test-strategies/tauri.md` |
| `web` | `package.json` without `src-tauri/`, with frontend framework deps | `.claude/reference/test-strategies/web.md` |
| `rest-api` | No frontend directory, with HTTP framework deps | `.claude/reference/test-strategies/rest-api.md` |
| `cli` | `Cargo.toml`/`package.json` contains `clap`/`commander`/`click` | `.claude/reference/test-strategies/cli.md` |
| `worker` | No HTTP listener, with message queue/cron job deps | `.claude/reference/test-strategies/worker.md` |
| `mobile` | `android/`/`ios/` directories, or `pubspec.yaml` | `.claude/reference/test-strategies/mobile.md` |

After detection, **immediately read the corresponding strategy file** and use its Smoke Test Checklist and business workflow validation as the default test strategy in the plan.

**2. Pattern Recognition** (Use specialized subagents when beneficial)

- Search for similar implementations in codebase
- Identify coding conventions:
  - Naming patterns (CamelCase, snake_case, kebab-case)
  - File organization and module structure
  - Error handling approaches
  - Logging patterns and standards
- Extract common patterns for the feature's domain
- Document anti-patterns to avoid
- Check CLAUDE.md for project-specific rules and conventions

**3. Dependency Analysis**

- Catalog external libraries relevant to feature
- Understand how libraries are integrated (check imports, configs)
- Find relevant documentation in docs/, ai_docs/, .agents/reference or ai-wiki if available
- Note library versions and compatibility requirements

**4. Testing Patterns**

- Identify test framework and structure (pytest, jest, etc.)
- Find similar test examples for reference
- Understand test organization (unit vs integration)
- Understand business workflow test style (UI E2E or API workflow test)
- Note coverage requirements and testing standards

**5. Integration Points**

- Identify existing files that need updates
- Determine new files that need creation and their locations
- Map router/API registration patterns
- Understand database/model patterns if applicable
- Identify authentication/authorization patterns if relevant

**6. API Contract/Naming Mapping (When API is touched)**

- If feature affects API controllers, service layers, data transfer objects, or API endpoints, mark `api-contract-first` as mandatory in the plan
- Build a field mapping table: frontend param/key <-> backend parameter binding alias / DTO field
- Explicitly call out naming convention boundaries (snake_case vs camelCase) and conversion rules

**Clarify Ambiguities:**

- If requirements are unclear at this point, ask the user to clarify before you continue
- Get specific implementation preferences (libraries, approaches, patterns)
- Resolve architectural decisions before proceeding

### Stage 3: External Research & Documentation

**Use specialized subagents when beneficial for external research:**

**Documentation Gathering:**

- Research latest library versions and best practices
- Find official documentation with specific section anchors
- Locate implementation examples and tutorials
- Identify common gotchas and known issues
- Check for breaking changes and migration guides

**Technology Trends:**

- Research current best practices for the technology stack
- Find relevant blog posts, guides, or case studies
- Identify performance optimization patterns
- Document security considerations

### Stage 4: Deep Strategic Thinking

**Think Harder About:**

- How does this feature fit into the existing architecture?
- What are the critical dependencies and order of operations?
- What could go wrong? (Edge cases, race conditions, errors)
- How will this be tested comprehensively?
- What performance implications exist?
- Are there security considerations?
- How maintainable is this approach?

**Design Decisions:**

- Choose between alternative approaches with clear rationale
- Design for extensibility and future modifications
- Plan for backward compatibility if needed
- Consider scalability implications

### Stage 5: Plan Structure Generation

**Create comprehensive plan using the following template:**

Read `.claude/reference/plan-template.md` and use it as the structure for the output plan. Fill every section — do not omit any section from the template.

**Also read `.claude/reference/spec-lite-template.md` for the Spec-Lite format (MANDATORY output per WORKFLOW.md 1-C).**

**Note:** When structuring tasks, note that execution will enforce TDD (WORKFLOW.md Phase 2-A). Where applicable, structure task order to allow test-first implementation.

## Output Format

**Plan header must include:**
> Execution: Use `/execute [this-file]` from this project. Do NOT use
> superpowers:executing-plans or superpowers:subagent-driven-development
> (they require git worktree isolation which this project does not use).

**Filename**: `.agents/plans/{kebab-case-descriptive-name}.md`

- Replace `{kebab-case-descriptive-name}` with short, descriptive feature name
- Examples: `add-user-authentication.md`, `implement-search-api.md`, `refactor-database-layer.md`

**Directory**: Create `.agents/plans/` if it doesn't exist

## Success Metrics

**One-Pass Implementation**: Execution agent can complete feature without additional research or clarification

**Validation Complete**: Every task has at least one working validation command

**Context Rich**: The Plan passes "No Prior Knowledge Test" - someone unfamiliar with codebase can implement using only Plan content

**Confidence Score**: #/10 that execution will succeed on first attempt

## Report

After creating the Plan, provide:

- Summary of feature and approach
- Full path to created Plan file
- Complexity assessment
- Key implementation risks or considerations
- Estimated confidence score for one-pass success