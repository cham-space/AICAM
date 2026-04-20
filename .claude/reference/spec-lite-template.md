# Spec-Lite: {feature-name}

> One-page functional specification. Target ≤ 120 lines.
> This is the single source of truth for implementation scope.

---

## Scope / Non-Goals

**In Scope:**
- {what this feature covers}

**Non-Goals (deferred to future phases):**
- {what is explicitly excluded}

---

## API Contract & Naming Mapping

> Only fill if this feature touches API endpoints.

| Frontend Param | Backend Field | Backend Param Annotation | Notes |
|----------------|---------------|------------------------|-------|
| `{camelCase}` | `{field_name}` | `{framework-specific annotation or alias}` | |

> Fill backend param annotation column per your project's framework (e.g., Java: `@RequestParam(name=...)`, Python FastAPI: `Query(alias=...)`, Go: `form:"..."`).

---

## Test Gates (MANDATORY)

| Test Type | Command | Evidence Required |
|-----------|---------|-------------------|
| Unit Tests | `{test runner command}` | Passing output + file count |
| Business Workflow Tests | `{e2e or API workflow command}` | Screenshot or API call evidence |

---

## Acceptance Criteria Snapshot

- [ ] {criterion 1}
- [ ] {criterion 2}
- [ ] {criterion 3}
- [ ] {criterion 4}
