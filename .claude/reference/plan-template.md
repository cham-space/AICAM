# Feature: <feature-name>

The following plan should be complete, but its important that you validate documentation and codebase patterns and task sanity before you start implementing.

Pay special attention to naming of existing utils types and models. Import from the right files etc.

## Feature Description

<Detailed description of the feature, its purpose, and value to users>

## User Story

As a <type of user>
I want to <action/goal>
So that <benefit/value>

## Problem Statement

<Clearly define the specific problem or opportunity this feature addresses>

## Solution Statement

<Describe the proposed solution approach and how it solves the problem>

## Feature Metadata

**Feature Type**: [New Capability/Enhancement/Refactor/Bug Fix]
**Estimated Complexity**: [Low/Medium/High]
**Primary Systems Affected**: [List of main components/services]
**Dependencies**: [External libraries or services required]

## Spec-Lite (MANDATORY)

Create one-page spec at `.agents/specs/{feature-name}.spec.md` (target <= 120 lines):

- Scope / Non-goals
- API contract and naming mapping (if API touched)
- Test gates: Unit + Business Workflow
- Acceptance criteria snapshot

---

## CONTEXT REFERENCES

### Relevant Codebase Files IMPORTANT: YOU MUST READ THESE FILES BEFORE IMPLEMENTING!

<List files with line numbers and relevance. Examples below:>

- `{path/to/existing_logic_file}` (lines XX-XX) - Why: Contains the core pattern for {Feature} that we will mirror.
- `{path/to/data_model_file}` (lines XX-XX) - Why: Database/Data structure to follow for consistency.
- `{path/to/existing_test_file}` - Why: Reference for testing patterns and mock setup.

### New Files to Create

- `{path/to/new_logic_file}` - Core business logic implementation for the feature.
- `{path/to/new_model_file}` - Data model or Schema definition for the new resource.
- `{path/to/new_interface_file}` - API Controller, Router, or Interface to expose the functionality.
- `{path/to/new_test_file}` - Unit and integration tests for the new implementation.

### Relevant Documentation YOU SHOULD READ THESE BEFORE IMPLEMENTING!

- [Documentation Link 1](https://example.com/doc1#section)
  - Specific section: Authentication setup
  - Why: Required for implementing secure endpoints
- [Documentation Link 2](https://example.com/doc2#integration)
  - Specific section: Database integration
  - Why: Shows proper async database patterns
- [{Documentation Name}]({URL}#section_anchor)
  - Specific section: {e.g., Auth Setup, Async Patterns, API Specs}
  - Why: {Describe why this is critical for the implementation}.
  
### [LANGUAGE CONTEXT & ADAPTATION]
*Note: The execution agent must adapt the following based on the project's primary language. Test commands → see Test Task Enforcement Rule in STEP-BY-STEP TASKS.*

| Language | Logic/Service Layer | Data/Model Layer |
| :--- | :--- | :--- |
| **Java (Spring)** | `.../service/*.java` | `.../entity/*.java`, `.../dto/*.java` |
| **Python** | `.../services/*.py` | `.../models/*.py`, `.../schemas/*.py` |
| **TypeScript** | `.../services/*.ts` | `.../interfaces/*.ts`, `.../dto/*.ts` |

### Patterns to Follow

<Specific patterns extracted from codebase - include actual code examples from the project>

**Naming Conventions:** (for example)

**Error Handling:** (for example)

**Logging Pattern:** (for example)

**Other Relevant Patterns:** (for example)

---

## STEP-BY-STEP TASKS

IMPORTANT: Execute every task in order, top to bottom. Each task is atomic and independently testable.

### Migration / Data Task Safety Rule

If any task involves database migrations or data operations, each such task MUST declare:

- **DESTRUCTIVE**: YES / NO — Does this task contain TRUNCATE / DROP / unconditional DELETE / column removal?
- **ROLLBACK**: `{rollback command or down-migration script}` — Required if DESTRUCTIVE = YES
- **BACKUP_REQUIRED**: YES / NO — Must a backup be confirmed before execution?

> ⚠ TRUNCATE and DROP are forbidden in migration scripts. Migrations are for schema changes only.
> Data cleanup must use separate `data-fix` scripts, clearly named and outside the migration version sequence.

### Task Format Guidelines

Use information-dense keywords for clarity:

- **CREATE**: New files or components
- **UPDATE**: Modify existing files
- **ADD**: Insert new functionality into existing code
- **REMOVE**: Delete deprecated code
- **REFACTOR**: Restructure without changing behavior
- **MIRROR**: Copy pattern from elsewhere in codebase

### Test Task Enforcement Rule

> **LESSON LEARNED**: If a test class appears in TESTING STRATEGY but has no corresponding Task in this section, the implementation agent WILL skip it. This has caused entire phases to ship with zero tests.

**Mandatory rules:**

1. **Test Tasks are first-class Tasks.** Every Implementation Phase that creates business logic files (Service, Util, Handler, Helper, etc.) MUST include a dedicated test-creation Task at the end of that Phase.
2. **VALIDATE must match the Task's nature.** Tasks creating business logic MUST use a test runner as VALIDATE — never a compile-only command.

   | Language | Compile-only (❌ for logic Tasks) | Test runner (✅ required) |
   |----------|----------------------------------|-------------------------|
   | Java | `mvn compile -q` | `mvn test -Dtest=XxxTest` |
   | Python | `python -m py_compile file.py` | `pytest tests/test_xxx.py -v` |
   | TypeScript | `tsc --noEmit` | `jest --testPathPattern=xxx.test.ts` |
   | Go | `go build ./...` | `go test ./pkg/xxx/... -run TestXxx` |

3. **Test Task template:**
   ```
   ### Task N: CREATE unit tests for Phase X
   
   **FILES TO CREATE**:
   - `{path/to/XxxServiceTest}` — minimum Y test methods
   - `{path/to/YyyUtilTest}` — minimum Z test methods
   
   **VALIDATE**: `{test runner command}` passes && new test count ≥ N
   **GATE**: This Task failing blocks the Phase from completion.
   ```

### {ACTION} {target_file}

- **IMPLEMENT**: {Specific implementation detail}
- **PATTERN**: {Reference to existing pattern - file:line}
- **IMPORTS**: {Required imports and dependencies}
- **GOTCHA**: {Known issues or constraints to avoid}
- **VALIDATE**: `{executable validation command}`

<Continue with all tasks in dependency order...>

---

## Smoke Test Checklist

<!-- 必填。每条为"操作 → 预期结果"格式，应用/服务启动后逐条验证。缺少此节将导致 /execute 停止执行。 -->

**启动命令**: `{command to start app/service}`

- [ ] 应用/服务正常启动，无崩溃
- [ ] {核心功能 A}：{操作步骤} → {预期结果}
- [ ] {核心功能 B}：{操作步骤} → {预期结果}
- [ ] 重启/二次启动不崩溃，数据保留

## Mock Strategy

<!-- 必填。说明业务流程测试如何不依赖真实外部服务。 -->

| 外部依赖 | Mock 方案 | 工具/库 |
|---------|---------|---------|
| {外部 API / DB / 第三方服务} | {预设响应 fixture / 内存 DB / stub} | {工具名} |

---

## TESTING STRATEGY

<Define testing approach based on project's test framework and patterns discovered in during research>

### Unit Tests

<Scope and requirements based on project standards>

Design unit tests with fixtures and assertions following existing testing approaches

### Integration Tests

<Scope and requirements based on project standards>

### Business Workflow Tests (MANDATORY)

Define at least one end-to-end business workflow validation path:

- Frontend available: use `e2e-test` / browser-based journey tests
- Backend-only: use API workflow tests (multi-step request sequence with data-state checks)

Include pass/fail evidence requirements (screenshots, response assertions, DB checks, or logs).

### Edge Cases

<List specific edge cases that must be tested for this feature>

### Test-to-Task Mapping (MANDATORY)

| Test File | Covers | Task # | VALIDATE Command |
|-----------|--------|--------|------------------|
| `{path/to/XxxServiceTest}` | XxxService core logic, edge cases | Task N | `{test runner} {test filter}` |
| `{path/to/YyyUtilTest}` | YyyUtil boundary values | Task M | `{test runner} {test filter}` |
| ... | ... | ... | ... |

---

## VALIDATION COMMANDS

<Define validation commands based on project's tools discovered in Stage 2>

Execute every command to ensure zero regressions and 100% feature correctness.

### Level 1: Syntax & Style

<Project-specific linting and formatting commands>

### Level 2: Unit Tests

<Project-specific unit test commands>

### Level 3: Integration Tests

<Project-specific integration test commands>

### Level 4: Business Workflow Tests (MANDATORY)

<Project-specific business workflow test commands (UI E2E or API workflow tests)>

### Level 5: Manual Validation

<Feature-specific manual testing steps - API calls, UI testing, etc.>

### Level 6: Additional Validation (Optional)

<MCP servers or additional CLI tools if available>

---

## ACCEPTANCE CRITERIA

<List specific, measurable criteria that must be met for completion>

- [ ] Feature implements all specified functionality
- [ ] All validation commands pass with zero errors
- [ ] Unit test coverage meets requirements (80%+)
- [ ] Integration tests verify end-to-end workflows
- [ ] Business workflow tests pass (UI E2E or API workflow)
- [ ] If API is involved: field naming mapping is verified and consistent
- [ ] Code follows project conventions and patterns
- [ ] No regressions in existing functionality
- [ ] Documentation is updated (if applicable)
- [ ] Performance meets requirements (if applicable)
- [ ] Security considerations addressed (if applicable)

---

## NOTES

<Additional context, design decisions, trade-offs>
