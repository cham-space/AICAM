---
name: destructive-op-gate
description: Destructive operation gate — scan and block high-risk SQL/file operations
severity: blocking
applies_to: [execute, hotfix]
---

# Destructive Operation Gate: High-Risk Command Detection

## Rule

Before executing any task, scan all commands and SQL for destructive patterns.
On detection → **STOP immediately** and present to user before proceeding.

## Detection Patterns

| Risk Level | Pattern | Impact |
|-----------|---------|--------|
| 🔴 CRITICAL | `DROP TABLE` / `DROP DATABASE` | Deletes entire table/database |
| 🔴 CRITICAL | `TRUNCATE TABLE` | Wipes all rows, irreversible |
| 🔴 CRITICAL | `rm -rf` / batch file deletion | Irreversible file deletion |
| 🔴 CRITICAL | `git reset --hard` | Destroys uncommitted work |
| 🟠 HIGH | `DELETE` without WHERE clause | Deletes all rows in table |
| 🟠 HIGH | `DROP COLUMN` / `ALTER TABLE ... DROP` | Column removal, data loss |
| 🟠 HIGH | Column type change | May truncate data |
| 🟠 HIGH | `git push --force` to main/master | Overwrites remote history |
| 🟡 MEDIUM | `ALTER TABLE ... RENAME COLUMN` | May break application code |

## Confirmation Protocol

On detection, present:
```
⚠ High-risk operation detected: `{command}`
Operation type: {TRUNCATE / DROP / unconditional DELETE / etc.}
Impact: {table/file path} — {estimated row count or description}
Is a backup in place? Please reply "confirm" to proceed, or explain why to skip.
```

**No auto-advance**: Must wait for explicit user "confirm".

## Migration Script Rules

- `TRUNCATE` and `DROP TABLE` are **forbidden** in migration scripts
- Data cleanup must use separate `data-fix` scripts outside the migration version sequence
- Each migration Task must declare: DESTRUCTIVE (YES/NO), ROLLBACK command, BACKUP_REQUIRED (YES/NO)

## Known Limitations (v1.2.1)

Current implementation uses static pattern matching (regex).
- May false-positive on commented-out SQL
- May miss dynamically constructed SQL strings
- v1.4.0 target: upgrade to SQL AST analysis
