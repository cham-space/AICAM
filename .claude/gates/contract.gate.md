---
name: contract-gate
description: API contract gate — naming consistency and breaking change detection
severity: blocking
applies_to: [execute, verify-phase]
---

# API Contract Gate: Naming Consistency & Breaking Changes

## Rule

When API endpoints are created or modified, verify frontend-backend field naming consistency and detect breaking changes.

## Naming Mapping Verification

Read the naming mapping table from Spec-Lite or plan file. Verify:

1. **Query/path parameters**: Frontend param names exactly match backend `name`/`alias` attributes
2. **Request body fields**: Frontend keys match backend serialized field names (after any naming strategy annotations)
3. **Response body fields**: Frontend TypeScript interfaces match JSON response field names
4. **Enum values**: Both sides use the same string representation, not ordinal/index

## Framework-Specific Checks

| Framework | Check |
|-----------|-------|
| Java Spring | `@RequestParam(name=...)` matches frontend param; `@JsonNaming` strategy respected |
| Python FastAPI | `Query(alias=...)` matches frontend; Pydantic `Field(alias=...)` considered |
| Go Gin | `c.Query("name")` string literal matches frontend; `json:"..."` struct tags |
| Node.js Express/NestJS | `req.query.xxx` / `@Query('xxx')` matches frontend call |
| Rust Actix | `#[serde(rename = "...")]` / `web::Query<Params>` naming matches frontend |

## Breaking Change Detection (v1.3.0+)

Before archiving, compare current API spec against previous version:

- Removed endpoint → ⚠️ BREAKING
- Renamed/moved field → ⚠️ BREAKING
- Changed field type (string→int) → ⚠️ BREAKING
- New required field → ⚠️ BREAKING (for existing clients)
- Added endpoint → ✅ NON-BREAKING
- New optional field → ✅ NON-BREAKING

### Detection Tool (v1.3.1)

Use `oasdiff` for automated OpenAPI breaking change detection:

```bash
# Install: brew install oasdiff  (or go install github.com/tufin/oasdiff@latest)

# Save current spec as baseline before implementing changes
cp .agents/specs/openapi-current.yaml archive/openapi-phase-{N-1}.yaml

# After implementation, diff against baseline
oasdiff breaking archive/openapi-phase-{N-1}.yaml .agents/specs/openapi-current.yaml

# For non-OpenAPI projects: manually review the Breaking Change rules above,
# record findings in the Verification Report's API Naming Consistency row
```

**Spec archiving protocol** (run in `/close-phase` before archiving plan):
1. If this Phase modified API endpoints → save current spec to `archive/openapi-phase{N}.yaml`
2. If `oasdiff` is installed → CI runs `oasdiff breaking` as part of `verify-phase` gate
3. If `oasdiff` is not installed → Breaking Change check falls back to AI manual review of the rules above

## Cycle Prevention

- `contract-gate.md` is consumed by `api-contract-first` Skill and CI
- `api-contract-first/SKILL.md` references the validation checklist from this gate
- CI reads this gate to decide pipeline blocking rules
