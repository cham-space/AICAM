---
description: "Phase 0-A: Requirements gathering and architecture research"
argument-hint: "[project idea or description]"
---

# Discover: Requirements Gathering & Architecture Research

## Feature: $ARGUMENTS

## Mission

Transform a project idea into a well-understood, consensus-backed requirements specification through structured dialogue, sub-agent research, and collaborative design exploration.

**Core Principle**: Never start building before both parties agree on what to build.

---

## Entry Gate: Decision Point

Before proceeding, ask the user:

> "Is your requirement already clear enough to proceed directly to research and PRD creation, or would you like me to walk you through a structured brainstorming process to refine the idea, explore alternatives, and validate the architecture?"

Present two paths:

- **Path A — Requirements Clear**: Skip brainstorming. Proceed directly to sub-agent research, then enter Phase 0-B (`/create-prd`).
- **Path B — Needs Structuring**: Enter full brainstorming flow. Refine the idea through one-question-at-a-time dialogue, propose alternatives, design sections, and get approval before proceeding.

**Do not proceed until the user selects a path.**

---

## Path A: Streamlined (Requirements Clear)

### Step 1: Sub-Agent Research

When dispatching 2+ research sub-agents, load `dispatching-parallel-agents`
for prompt construction guidance. Each agent must receive: specific scope,
clear goal, constraints, and expected output format.

Launch parallel sub-agents for research:

1. **Architecture Research Agent**: Research best practices for the target application type, recommended tech stack, common pitfalls, and reference implementations.
2. **Domain Research Agent**: Research the specific domain (e.g., offline-first apps, multi-device sync, note-taking UX) for established patterns and proven solutions.

### Step 2: Research Summary & Validation

Present findings to the user:

- Recommended architecture and tech stack with rationale
- Best practices applicable to this project
- Common pitfalls to avoid
- Reference implementations or similar projects

Ask the user to confirm or raise concerns.

### Step 3: Gap Detection

Even if requirements appear clear, scan for logical gaps using this framework:

- **Data model**: Primary key strategy, data consistency edge cases, schema completeness
- **Error handling**: Error reporting strategy, retry logic, failure recovery paths
- **Performance**: Expected load, latency constraints, caching strategy, pagination
- **Security**: Authentication approach, authorization boundaries, sensitive data handling
- **Concurrency**: Conflict resolution (if multi-user or multi-device), race conditions
- **Offline/availability**: Offline requirements (if applicable), graceful degradation

If gaps are found, ask targeted questions. Fix them before proceeding.

### Step 4: Enter Phase 0-B

Proceed to `/create-prd` with the confirmed requirements and research findings.

---

## Path B: Full Brainstorming Flow

### Stage 1: Explore Project Context

Check the current workspace:

- What type of project exists (if any)?
- What documentation is available?
- What is the tech stack (if applicable)?

Assess scope: if the request describes multiple independent subsystems, flag this immediately. Help the user decompose into sub-projects. Each sub-project gets its own spec, plan, and implementation cycle.

### Stage 2: Clarifying Questions (One at a Time)

**Rules:**
- Ask **one question per message**. Do not combine multiple questions.
- Prefer **multiple choice** when possible, but open-ended is fine too.
- Focus on: purpose, constraints, success criteria, target users.
- If a topic needs more exploration, break it into multiple sequential questions.

**Key areas to cover:**
1. What problem does this solve? Who is the user?
2. What is the MVP scope? What is explicitly out of scope?
3. Technical constraints (platform, performance, offline requirements)?
4. Success criteria — how will we know this is done and working?
5. Data model — what are the core entities and their relationships?
6. Delivery constraints — **REQUIRED before writing any spec**:
   - Who is building this? (solo / small team — how many people?)
   - What is the target launch date or available time budget?
   - Tech proficiency in the chosen stack (e.g., Rust / Tauri experience level)?
   - Full-time or part-time? Estimated weekly hours available?

   **Do NOT skip these questions.** If left unanswered, all timeline estimates in the PRD will be invalid. If the user declines to answer, record explicitly as "unknown" and flag in the PRD.

### Stage 3: Propose 2-3 Approaches

Once the idea is sufficiently refined:

- Propose **2-3 different architectural approaches** with trade-offs.
- Present your **recommended option** with reasoning.
- Let the user choose or request modifications.

### Stage 4: Present Design (Incremental Approval)

Once you understand what to build, present the design **section by section**:

- Scale each section to its complexity (a few sentences for straightforward items, more for nuanced decisions).
- Ask for approval **after each section** before moving to the next.
- Cover: architecture, components, data flow, error handling, testing strategy.

**Design for isolation:** Break the system into smaller units, each with one clear purpose, well-defined interfaces, and independent testability.

### Stage 5: Write Design Document

Save the validated design to:

```
docs/specs/YYYY-MM-DD-<topic>-design.md
```

The design document should include:

- Problem statement and user story
- Architecture overview
- Component breakdown
- Data model and flow
- Technology choices and rationale
- Known constraints and trade-offs
- Open questions (none left unanswered)

**Downstream extraction guide** — append this note at the end of the design document to guide downstream commands:

```markdown
---
> Downstream extraction guide:
> - For /create-prd: extract Sections 1-5 (problem, architecture, data model, constraints, open questions). Architecture details in Sections 2-3 are copied into the PRD at a summary level — do not inline full component specs.
> - For CLAUDE.md: extract only technology choices, naming conventions, and key patterns. Detailed component breakdown and error handling strategies belong in reference documents, not CLAUDE.md.
> - For /ref-research: this document defines the project scope. External best practices for the detected tech stack should be researched and written to .claude/reference/.
```

### Stage 6: Spec Self-Review

After writing the spec, review with fresh eyes:

1. **Placeholder scan**: Any "TBD", "TODO", incomplete sections, or vague requirements? Fix them.
2. **Internal consistency**: Do any sections contradict each other?
3. **Scope check**: Is this focused enough for a single implementation plan?
4. **Ambiguity check**: Could any requirement be interpreted two ways? If so, make it explicit.

Fix any issues inline.

### Stage 7: User Review Gate

Present the written spec to the user:

> "Spec written and saved to `docs/specs/YYYY-MM-DD-<topic>-design.md`. Please review it and let me know if you want to make any changes before we proceed to PRD creation."

If changes are requested, revise and re-run the self-review loop. Only proceed once the user approves.

### Stage 8: Enter Phase 0-B

Proceed to `/create-prd` with the approved design document as the primary input.

---

## Hard Gate

**Do NOT proceed to Phase 0-B (`/create-prd`) until:**

- Path A: Research findings have been reviewed, and any detected gaps have been resolved.
- Path B: The design document has been written, self-reviewed, and approved by the user.

Do NOT write any implementation code during this phase.

---

## Sub-Agent Research Template

When launching sub-agents for research, use this prompt structure:

```
Research the following for a [project type] application:

**Context**: [Brief project description from user]

**Research Focus Areas**:
1. Architecture patterns and best practices
2. Technology stack recommendations with rationale
3. Common pitfalls and how to avoid them
4. Reference implementations or similar projects
5. Performance considerations for [specific concern, e.g., offline-first, full-text search, multi-device sync]

**Deliverable**: A concise report with actionable recommendations, prioritized by impact.
```

---

## Output

After completing Path A or Path B:

- Summarize the agreed-upon requirements
- List key architectural decisions and their rationale
- Highlight any remaining open questions (if any)
- Recommend next steps: Phase 0-B (`/create-prd`)
