---
description: "Close a completed phase: extract lessons → update CLAUDE.md → archive details"
argument-hint: "[phase-name or auto-detect]"
---

# Close Phase: Archive & Distill

## Phase to Close: $ARGUMENTS

## Mission

Close a completed implementation phase by **extracting key decisions, bugs, and lessons into CLAUDE.md**, then archiving detailed artifacts. This ensures future phases have full traceability without context bloat.

**Core Principle**: Compress, don't delete. Every Phase's hard-won knowledge must survive in CLAUDE.md. Detailed documents move to `archive/` for on-demand access.

---

## Process

### Step 0: Pre-condition Check (refuse to close if not met)

Before executing any archiving operations, verify each condition:

| Condition | How to Check | If Not Met |
|------|---------|---------|
| Verification Report exists with status ✅ or ⚠ | Read the status line in `.agents/reports/PHASE{N}_VERIFICATION_REPORT.md` | STOP |
| Smoke Test Log all ✅ (no ❌, no ⏸️) | Read `## Smoke Test Log` section in `.agents/plans/{phase}.summary.md` | STOP: list ❌/⏸️ items, require fixes before re-submitting |
| No ⏸️ unclosed Gate items | Scan Mandatory Gates table in Verification Report | STOP: list all ⏸️ items |
| All P0 bugs fixed | Read Verification Report Section VII (Fix Priorities), check P0 Blocking rows | STOP: list unfixed P0 items |

If all conditions pass, output: `✅ Pre-conditions met, proceeding to close Phase.`  
If any condition fails, output: `❌ Phase does not meet close conditions: {list of unmet items}` and terminate — do not execute subsequent steps.

---

### Step 1: Detect Completed Phase Artifacts

Scan workspace for phase-related documents using dynamic detection:

**Step 1a: Locate project context root**

Find the nearest `CLAUDE.md` in the workspace. The directory containing it is `{PROJECT_ROOT}`.
If no `CLAUDE.md` exists, use the workspace root.

**Phase number derivation** (needed for archive file naming `PHASE{N}_...`):
1. Extract from plan filename prefix: `phase{N}-` → use `N`
2. If no numeric prefix, read plan content for a `# Phase N` or `Phase N:` declaration
3. If still undetermined, ask the user: `"What phase number is this? (e.g., 1, 2, 3)"`

**Step 1b: Scan these locations**

```
Locations to check:
  .agents/plans/*.md              — Execution plans, summaries, specs
  .agents/reviews/*.md            — Code review reports
  {PROJECT_ROOT}/*REPORT*.md      — Verification reports
  {PROJECT_ROOT}/*PLAN*.md        — Planning documents (exclude PRD.md)
  {PROJECT_ROOT}/doc/             — Additional documentation
  {WORKSPACE_ROOT}/*REPORT*.md    — Root-level reports (if different from PROJECT_ROOT)
```

For each file found, determine:
- **Phase association**: Which phase does it belong to? (from filename or content)
- **Completion status**: Is the phase fully done? (look for ✅/completed markers)
- **Already archived?**: Is there a matching entry in CLAUDE.md's "Migration Journal" section?

**Output a checklist** of what was found:
```
Detected artifacts for Phase X:
  [plan]   .agents/plans/{phase-name}.md ({N} lines)
  [report] .agents/reports/PHASE{N}_VERIFICATION_REPORT.md ({N} lines)
  [dupe]   {PROJECT_ROOT}/doc/{phase-name}-report.md ({N} lines, duplicate)
  
Already in CLAUDE.md migration journal: No
```

If no unarchived artifacts are found, stop with:
> "No unarchived phase artifacts detected. Nothing to close."

### Step 2: Extract Key Information

From each artifact, extract ONLY what future phases need to know:

**From execution plans (.agents/plans/):**
- Scope summary (1 sentence)
- Total file/test count
- Plan deviations (actual vs planned — renamed files, extra files, skipped tasks)

**From verification reports:**
- Bug list with root cause and fix (1 line each)
- Acceptance criteria results (pass/fail summary)
- Unresolved issues or known limitations

**From both:**
- Lessons learned (process improvements, template gaps, tooling issues)
- Architecture decisions made during implementation (not in original ADRs)

### Step 3: Generate Migration Journal Entry

Format the extracted information as a concise journal entry:

```markdown
### Phase N: {phase-name} ✅ ({date range})

**Scope**: {1-sentence scope description}
**Output**: {X source files, Y test files, Z migration scripts — key numbers only}

**Plan Deviations**:
- {deviation 1: what changed and why}
- {deviation 2}

**Bugs Found & Fixed**:
- {BUG-ID}: {1-line description} → {1-line fix}

**Unresolved Issues**:
- {issue description, if any}

**Lessons**:
- {lesson that affects future phases}
```

**Size target**: Each Phase entry should be 15-30 lines. If it exceeds 40 lines, you're including too much detail.

### Step 4: Present for User Review

**Before making any changes**, display:

1. The journal entry that will be appended to CLAUDE.md
2. The list of files that will be moved to archive
3. Any duplicate files that will be deleted

**Wait for user confirmation before proceeding.**

### Step 5: Update CLAUDE.md

Check if CLAUDE.md has a "Migration Journal" section:
- If **yes**: Append the new Phase entry at the end of that section
- If **no**: Create the section before the last `---` separator (or at the end)

The section header format:
```markdown
## Migration Journal

> Automatically distilled by `/close-phase` after each Phase. Detailed reports in `archive/`.

### Phase 1: ...
### Phase 2: ...
```

### Step 6: Archive Detailed Files

Create archive directory if needed, then move files detected in Step 1:

```bash
# Create archive directories
mkdir -p {PROJECT_ROOT}/archive
mkdir -p .agents/plans/archive

# Detect git repo (once)
IS_GIT_REPO=$(git rev-parse --is-inside-work-tree 2>/dev/null)
MOVE="mv"
if [ "$IS_GIT_REPO" = "true" ]; then MOVE="git mv"; fi

# Move completed phase reports
$MOVE .agents/reports/PHASE{N}_VERIFICATION_REPORT.md {PROJECT_ROOT}/archive/
$MOVE .agents/reviews/phase{n}-*.md {PROJECT_ROOT}/archive/
$MOVE {PROJECT_ROOT}/doc/phase{n}-*.md {PROJECT_ROOT}/archive/

# Move completed execution plans
$MOVE .agents/plans/phase{n}-*.md .agents/plans/archive/
```

**Do NOT archive:**
- `CLAUDE.md` (active context — the single source of truth)
- `PRD.md` (requirement reference)
- Any file referenced in CLAUDE.md's "Reference Documents" table as an active dependency
- Any file for an incomplete/in-progress phase

### Step 7: Check & Update Reference Files

After archiving, determine whether this phase changed any shared reference material:

**Step 7a: Detect impacted reference domains**

Scan the phase's execution plan and verification report for:
- New or modified API endpoints / request-response schemas → impacts `api.md`
- New or modified UI components / props / design tokens → impacts `components.md`
- Other `.claude/reference/*.md` files explicitly mentioned in the plan

**Step 7b: Report findings and prompt**

Output a reference status block:
```
Reference Files Check:
  api.md         — [CHANGED / unchanged]  {reason, e.g. "3 new endpoints added"}
  components.md  — [CHANGED / unchanged]  {reason}
```

If any file is marked CHANGED:
> ⚠ Reference file(s) may be stale. Please update `.claude/reference/{file}` now, or confirm it is already accurate.

**Wait for user confirmation** before marking as updated.

If no changes are detected, output:
> ✅ Reference files unchanged. No update needed.

---

### Step 7.5: Update TEST_DASHBOARD.md

After archiving, update `.agents/reports/TEST_DASHBOARD.md` (create if not exists):

1. Append/update the current Phase's row in the "Phase Coverage Matrix" and "Cross-Phase Trends" tables
2. Fill in this Phase's detailed block:
   - Gate summary (read from Verification Report Mandatory Gates table)
   - Unit test details (read from summary.md Test Cases)
   - Smoke Test details (read from summary.md Smoke Test Log, including each action → expected → result)
   - Business workflow test details (read from summary.md Business Workflow Tests, including Mock strategy)
3. TEST_DASHBOARD.md is **NOT added to CLAUDE.md context loading** — for human reference only

---

### Step 8: Deduplicate Reference & Skills (One-time)

**Only execute this step if `.agents/reference/` or `.agents/skills/` directories exist. If neither exists, skip to Step 9.**

Check for duplicate directories between `.agents/` and `.claude/`:

```
.agents/reference/ vs .claude/reference/  — keep .claude/, remove .agents/
.agents/skills/    vs .claude/skills/     — keep .claude/, remove .agents/
```

Only deduplicate if content is genuinely overlapping (same filenames). If `.agents/` has unique content not in `.claude/`, merge rather than delete.

### Step 9: Clean Up Root-Level Stale Docs

Check root-level and `{PROJECT_ROOT}` markdown files for staleness:

**Detection rules** (apply to each `.md` file NOT already in archive):
1. **Superseded**: File has a newer version (e.g., `PLAN.md` superseded by `PLAN_FINAL.md`) → archive the older one
2. **Covered by CLAUDE.md**: File describes architecture/structure that CLAUDE.md already documents → archive
3. **Belongs to completed phase**: File name or content references only completed phases → archive

**Always keep**: `CLAUDE.md`, `PRD.md`, `README.md`, active config files

---

## Output Report

```markdown
## Phase Close Summary

### Archived
- {list of files moved to archive/}

### Updated
- CLAUDE.md — Added Phase N migration journal entry ({line count} lines)

### Reference
- `api.md` — {updated N endpoints | no change}
- `components.md` — {updated N components | no change}

### Deduplicated
- {list of removed duplicates, if any}

### Context Size
- Before: {X} KB markdown content
- After:  {Y} KB markdown content
- Saved:  {Z} KB ({percent}%)

### Next Steps
- Run `/commit` to create an atomic commit for this phase
- Ready to run `/plan-feature` for Phase {N+1}
```

---

## Safety Rules

- **Never delete files** — always move to `archive/`
- **Never auto-archive without user review** of the journal entry
- **Never archive active/in-progress phase** artifacts
- **Preserve git history** — auto-detects git repo and uses `git mv` when available, falls back to `mv`
