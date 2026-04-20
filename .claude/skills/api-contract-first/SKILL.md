---
name: api-contract-first
description: >
  Enforce API Contract-First development workflow between backend and frontend.
  Generates and validates a shared OpenAPI spec, ensures frontend services/types match backend data models,
  catches parameter naming mismatches (case conventions, aliasing), missing endpoints, and type inconsistencies.
  USE THIS SKILL whenever: building new API endpoints, creating frontend service layers, adding new pages that call APIs,
  modifying data models/Request/Response classes, changing controller method signatures, or when the user mentions
  "API contract", "frontend-backend mismatch", "field mapping", "OpenAPI", "swagger", or "API consistency".
  Also trigger when creating or modifying files in API controller, service, or data transfer directories.
---

# API Contract-First Development Workflow

## Why This Matters

Without a shared contract, frontend and backend diverge silently. The three most common failure modes:
1. **Parameter naming blindspot**: Backend uses one naming convention for query parameters, frontend sends another — silently fails.
2. **Phantom endpoints**: Frontend implements operations that backend never created.
3. **Type mismatches**: Frontend sends a string where backend expects an integer, or vice versa.

## Core Principle

**The OpenAPI spec is the single source of truth.** Both sides code against it, not against assumptions.

---

## Workflow: Adding or Modifying an API Endpoint

### Step 1: Backend First — Define the Contract

When creating or modifying a controller endpoint:

1. **Use explicit parameter naming for all query/path parameters.** Adapt to your framework:

| Framework | Query Param Naming | Path Param Naming |
|-----------|-------------------|-------------------|
| Java Spring | `@RequestParam(name = "snake_case") String camelName` | `@PathVariable("snake_case")` |
| Python FastAPI | `Query(alias="snake_case")` | `Path(alias="id")` |
| Go Gin | `c.Query("snake_case")` | `c.Param("id")` |
| Node.js Express | `req.query.snake_case` | `req.params.id` |
| Rust Actix | `web::Query<Params>` with `Deserialize` `#[serde(rename)]` | `web::Path<(i64,)>` |
| C# ASP.NET | `[FromQuery(Name = "snake_case")]` | `[FromRoute(Name = "id")]` |

**Rule**: Always use the explicit naming form — never rely on the framework's default variable-to-param mapping.

2. **All Request/Response data models must use a consistent field naming convention.** Common patterns:

| Pattern | Backend Annotation (by framework) |
|---------|-----------------------------------|
| Java: snake_case in JSON | `@JsonNaming(SnakeCaseStrategy.class)` on DTO class |
| Python: snake_case | Automatic in Pydantic; use `Field(alias=...)` for overrides |
| Go: JSON tags | ``json:"field_name"`` struct tags |
| Node.js: camelCase | Manual or use `class-transformer` `@Expose({ name: "..." })` |
| Rust: snake_case | `#[derive(Deserialize)] #[serde(rename_all = "snake_case")]` |

3. **Use enum/types (not raw integers/strings) for status/state fields:**

| Framework | Correct Approach |
|-----------|-----------------|
| Java | Use `enum` type; Jackson serializes as string by default |
| Python | Use `enum.Enum` in Pydantic model |
| Go | Use `const` + `iota` or typed constants with `String()` method |
| Node.js | Use TypeScript `enum` or union type `'enabled' \| 'disabled'` |
| Rust | Rust `enum` with `#[derive(Serialize, Deserialize)]` |

4. **Add OpenAPI/Swagger annotations for documentation:**

| Framework | Annotation |
|-----------|-----------|
| Java Spring | `@Tag(name = "...")`, `@Operation(summary = "...")` |
| Python FastAPI | `tags=["..."]` in route decorator, `summary="..."` |
| Go (swaggo) | `@Tags`, `@Summary` godoc comments |
| Node.js (NestJS) | `@ApiTags("...")`, `@ApiOperation({ summary: "..." })` |

### Step 2: Verify the Generated Spec

After backend changes, verify the OpenAPI spec:

```bash
# Start backend and fetch the spec (adjust port/path per project)
curl http://localhost:{port}/{api-docs-path} | python3 -m json.tool > openapi.json
```

Common doc paths:
| Framework | Default OpenAPI Path |
|-----------|---------------------|
| Java Spring (springdoc) | `/v3/api-docs` or `/api-docs` |
| Python FastAPI | `/openapi.json` |
| Go (swaggo) | `/swagger/doc.json` |
| Node.js NestJS | `/api-json` |

### Step 3: Frontend — Code Against the Spec

1. **Frontend types must mirror the API's field naming convention exactly.** Match the serialized JSON output from Step 1's naming strategy, not the backend's internal variable names.

2. **Service query params must use the backend's explicit parameter name** (the `name`, `alias`, or string literal from Step 1).

3. **Every frontend service function must have a corresponding backend endpoint.** Before adding a service call, verify the endpoint exists in the controller.

---

## Validation Checklist

Run this checklist when reviewing any API-related changes:

### Request Parameters (Query String)
- [ ] Every query/path parameter has explicit naming (see framework table above)
- [ ] Frontend param names exactly match the backend's declared names
- [ ] No reliance on the framework's default variable-to-param mapping

### Request Body (JSON/serialized)
- [ ] Backend data model has explicit field naming strategy annotation
- [ ] Frontend sends field names matching the serialized output
- [ ] Enum/status fields use typed values, not raw integers

### Response Body (JSON/serialized)
- [ ] Response data model has explicit field naming strategy
- [ ] Frontend type interface field names match the serialized output
- [ ] Pagination uses consistent field names across all endpoints

### Endpoint Coverage
- [ ] Every frontend service function has a matching backend controller method
- [ ] HTTP methods match (GET/POST/PUT/DELETE)
- [ ] URL paths match exactly (including path variables)

### Special Cases
- [ ] `Map`/dictionary request bodies: field keys are documented and consistent
- [ ] Response wrapper (e.g., `Result<T>`, `{ data: ... }`): frontend correctly unwraps
- [ ] Date/time formats: ISO-8601 on both sides

---

## Common Pitfalls Reference

| Pitfall | Symptom | Fix |
|---------|---------|-----|
| Parameter without explicit name | Query filter silently ignored | Add explicit naming annotation |
| Data model missing naming strategy | Inconsistent JSON field names | Add framework-specific naming annotation |
| Frontend has endpoint, backend doesn't | 404 Not Found | Add backend endpoint or remove frontend call |
| Enum serialized as ordinal/code | Type conversion error | Use enum type, ensure string serialization |
| Dictionary body with inconsistent keys | Field value is null | Document key names, prefer typed data models |
| Pagination param name inconsistency | Wrong page returned | Standardize on the project's chosen param name |

---

## OpenAPI Export for Frontend Codegen (Optional)

For projects wanting auto-generated frontend types:

```bash
# Export OpenAPI spec from running backend (adjust URL per project)
curl -o doc/openapi.json http://localhost:{port}/{api-docs-path}
```

Then use the appropriate codegen tool for the project's frontend stack:

| Frontend Stack | Codegen Tool |
|----------------|-------------|
| TypeScript | `npx openapi-typescript openapi.json -o src/services/api-types.ts` |
| Python | `openapi-python-client generate --path openapi.json` |
| Go | `oapi-codegen -package types -generate types openapi.json > types.go` |
| Kotlin (Android) | `openapi-generator-cli generate -i openapi.json -g kotlin` |

This generates type-safe interfaces directly from the backend spec, eliminating manual type synchronization.
