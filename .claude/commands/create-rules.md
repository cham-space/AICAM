---
description: Create global rules (CLAUDE.md) from codebase analysis
argument-hint: ""
---

# Create Global Rules

Generate a CLAUDE.md file by analyzing the codebase and extracting patterns.

---

## Objective

Create project-specific global rules that give Claude context about:
- What this project is
- Technologies used
- How the code is organized
- Patterns and conventions to follow
- How to build, test, and validate

---

## Step 1: DISCOVER

### Identify Project Type

First, determine what kind of project this is:

| Type | Indicators |
|------|------------|
| Web App (Full-stack) | Separate client/server dirs, API routes |
| Web App (Frontend) | React/Vue/Svelte/Angular, no server code |
| API/Backend | Express/FastAPI/Spring/Fiber/etc, no frontend |
| Library/Package | `main`/`exports` in package.json, or library JAR/module |
| CLI Tool | `bin` in package.json, command-line interface |
| Monorepo | Multiple packages, workspaces config |
| Script/Automation | Standalone scripts, task-focused |
| Java/Spring Boot | `pom.xml`/`build.gradle` with `spring-boot-starter-*` deps, `@SpringBootApplication` |
| Python | `pyproject.toml`, `requirements.txt`, `*.py` files |
| Go | `go.mod`, `*.go` files, `cmd/` or `internal/` dirs |
| Mobile (React Native/Flutter) | `app.json`, `ios/`/`android/` dirs, or `pubspec.yaml` |
| Legacy Java EE | `persistence.xml`, `web.xml`, `javax.*` imports |

### Analyze Configuration

Look at root configuration files relevant to the project's language:

```
# JavaScript/TypeScript:
package.json       → dependencies, scripts, type
tsconfig.json      → TypeScript settings
vite.config.*      → Build tool

# Java:
pom.xml            → Maven dependencies, plugins, profiles
build.gradle       → Gradle dependencies, tasks
application.yml    → Runtime config (datasource, server, logging)

# Python:
pyproject.toml     → dependencies, build system
requirements.txt   → pip dependencies

# Go:
go.mod             → module path, dependencies

# Rust:
Cargo.toml         → dependencies, features, edition
```

### Map Directory Structure

Explore the codebase to understand organization:
- Where does source code live?
- Where are tests?
- Any shared code?
- Configuration locations?

**Common source layouts by language:**

| Language | Source Root | Tests | Config |
|----------|-------------|-------|--------|
| Java/Maven | `src/main/java` | `src/test/java` | `src/main/resources` |
| Java/Gradle | `src/main/kotlin` or `java` | `src/test/kotlin` or `java` | `src/main/resources` |
| Python | `src/` or project root | `tests/` or `test/` | project root, `pyproject.toml` |
| Go | `cmd/`, `internal/`, `pkg/` | `_test.go` alongside source | project root |
| Node.js/TS | `src/` | `src/**/*.test.*` or `tests/` | project root, `tsconfig.json` |
| Rust | `src/` | `src/` (inline `#[cfg(test)]`) | project root, `Cargo.toml` |

---

## Step 2: ANALYZE

### Extract Tech Stack

From configuration files and source code, identify:
- Language and version (Java 17, Python 3.12, Go 1.22, Node 20, etc.)
- Framework(s) (Spring Boot, FastAPI, Gin, Express, etc.)
- Database (if any)
- Testing tools
- Build tools
- Linting/formatting

### Identify Patterns

Study existing code for:
- **Naming**: How are files, functions, classes named?
  - *Java*: camelCase methods, PascalCase classes, `UserService` vs `UserServiceImpl`
  - *Python*: snake_case functions, PascalCase classes
  - *Go*: PascalCase exported, camelCase unexported
  - *TypeScript*: camelCase functions, PascalCase components
- **Structure**: How is code organized within files?
  - *Java*: Layered (Controller → Service → Repository), DTO vs Entity
  - *Python*: Module-based, often single file per component
  - *Go*: Package-based, `internal/` for private, `cmd/` for entry points
  - *TypeScript*: Feature folders, co-located tests/styles
- **Errors**: How are errors created and handled?
  - *Java*: Global `@ControllerAdvice` or local try-catch? `@Slf4j` or `System.out`?
  - *Python*: Custom exception classes, `logging` module
  - *Go*: `error` return values, `fmt.Errorf` wrapping
  - *TypeScript*: Error boundaries, try/catch with typed errors
- **Tests**: How are tests structured?
  - *Java*: JUnit 4/5, Mockito, `@SpringBootTest`
  - *Python*: pytest, unittest, fixtures
  - *Go*: `_test.go` files, `testing` package, table-driven tests
  - *TypeScript*: Jest, Vitest, React Testing Library

### Find Key Files

Identify files that are important to understand:
- Entry points (e.g., `main()`, `Application.java`, `main.py`, `cmd/main.go`, `index.ts`)
- Configuration files
- Core business logic
- Shared utilities
- Type definitions

---

## Step 3: GENERATE

### Create CLAUDE.md

Use the template at `.claude/CLAUDE-template.md` as a starting point.

**Output path**: `CLAUDE.md` (project root)

**Adapt to the project:**

- Remove sections that don't apply
- Add sections specific to this project type
- Keep it concise - focus on what's useful

**Language-Specific Adaptation Guide:**

- Remove generic sections that don't apply to this project's language.
- Add language-specific sections:
  - **Java/Spring**: JDK version, Lombok annotations, layered architecture, `mvn`/`gradle` commands
  - **Python**: Python version, type hints, `pytest` fixtures, virtual env manager
  - **Go**: Go version, `internal/` package visibility, error handling style, table-driven tests
  - **TypeScript/Node**: Runtime (Node/Bun/Deno), module system (ESM/CJS), test framework
  - **Rust**: Rust edition, error handling (`Result` vs `anyhow`), inline tests
  - **Mobile**: Platform targets, state management, navigation pattern
- **Keep it concise**: Focus on the specific frameworks, ORMs, and tools actually used.

**Volume gate**: CLAUDE.md must not exceed 150 lines. If content would exceed this limit, apply the following split rules:

| Content type | Where it goes |
|-------------|---------------|
| Project overview, tech stack (framework-level only), commands | CLAUDE.md |
| Directory structure (≤15 lines summary) | CLAUDE.md |
| Code patterns and conventions (naming, error handling, streaming approach) | CLAUDE.md (1-2 lines per pattern) |
| Detailed testing strategies, test pyramid diagrams, mock examples | `.claude/reference/testing.md` — link from CLAUDE.md |
| Full dependency/crate lists | `Cargo.toml` / `package.json` — do not enumerate in CLAUDE.md |
| Detailed API/external integration patterns | `.claude/reference/api.md` (generated by `/ref-research`) |
| Detailed component architecture, state management anti-patterns | `.claude/reference/components.md` (generated by `/ref-research`) |
| Safety rules beyond standard ones | `.claude/reference/safety-{domain}.md` — link from CLAUDE.md |

**Split trigger**: If a template section would produce >20 lines of content, write it to a reference file and replace with a 1-line pointer in CLAUDE.md.

**Key sections to include (all project types):**

1. **Project Overview** - What is this and what does it do?
2. **Tech Stack** - What technologies are used?
3. **Commands** - How to dev, build, test, lint?
4. **Structure** - How is the code organized?
5. **Patterns** - What conventions should be followed?
6. **Key Files** - What files are important to know?
7. **Reference Documents** - If `.claude/reference/components.md` exists, add: "When handling frontend components, read `.claude/reference/components.md`." If `.claude/reference/api.md` exists, add: "When handling API endpoints, read `.claude/reference/api.md`."

**Language-specific extensions (add when applicable):**

- **Project Overview**: Note the application type (REST API, batch job, web app, CLI, etc.)
- **Tech Stack**: Language version, framework version, database, build tool
- **Commands**: dev run, test, build commands specific to the project
- **Structure**: Package/module layout
- **Patterns**:
  - *Logging*: Use the project's logging framework, not `print`/`System.out`/`console.log`
  - *Data Layer*: Never return data entities directly from API endpoints, map to DTOs
  - *Profile/Env Specifics*: Production config differs from dev; read env/profile files
- **Key Files**: Entry point, data models, main config

---

## Step 4: OUTPUT

```markdown
## Global Rules Created

**File**: `CLAUDE.md`

### Project Type

{detected project type}

### Tech Stack Summary

{key technologies detected}

### Directory Structure

{brief overview}

### Next Steps

1. Review the generated `CLAUDE.md`
2. Add project-specific notes
3. Remove inapplicable sections
4. Apply Volume gate split rules to create necessary reference docs in `.claude/reference/`
```

---

## Tips

- Keep CLAUDE.md focused and scannable — **target ≤150 lines**
- Don't duplicate information that's in other docs (link instead)
- Focus on patterns and conventions, not exhaustive documentation
- If a section grows beyond 3-4 lines, consider splitting to `.claude/reference/`
- Update it as the project evolves

## Database Safety Rules (include if project uses a database)

If the project uses a relational database, add the following section to the generated CLAUDE.md:

```markdown
## Database Safety Rules

- `TRUNCATE`, `DROP TABLE`, `DROP COLUMN`, unconditional `DELETE` (no WHERE clause) are **forbidden without explicit user confirmation**
- Migration scripts must only contain schema changes (CREATE TABLE, ADD COLUMN, CREATE INDEX, etc.)
- Data cleanup must use separate `data-fix` scripts — never mix with migration version sequences
- Every destructive migration MUST include a rollback script
- Column type changes that may truncate data require backup confirmation before execution
```