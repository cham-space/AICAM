---
description: "Verify a completed phase: compare plan vs implementation → run validation commands → produce structured report"
argument-hint: "[phase-name or plan-file-path]"
---

# Verify Phase: Implementation Audit

## Phase to Verify: $ARGUMENTS

## Mission

Systematically audit a completed implementation phase by comparing the **plan** against the **actual codebase**, running all validation commands, and producing a structured `PHASE{N}_VERIFICATION_REPORT.md` that enables `/close-phase` to archive and distill lessons.

**Core Principle**: Evidence over assumption. Every finding must be backed by a file read, command output, or diff — not guesswork.

> **Pre-requisite (Node 3-A)**: Code Review should be completed before running this command.  
> If not done, run `/requesting-code-review` first, or explicitly acknowledge and proceed.

---

## Process

### Step 1: Locate Artifacts

**Step 1a: Find the plan file**

If `$ARGUMENTS` is a file path, read it directly.
If `$ARGUMENTS` is a phase name (e.g., `phase3`), scan:
```
.agents/plans/{phase-name}*.md
.agents/plans/archive/{phase-name}*.md
```

If no plan is found, stop with:
> "Cannot verify without a plan file. Provide a path or phase name."

**Step 1b: Locate project context root**

Find the nearest `CLAUDE.md`. Its directory is `{PROJECT_ROOT}`.

**Step 1c: Check if already verified**

Look for `.agents/reports/PHASE{N}_VERIFICATION_REPORT.md`.
If found, warn: `"⚠ Verification report already exists. Proceeding will overwrite. Continue? (yes/no)"`

---

### Step 2: Parse the Plan

Read the plan file and extract:

1. **Expected deliverables** — Every file listed under "New Files to Create", "Files to Create", or "FILES TO CREATE"
2. **Validation commands** — Every command under "VALIDATION COMMANDS" or "VALIDATE:" blocks
3. **Acceptance criteria** — Every checkbox `- [ ]` item under "ACCEPTANCE CRITERIA" or "COMPLETION CHECKLIST"
4. **Testing strategy** — Test files and coverage targets
5. **Plan deviations already noted** — Any "Plan Deviations" section in the plan/summary
6. **Mandatory gates** — Unit tests, business workflow tests, and API naming consistency check (if applicable)

---

### Step 3: File Existence Audit

For each expected file from Step 2:

```
✅ EXISTS   — file found at expected path
⚠  MOVED    — not at expected path, but found elsewhere in workspace (note actual path)
❌ MISSING  — not found anywhere
```

Output a table:
```
| Expected Path | Status | Actual Path (if moved) |
|---------------|--------|------------------------|
| src/...       | ✅     | —                      |
| src/...       | ⚠      | src/other/path.ts      |
| src/...       | ❌     | —                      |
```

Count: `{X} ✅ found, {Y} ⚠ moved, {Z} ❌ missing out of {total} expected`

---

### Step 4: Run Validation Commands

Execute each validation command from the plan **in order**. For each:

```bash
# Command: {command}
# Purpose: {what the plan says it validates}
```

After running:
- **PASS** ✅ — Command exits 0, output matches expectations
- **FAIL** ❌ — Command exits non-zero or output shows errors
- **WARN** ⚠ — Command passes but with warnings

If a command fails:
1. Capture the error output
2. Load `systematic-debugging` Skill — complete Phase 1 root cause investigation before proposing any fix
3. Attempt **one** fix if the root cause is clear (e.g., missing import, typo)
4. Re-run once
5. If still failing, log it as a bug — **do not retry indefinitely**; verify-phase is a read-only audit — hand complex fixes back to the user

---

### Step 5: Acceptance Criteria Audit

**Before writing status conclusions**, load `verification-before-completion`.
Run verification commands in this step — do not rely on prior execution output.

For each acceptance criterion from the plan, determine status:
- ✅ **PASS** — verifiable from file existence + command output
- ❌ **FAIL** — missing file or failed validation command
- ⚠ **PARTIAL** — code exists but not fully functional / untested
- ⏭ **SKIP** — explicitly deferred or marked N/A in the plan

Additionally enforce gate outcomes:
- Unit tests must be evidenced by command output
- Business workflow tests must be evidenced by command output/artifacts
- If API is involved, naming mapping consistency must be evidenced

---

### Step 6: Bug Catalogue

List every bug encountered during this verification (Step 4), plus any pre-existing bugs found by reading code:

For each bug:
```
### BUG-{N}: {short title} — {severity: Critical/High/Medium/Low}

**现象**: {what was observed}
**根因**: {why it happened}
**修复**: {what was changed, or "未修复"}
**状态**: ✅ 已修复 | ❌ 未修复 | ⏭ 已知/延期
```

**Bug Fix Path**:  
If the bug catalogue is non-empty, each fix requires, before the user proceeds:  
1. Complete root cause investigation using the `systematic-debugging` Skill (Phase 1)  
2. Write a failing test that reproduces the bug first (the TDD Iron Law applies to bug fixes too)  
3. Only after the fix is complete and tests are green may you proceed to `/close-phase`  
Do not close the Phase after directly patching code without a confirmed root cause.

---

### Step 7: Generate Verification Report

Write the report to `.agents/reports/PHASE{N}_VERIFICATION_REPORT.md`:

```markdown
# Phase {N} 核验报告

> 核验时间: {YYYY-MM-DD}
> 核验范围: {phase scope from plan, N tasks}
> 核验状态: ✅ 通过 | ⚠ 有条件通过 | ❌ 未通过

---

## 一、环境与依赖核验

| 检查项 | 状态 | 说明 |
|--------|------|------|
| {dependency} | ✅/❌ | {detail} |

---

## 二、Task 任务完成情况

### 总览：{N} 个文件（{M} 计划 + {extra} 额外）

| 任务组 | 任务 | 文件数 | 状态 | 备注 |
|--------|------|--------|------|------|

### 变更/差异记录

| 计划 | 实际 | 类型 |
|------|------|------|

---

## 三、VALIDATION COMMANDS 执行结果

### Level 1: {command name}

```
{command output snippet — first 20 lines}
```

Result: ✅/❌ | {summary}

### Mandatory Gates

| Gate | Status | Evidence |
|------|--------|----------|
| Unit Tests | ✅/❌ | {command + short output} |
| Business Workflow Tests | ✅/❌ | {command/artifact path} |
| API Naming Consistency (if applicable) | ✅/❌/N/A | {mapping/check evidence} |
| TDD Compliance | ✅/❌/N/A | {Read `## TDD Log` from summary.md — verify non-exempt task count matches TDD records; flag any missing entries or EXEMPT-without-user-confirmation entries} |

---

## 四、发现的缺陷

{Bug catalogue from Step 6}

---

## 五、ACCEPTANCE CRITERIA 核验

| 验收标准 | 状态 | 说明 |
|----------|------|------|

---

## 六、AC-Test 覆盖矩阵

> 扫描来源：Spec-Lite AC 列表 × 计划文件中声明的测试文件（不做全库扫描）。

| AC ID | 验收标准 | 覆盖测试用例 | 测试文件 | 测试结果 | 状态 |
|-------|----------|------------|---------|---------|------|
| AC-1 | {标准描述} | {describe > it name} | {path/to/test.ts} | PASS/FAIL | ✅/❌ |
| AC-2 | {标准描述} | — | — | — | ⚠ 无覆盖 |

> ⚠ 无覆盖 的 AC 项视为 PARTIAL，需在修复优先级中列出。

---

## 七、修复优先级建议

| 优先级 | 编号 | 问题 | 修复工作量 |
|--------|------|------|------------|
| P0 阻塞 | | | |
| P1 高 | | | |
| P2 中 | | | |
| P3 低 | | | |
```

---

### Step 8: Present Summary

After writing the report, output a brief terminal summary:

```
## Phase {N} Verification Complete

Overall Status: ✅ PASS | ⚠ CONDITIONAL | ❌ FAIL

Files:     {X}/{total} present  ({Y} moved, {Z} missing)
Commands:  {P}/{total} passed   ({Q} failed, {R} warned)
Criteria:  {A}/{total} met      ({B} partial, {C} failed)
Bugs:      {blocking} blocking, {non_blocking} non-blocking
Mandatory Gates: Unit={PASS/FAIL}, Workflow={PASS/FAIL}, API Naming={PASS/FAIL/N/A}, TDD={PASS/FAIL/N/A}

Report written to: .agents/reports/PHASE{N}_VERIFICATION_REPORT.md

Next step:
- If Code Review not yet done → **strongly recommended** to run it first:  
  `BASE_SHA=$(git rev-parse HEAD~1)` + `HEAD_SHA=$(git rev-parse HEAD)`  
  Dispatch `superpowers:code-reviewer` subagent using the `code-reviewer.md` template; fix Critical/Important issues before archiving  
- Run `/close-phase {phase-name}` to archive and distill to CLAUDE.md
```

---

## Safety Rules

1. **Read before writing** — always read a file before concluding it exists and is correct
2. **Do not auto-fix unless trivial** — fixing bugs requires judgment; prefer logging over blind patching
3. **Never delete files** — verification is read-only except for the report file written in Step 7
4. **Command timeouts** — if a build/test command runs > 5 minutes without output, stop it and mark as TIMEOUT
5. **Scope discipline** — only verify what the plan specifies; do not audit unrelated code
