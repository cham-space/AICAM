---
name: backend-test
description: Backend test execution skill covering REST API integration tests, database tests, and mock strategies. USE THIS SKILL when creating backend test files, writing API workflow tests, setting up database test fixtures with transaction rollback, or determining mock vs integration test boundaries. Covers unit tests for service/util/handler layers, integration tests for API endpoints, and database migration verification.
---

# Backend Test Execution

## When to Use

Activate when:
- Creating test files for backend service/util/handler/controller layers
- Writing REST API integration tests (multi-step request + DB verification)
- Testing database migrations or schema changes
- Setting up test fixtures and test data strategies
- User mentions "backend test", "API test", "integration test", "database test"

## Core Principle

Backend tests must verify both the code path AND the data outcome. A passing test that doesn't check the database state is incomplete.

---

## Test Types

### 1. Unit Tests — Service / Util / Handler Logic

```
Scope: Single function or method
Database: Mocked or in-memory
Time: < 10ms per test
```

**Rules**:
- Mock external dependencies (DB, HTTP clients, file system)
- Test happy path + at least 1 failure path per public function
- Test edge cases: null, empty collection, zero value, max value
- Assert behavior, not implementation details

**Per-Language Templates**:

| Language | Framework | Mock Strategy |
|----------|-----------|---------------|
| TypeScript/Node.js | Jest / Vitest | `jest.mock()` / `vi.mock()` for modules |
| Python | pytest | `unittest.mock` / `pytest-mock` |
| Java | JUnit 5 + Mockito | `@Mock` / `@InjectMocks` |
| Go | testing + testify | Interfaces + mock structs |
| Rust | `#[cfg(test)]` + `#[tokio::test]` | Trait mocks / `mockall` |
| C# | xUnit + Moq | `Mock<T>` |

### 2. Integration Tests — API Endpoints

```
Scope: HTTP request → controller → service → DB → response
Database: Real (test DB or in-memory)
Time: < 200ms per test
```

**Rules**:
- Start the app in test mode (test DB or in-memory DB)
- Make real HTTP requests (supertest / TestClient / reqwest)
- Assert: HTTP status, response body structure, response field values
- THEN query the database to verify side effects
- Clean up between tests (transaction rollback or table truncation)

**Per-Project-Type Commands**:

| Type | Setup | Test Runner |
|------|-------|-------------|
| `rest-api` (Express) | `import supertest from 'supertest'` + test DB | `jest --testPathPattern=integration` |
| `rest-api` (FastAPI) | `from fastapi.testclient import TestClient` | `pytest -m integration` |
| `rest-api` (Spring) | `@SpringBootTest` + `TestRestTemplate` | `mvn test -Dtest=*IntegrationTest` |
| `rest-api` (Go) | `httptest.NewServer` + test DB | `go test -tags=integration ./...` |
| `worker` | Start worker with test broker + inject messages | Language test runner |
| `cli` | `assert_cmd::Command::cargo_bin()` / `subprocess.run()` | Language test runner |

### 3. Database Tests — Migrations + Schema

```
Scope: Migration up/down, schema constraints, data integrity
Database: Real (same engine as production)
Time: < 500ms per migration
```

**Rules**:
- Test migration `up` creates expected tables/columns/indexes
- Test migration `down` reverses cleanly (if supported)
- Test NOT NULL / UNIQUE / FOREIGN KEY constraints
- Test index usage on query patterns (EXPLAIN)
- Never test with production data — use seed fixtures

---

## Test Data Strategy (replaces Mock Strategy in plan-template v1.3.0+)

### Principles

1. **Each test owns its data**: Tests must not depend on data created by other tests
2. **Clean up after each test**: Transaction rollback or per-test DB reset
3. **Seed only what's needed**: Minimal fixtures, not full database dumps
4. **Fixtures over mocks for data**: Real data rows > mocked DB calls for integration tests

### Patterns

| Pattern | When to Use | Tool |
|---------|-------------|------|
| **Transaction rollback** | SQL databases, per-test cleanup | BEGIN → test → ROLLBACK |
| **In-memory DB** | SQLite, H2 — fast, no cleanup needed | `:memory:` / `jdbc:h2:mem:` |
| **Test fixtures (factory)** | Reusable seed data across tests | factory_boy (Python) / fishery (TS) |
| **Table truncation** | Between test suites, when rollback unavailable | DELETE FROM or TRUNCATE (with caution) |
| **Docker testcontainers** | Need real PostgreSQL/MySQL/Redis | testcontainers-{lang} |

### Per-Language Fixture Examples

```
TypeScript (fishery):
  const userFactory = Factory.define<User>({ ... })
  const testUser = await userFactory.create({ role: 'admin' })

Python (factory_boy):
  class UserFactory(factory.Factory):
      email = factory.Faker('email')
  test_user = UserFactory(role='admin')

Rust (fixtures via functions):
  fn test_user(pool: &PgPool) -> User { ... }
  let user = test_user(&pool);
```

---

## Validation Checklist

When reviewing backend tests, verify:

- [ ] Every public service/handler function has at least 1 unit test
- [ ] Every API endpoint has at least 1 integration test
- [ ] Tests assert database side effects (not just HTTP response)
- [ ] Tests clean up their own data (no cross-test pollution)
- [ ] Edge case coverage: nulls, empty input, zero values, max limits
- [ ] Error paths tested: invalid input, missing auth, DB failure
- [ ] Migration tests cover up + down paths
- [ ] Test data factory exists for core entities (not inline INSERT per test)

---

## Common Pitfalls

| Pitfall | Symptom | Fix |
|---------|---------|-----|
| Tests share state via DB | Test B passes alone but fails in suite | Transaction rollback or per-test cleanup |
| Mocking DB instead of using test DB | Tests pass but real DB fails (schema mismatch) | Use same DB engine in test as production |
| No DB assertion after API call | API returns 200 but nothing was saved | Always query DB to verify side effects |
| Production data in tests | Test breaks when production data changes | Seed test-specific fixtures |
| Slow tests from real external calls | Test suite takes minutes | Mock external APIs at boundary; use testcontainers for DB |
