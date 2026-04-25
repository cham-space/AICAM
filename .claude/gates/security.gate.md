---
name: security-gate
description: Security gate — SAST, SCA, and secrets detection
severity: blocking
applies_to: [commit]
---

# Security Gate: Automated Vulnerability Detection

## Rule

Before committing code, run automated security scans. Do not rely on AI manual review alone.

## Scan Layers

### Layer 1: Secrets Detection (gitleaks)

```bash
gitleaks detect --source . --no-git --verbose
```

High-confidence findings → **BLOCK** commit. Low-confidence → warn.

### Layer 2: SAST (semgrep)

```bash
semgrep scan --config=auto --error --quiet
```

Rules cover: SQL injection, XSS, path traversal, hardcoded credentials, unsafe deserialization.

### Layer 3: SCA — Dependency Audit

| Ecosystem | Command |
|-----------|---------|
| npm/Node.js | `npm audit --audit-level=high` |
| Rust/Cargo | `cargo audit` |
| Python/pip | `pip-audit` |
| Go | `govulncheck ./...` |

Any CRITICAL or HIGH CVE → **BLOCK** commit until patched or suppressed with justification.

## Gate Status Determination

| Condition | Result |
|-----------|--------|
| Secrets found (high confidence) | ❌ BLOCKED |
| SAST errors found | ❌ BLOCKED |
| Critical/High CVEs in dependencies | ❌ BLOCKED |
| Warnings only | ⚠️ PASS — log and continue |
| All clean | ✅ PASS |

## CI Integration

In CI pipeline:
```yaml
- name: Security Scan
  run: |
    gitleaks detect --source . --no-git
    semgrep scan --config=auto --error
    npm audit --audit-level=high  # adapt per project
```
