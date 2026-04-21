# Test Strategy: Worker / Background Service

## Project Type Identifier
`worker` — Background services, message queue consumers, cron jobs, daemons

---

## Smoke Test Checklist

- [ ] Worker process starts normally, no FATAL / panic in logs
- [ ] First message consumed and processed successfully (or one tick completes)
- [ ] Graceful shutdown: exits within timeout on SIGTERM, no zombie processes
- [ ] Health check endpoint (if any) returns 200

---

## Business Workflow Verification

Use **message queue stub + timing assertions**:

1. Inject a test message into the stub queue / channel
2. Wait for Worker to complete processing (poll state or await callback)
3. Assert: target side-effects occurred (DB rows written, downstream HTTP called, file generated, etc.)
4. Assert: idempotency — same message delivered twice produces a single final state

---

## Unit Test Focus

| Layer | Test Subject | Assertions |
|----|---------|------|
| Message parsing | `parse_message()` | Both valid and invalid formats covered |
| Business logic | Handler core functions | Mock DB / HTTP |
| Error retry | retry/backoff strategy | Reaches dead-letter queue after max attempts |
| Timer triggers | cron expression parsing | Boundary time points |

---

## Mock Strategy

| External Dependency | Mock Approach |
|---------|---------|
| Message queue (Kafka/RabbitMQ/Redis) | In-memory stub implementing the same interface |
| Database | TestContainers or SQLite in-memory |
| Downstream HTTP | `wiremock` / `mockito` / `httpmock` |
| Clock / timer | Inject fake clock, advance time manually |

---

## Evidence Requirements

- Smoke Test: Worker startup log screenshot + first message processed successfully
- Business workflow: Before/after DB row comparison screenshot (or JSON diff)
- Idempotency: DB final state screenshot after two deliveries of the same message
