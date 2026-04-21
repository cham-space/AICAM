# Test Strategy: REST API / Backend Service

## Project Type Identifier
`rest-api` — Pure backend HTTP API services (Express, FastAPI, Spring Boot, Axum, Gin, etc.)

### Detection Signals
| File | Signal |
|------|---------|
| `package.json` + `express`/`fastify` dep | Node.js API |
| `requirements.txt` / `pyproject.toml` + `fastapi`/`django` | Python API |
| `pom.xml` / `build.gradle` + `spring-boot` | Spring Boot |
| `Cargo.toml` + `axum`/`actix-web` | Rust API |
| No frontend directory (no `src/components/`) | Backend-only |

---

## Smoke Test Checklist

- [ ] Service starts without errors (listening on target port)
- [ ] `GET /health` or `GET /` returns 200
- [ ] Database connection succeeds (no connection error in startup logs)
- [ ] At least one core endpoint responds normally (`curl` or HTTP client test)
- [ ] Auth endpoint can issue a token (if authentication is present)

---

## Business Workflow Verification

Use **multi-step API workflow tests** (data-state chain validation):

### Typical Journey Template

```
Step 1: POST /auth/login → get token
Step 2: POST /resources → create resource, record resource_id
Step 3: GET /resources/{resource_id} → verify fields match creation data
Step 4: PATCH /resources/{resource_id} → update operation
Step 5: GET /resources/{resource_id} → verify update persisted
Step 6: DELETE /resources/{resource_id}
Step 7: GET /resources/{resource_id} → 404 confirms deletion
```

### Tool Selection
| Language | Recommended Tool |
|------|---------|
| Node.js | `supertest` + Jest/Vitest |
| Python | `pytest` + `httpx` / `TestClient` |
| Java | `MockMvc` / `RestAssured` + JUnit |
| Rust | `axum::serve` in-process + `reqwest` |
| General | Bruno / Hoppscotch collections (CLI-runnable) |

---

## Unit Test Focus

| Layer | Test Subject | Assertions |
|----|---------|------|
| Service layer | Business logic functions | Mock Repository, verify output |
| Repository layer | DB queries | Test database (testcontainers or in-memory) |
| Serialization | Request/response DTOs | serde / JSON Schema validation |
| Validators | Input validation rules | Both valid and invalid inputs covered |
| Error handling | 4xx/5xx response format | Consistent error structure assertions |

---

## Mock Strategy

| External Dependency | Mock Approach |
|---------|---------|
| Database | TestContainers (integration) / in-memory SQLite (unit) |
| External HTTP APIs | `wiremock` / `httpmock` / `nock` (Node) |
| Message queue | In-memory stub (same as worker.md strategy) |
| File storage (S3) | `localstack` / temp directory |
| Clock | Inject fake clock, fix timestamps |

---

## Evidence Requirements

- Smoke Test: Service startup log screenshot + `curl /health` returns 200 screenshot
- Business workflow: Workflow test output screenshot (status code + key fields per step)
- Deletion verification: Final step 404 response screenshot
- DB verification (optional): Before/after DB query result screenshots
