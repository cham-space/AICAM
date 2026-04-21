---
description: "Multi-language code review: dispatch isolated sub-agent reviewer → produce structured report → gate /verify-phase"
argument-hint: "[path-to-plan or phase-name]"
---

# Code Review

## Target: $ARGUMENTS

> **Context Isolation Rule**: This reviewer receives only artifact context — NOT the planning session history. This ensures objective review.
>
> **Output File**: `.agents/reviews/{phase-name}-code-review.md`  
> ⚠️ This file is **evidence-only archive**. Never auto-load into context.  
> `/verify-phase` checks existence only. `/close-phase` reads `## Summary` section only (≤10 lines).

---

## Step 1: Resolve Artifacts

**1a. Locate plan file**

If `$ARGUMENTS` is a file path → read it directly.  
If `$ARGUMENTS` is a phase name → scan:
```
.agents/plans/{phase-name}*.md
.agents/plans/{phase-name}*.summary.md
```
(exclude `*.summary.md` — prefer the original plan file; only fall back to summary if no plan file found)

**If `$ARGUMENTS` is empty:**  
Scan `.agents/plans/` and list all `*.md` files sorted by last-modified time (newest first).  
Present the list to the user and ask:
```
Detected plan files (sorted by modification time):
  1. .agents/plans/phase1-xxx.md       ← recommended (most recently modified)
  2. .agents/plans/phase1-xxx.summary.md
  3. .agents/plans/phase2-xxx.md
  ...

Please select a file number, or enter a path directly (leave empty to default to 1):
```
Wait for user confirmation before proceeding. Use the selected file as the plan.  
If `.agents/plans/` is empty → abort: `❌ No plan files found. Run /plan-feature first.`

**After resolving the plan file (any path above), confirm with user before continuing:**
```
📋 Code review will be performed on the following plan file:
   {resolved-plan-path}

Confirm to proceed? (y/n, leave empty for y)
```
Wait for confirmation. If user says n → abort and ask them to specify the correct plan path.

**1b. Determine review scope (three-layer resolution, in priority order)**

**Layer 1 — Plan file declared scope (authoritative)**  
Extract file lists from the plan file under these headings (in order of priority):
- `FILES TO CREATE` / `New Files to Create`
- `FILES TO MODIFY` / `Files to Modify`
- `Step by Step Tasks` → scan each task for explicit file paths

This is the **primary scope**. Only files declared in the plan are subject to full review.

**Layer 2 — Git working tree delta (supplements Layer 1)**  
```bash
# Uncommitted changes (staged + unstaged) — covers /execute not yet committed
git diff --name-only HEAD
git diff --name-only --cached

# Also check committed delta since last phase (if commits exist)
BASE_SHA=$(git rev-parse HEAD~1 2>/dev/null)
if [ $? -eq 0 ]; then
  git diff --name-only $BASE_SHA HEAD
fi
```

Cross-reference with Layer 1: files appearing in **both** plan scope and git delta are the confirmed review targets.  
Files in git delta but NOT in plan → flag as **scope deviation** (not reviewed in detail, just noted).

**Layer 3 — Fallback (no git history)**  
If git is unavailable or this is the initial commit, use Layer 1 plan scope exclusively.

**Final scope = Layer 1 ∩ (Layer 2 ∪ Layer 3)**  
> Scope boundary: Do NOT review files outside the plan's declared scope unless they are direct dependencies of a changed file (e.g., a shared module modified by this phase).

**1c. Detect languages**

Scan changed files by extension. Build a language map:

| Extension | Language |
|-----------|----------|
| `.rs` | Rust |
| `.ts`, `.tsx` | TypeScript/React |
| `.js`, `.jsx` | JavaScript/React |
| `.py` | Python |
| `.java` | Java |
| `.go` | Go |
| `.swift` | Swift |
| `.kt` | Kotlin |
| `.cs` | C# |
| `.md` | Markdown/Docs |
| `.sql` | SQL/Migration |
| Other | General |

---

## Step 2: Build Reviewer Context

Construct the following payload for the sub-agent reviewer:

```
PHASE_NAME: {phase name from plan}
PLAN_FILE: {path}
SPEC_FILE: {.agents/specs/{phase-name}.spec.md if exists}
REVIEW_SCOPE: {final file list from Layer 1 ∩ Layer 2 — these files only}
SCOPE_DEVIATIONS: {files in git delta but NOT in plan — list only, do not review}
LANGUAGES_DETECTED: {language map}
ACCEPTANCE_CRITERIA: {extracted from Spec-Lite}
API_NAMING_MAP: {extracted from plan if present}
KNOWN_TRADEOFFS: {extracted from plan ## NOTES > Design Decisions — these are intentional, do not flag as issues}
DEFERRED_ITEMS: {extracted from plan "Deferred to Future Phases" — these are intentionally out of scope, do not flag as missing}
```

---

## Step 3: Dispatch Sub-Agent Reviewer

Dispatch an **isolated sub-agent** with the following instructions. The reviewer must NOT access the current conversation history.

---

### Reviewer Instructions (Sub-Agent)

You are an expert code reviewer. Review the implementation described below with fresh eyes.

**Your mission**: Identify issues across 6 universal dimensions + language-specific checks. Classify every finding. Produce a structured report.

#### Universal Review Dimensions (All Languages)

**D1 — Design Compliance**
- Does the implementation match the plan scope? Any over-engineering or scope creep?
- Are all acceptance criteria satisfied?
- Does the code follow established project conventions (naming, patterns, file structure)?

**D2 — Security (OWASP Top 10 relevant)**
- Injection risks (SQL, command, path traversal)
- Hardcoded credentials or secrets
- Insecure direct object references
- Sensitive data exposure (logging, error messages leaking internals)
- Unsafe deserialization or input validation gaps

**D3 — Error Handling**
- Are all error paths handled explicitly?
- Are errors propagated correctly vs. silently swallowed?
- Do error messages expose too much internal detail?
- Are panics/exceptions at correct boundaries?

**D4 — Test Adequacy**
- Core happy-path covered?
- At least one failure/error path covered per function?
- Edge cases: nulls, empty collections, zero values, max values?
- Are tests asserting behavior, not implementation details?

**D5 — Performance & Resources**
- Unnecessary allocations in hot paths?
- N+1 query patterns in database access?
- Lock held too long (mutex/semaphore granularity)?
- Potential resource leaks (file handles, connections, streams)?

**D6 — API & Naming Consistency**
- IPC/API field names match Spec-Lite naming map?
- Frontend parameter names match backend binding aliases?
- Response structure matches declared contract?

#### Language-Specific Checks

Apply the relevant section(s) based on `LANGUAGES_DETECTED`:

**Rust**
- `unsafe` blocks: is the safety invariant documented in a comment?
- `unwrap()` / `expect()` in non-test code: is panic acceptable here?
- `Send + Sync` impls: is the manual impl justified and safe?
- Mutex lock ordering: consistent across codebase to prevent deadlock?
- Lifetime annotations: are they minimal and correct?
- `Arc<Mutex<T>>` vs `RwLock<T>`: is read-heavy data using RwLock?

**TypeScript / JavaScript**
- `any` type usage: is it necessary or should it be typed?
- `Promise` chains: are all rejection paths handled?
- Null/undefined checks at runtime boundaries (API responses, DOM events)?
- `useEffect` dependencies: are arrays complete and correct?
- Zustand selectors: are they atomic (no broad `s => s` selectors)?

**Python**
- Type annotations present on public functions?
- f-string with untrusted input (potential log injection)?
- Mutable default arguments (`def f(x=[])`)?
- Bare `except:` catching too broadly?
- Thread safety for shared state?

**Java**
- Thread safety: are shared mutable fields synchronized or volatile?
- `Optional` used instead of returning null?
- Resources (streams, connections) closed in try-with-resources?
- `@Transactional` boundaries correct?

**Go**
- Goroutine leak: are goroutines always terminated?
- Context propagated through all async calls?
- Error wrapping with `%w` for stacktrace preservation?
- Mutex held across goroutine boundaries?

**SQL / Migrations**
- All destructive operations (DROP, TRUNCATE, DELETE without WHERE) flagged?
- Indexes added for new foreign keys and query filter columns?
- Migration is idempotent or has rollback?

---

## Step 4: Compile Structured Report

After review, write `.agents/reviews/{phase-name}-code-review.md`:

```markdown
# Code Review: {phase-name}

**Date**: {date}
**Reviewer**: AI Sub-Agent (isolated context)
**Plan**: {plan-file-path}
**Git Delta**: {BASE_SHA}..{HEAD_SHA}
**Files Reviewed**: {count} ({language breakdown})

---

## 🚨 Critical Issues
> Must fix before /verify-phase. These block the gate.

<!-- If none: "None found." -->
- **[C1]** `{file}:{line}` — {dimension code: D1-D6 or Lang} — {description}
  - Risk: {why this matters}
  - Fix: {concrete suggestion}

## ⚠️ Important Issues
> Strongly recommended to fix before continuing.

<!-- If none: "None found." -->
- **[I1]** `{file}:{line}` — {dimension} — {description}
  - Risk: {why this matters}
  - Fix: {concrete suggestion}

## 💡 Minor / Suggestions
> Can be deferred to a later Phase.

<!-- If none: "None found." -->
- **[M1]** `{file}` — {description}

## ✅ Summary

| Metric | Value |
|--------|-------|
| Files reviewed | {N} |
| Languages | {list} |
| Critical issues | {N} |
| Important issues | {N} |
| Minor suggestions | {N} |
| Overall health | 🟢 Good / 🟡 Needs attention / 🔴 Blocked |

**Gate result**: ⛔ BLOCKED — fix Critical issues before /verify-phase  
OR  
**Gate result**: ✅ PASSED — proceed to /verify-phase
```

---

## Step 5: Evaluate and Report Gate Result

After receiving the sub-agent report:

1. Read `.agents/reviews/{phase-name}-code-review.md`
2. Extract Critical issue count

**If Critical count > 0**:
```
⛔ CODE REVIEW BLOCKED
{N} Critical issue(s) found. Fix all before running /verify-phase.
See: .agents/reviews/{phase-name}-code-review.md
```
Present each Critical issue inline (file, line, description, fix suggestion).  
Fix Critical issues now (with user confirmation for destructive changes).  
Re-run relevant tests after fixing.

**If Critical count = 0**:
```
✅ CODE REVIEW PASSED
Important: {N} | Minor: {N}
See full report: .agents/reviews/{phase-name}-code-review.md
Next step: /verify-phase {plan-file-path}
```

---

## Notes

- This command operates on a **sub-agent** with isolated context — planning history is intentionally excluded
- The report file is for archiving evidence, not for loading into future AI context sessions
- `/close-phase` will extract only the `## Summary` table (≤10 lines) for lesson distillation
- If `$ARGUMENTS` is omitted, scan `.agents/plans/` for the most recent `*.summary.md` automatically
