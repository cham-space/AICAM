---
name: security-gate
description: Security gate — SAST, SCA, and secrets detection
severity: blocking
applies_to: [commit]
---

# Security Gate: Automated Vulnerability Detection

## Rule

Before committing code, run automated security scans. Do not rely on AI manual review alone.

**Hard gate**: At least ONE scan layer MUST produce a definitive result (pass/fail).
If ALL layers are unavailable → gate = ❌ BLOCKED until resolved.

## Layer 0: Tool Availability Pre-check

Execute BEFORE Layers 1-3. Check which tools are actually runnable:

| Layer | Tool | Check | Docker Fallback |
|-------|------|-------|-----------------|
| 1 — Secrets | gitleaks | `which gitleaks` | `docker run --rm -v "$(pwd)":/src zricethezav/gitleaks detect --source /src --no-git` |
| 2 — SAST | semgrep | `which semgrep` | `docker run --rm -v "$(pwd)":/src returntocorp/semgrep semgrep scan --config=auto --error` |
| 3 — SCA | (ecosystem-dependent) | see Layer 3 table | see Layer 3 table |

### Availability Resolution Protocol

| Condition | Action |
|-----------|--------|
| ≥1 native tool available | Proceed to actual scan (Layers 1-3) |
| ALL native tools missing + Docker available | Use Docker fallback commands |
| ALL tools missing + no Docker | Present user with resolution options (see below) |
| No resolution achieved | **❌ BLOCKED** — commit refused |

**When all paths exhausted** (no native tools, no Docker):

Present user with:
```
SECURITY GATE BLOCKED — No scan tool available.

All three scan layers are unavailable:
  - gitleaks: not installed
  - semgrep: not installed
  - Docker: not available (cannot use fallback images)

To proceed, choose one:
  a. Install gitleaks:   brew install gitleaks
  b. Install semgrep:    pip install semgrep
  c. Install Docker:     brew install docker
  d. Skip with acknowledgment (type CONFIRM-SKIP)

Without any resolution, commit cannot proceed.
```

Only proceed if user explicitly types "CONFIRM-SKIP" (not "yes"/"ok"/"skip").
Record the acknowledgment in `## Security Gate Log`:
```
Security Gate: ⚠️ BYPASSED — user acknowledged risk at {timestamp}
Reason: No scan tools available (gitleaks/semgrep/Docker all missing)
```

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
| All tools unavailable + no resolution | ❌ BLOCKED — cannot execute gate |
| User CONFIRM-SKIP (written acknowledgment) | ⚠️ BYPASSED — logged with timestamp |
| Secrets found (high confidence) | ❌ BLOCKED |
| SAST errors found | ❌ BLOCKED |
| Critical/High CVEs in dependencies | ❌ BLOCKED |
| Docker fallback used + clean | ⚠️ PASS — log "Docker fallback" |
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
