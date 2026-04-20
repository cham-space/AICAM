---
description: "Phase 0-C: Research frontend components and API best practices, write reference docs"
argument-hint: ""
---

# Research References: Frontend & API Best Practices

## Mission

Launch parallel sub-agents to research industry best practices for this project's frontend components and API design. Write findings into `.claude/reference/` so that every future AI session has authoritative, project-specific guidance on demand.

**Core Principle**: Reference docs capture *external* best practices. They do not duplicate project-internal conventions (that is the role of `CLAUDE.md`).

---

## Step 1: Read PRD

Before dispatching any agents, load `docs/PRD.md` and extract:

- **Tech stack**: frontend framework, component library, API style (REST / tRPC / GraphQL / IPC)
- **Application type**: what kind of UI (desktop overlay, management dashboard, settings panel, etc.)
- **Integration points**: which third-party services or APIs are involved

If `docs/PRD.md` is not found, check `docs/specs/` for an approved design document. If neither exists, stop and ask the user to run `/create-prd` first.

---

## Step 2: Determine Research Scope

Based on the PRD, decide which reference documents are needed:

| Condition | Generate |
|-----------|----------|
| Project has a frontend (React / Vue / Svelte / etc.) | `components.md` |
| Project has API endpoints or external service calls | `api.md` |
| Both | Both files |
| Neither (pure CLI / library) | Skip; inform user and proceed to `/create-rules` |

### Content Boundary Declaration

The following content types belong in reference documents and **must NOT flow into CLAUDE.md**:

- Complete dependency/crate lists (these live in `Cargo.toml` / `package.json`)
- Detailed testing strategies and pyramid diagrams
- Streaming/real-time implementation code examples
- Full ARIA attribute tables and accessibility specifications
- Third-party API endpoint URLs and authentication details
- Reference implementation descriptions and comparison tables
- Anti-pattern catalogs and code-level optimization patterns

CLAUDE.md should only contain: framework-level tech choices, naming conventions, error handling approach, and a pointer to the reference document for deeper guidance.

**Handshake with `/create-rules`**: When `/create-rules` runs after this command, it will check for these reference files and link to them from CLAUDE.md. If `/ref-research` was skipped, the Volume gate in `/create-rules` will attempt to create them anyway — but the content will be less authoritative. Always run `/ref-research` before `/create-rules` for projects with frontend or API components.

---

## Step 3: Dispatch Parallel Sub-Agents

Launch up to two sub-agents concurrently. Each agent must receive:
- Specific research scope (do not overlap)
- The project's tech stack from the PRD
- Expected output format (structured Markdown with sections and examples)

### Agent A — Frontend Component Best Practices

**Research scope** (tailor to detected stack):
1. Component architecture patterns for the detected framework (e.g., React + Tauri, React + Electron)
2. State management: recommended approaches for this app type, anti-patterns to avoid
3. Styling conventions: utility-first (Tailwind) vs CSS Modules vs CSS-in-JS trade-offs for desktop apps
4. Accessibility: ARIA patterns relevant to the component types in the PRD
5. Performance: code splitting, lazy loading, virtual lists for large datasets
6. Testing: component testing strategy (unit snapshot vs interaction testing)
7. 3-5 reference implementations or open-source projects worth studying

**Output format for `components.md`:**

```markdown
# Frontend Component Reference

> Generated: YYYY-MM-DD | Stack: {framework} + {styling}

## 1. Component Architecture
...

## 2. State Management
...

## 3. Styling Conventions
...

## 4. Accessibility Patterns
...

## 5. Performance Guidelines
...

## 6. Testing Strategy
...

## 7. Reference Implementations
...
```

### Agent B — API Design & Contract Best Practices

**Research scope** (tailor to detected API style):
1. Endpoint naming and URL structure conventions for the detected style (REST / IPC / GraphQL)
2. Request / response schema design: field naming (camelCase vs snake_case), envelope patterns
3. Error response format: standard error shapes, HTTP status code usage
4. Versioning strategy: URL versioning vs header versioning vs no-versioning
5. Authentication patterns relevant to this project (API key, JWT, OAuth, none)
6. Contract-first workflow: how to define and validate the API contract before implementation
7. Streaming / real-time patterns if applicable (SSE, WebSocket, Tauri IPC streams)

**Output format for `api.md`:**

```markdown
# API Design Reference

> Generated: YYYY-MM-DD | Style: {REST/IPC/GraphQL} | Auth: {method}

## 1. Endpoint Naming Conventions
...

## 2. Request / Response Schema
...

## 3. Error Handling
...

## 4. Versioning Strategy
...

## 5. Authentication Patterns
...

## 6. Contract-First Workflow
...

## 7. Streaming & Real-Time Patterns
...
```

---

## Step 4: Write Reference Files

After both agents return findings:

1. Synthesize and de-duplicate overlapping content
2. Write `components.md` to `.claude/reference/components.md`
3. Write `api.md` to `.claude/reference/api.md`
4. Update `.claude/reference/index.md` to include the new files in the table

---

## Step 5: Self-Review

Before confirming completion, verify:

- [ ] Content is specific to this project's tech stack — not generic web development advice
- [ ] Each section has actionable guidance, not just definitions
- [ ] No placeholder text ("TBD", "TODO", "…") remains
- [ ] `index.md` table is updated

Fix any issues inline before proceeding.

---

## Step 6: Output Confirmation

After writing all files:

1. Confirm file paths written
2. List the top 3 most important findings per document
3. Note any areas where research was inconclusive or where the user should review manually

Then prompt:

> "Reference documents written. Next step: run `/create-rules` to generate `CLAUDE.md` — this will incorporate these reference docs into the project's global rules."
