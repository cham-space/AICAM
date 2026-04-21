---
description: Execute an implementation plan
argument-hint: [path-to-plan]
---

# Execute: Implement from Plan

## Plan to Execute

Read plan file: `$ARGUMENTS`

## Execution Instructions

### 1. Read and Understand

- Read the corresponding Spec-Lite: `.agents/specs/{phase-name}.spec.md`
  - If Spec-Lite is missing → **STOP** and warn: `"⚠ Spec-Lite not found. Run /plan-feature first."`
- Read the ENTIRE plan carefully
- Understand all tasks and their dependencies
- Note the validation commands to run
- Review the testing strategy

### ⚠ Destructive Operation Gate（高危操作门禁）

Before executing ANY task, scan all commands and SQL in that task.
If any of the following patterns are detected, **STOP immediately** and present to the user before proceeding:

| 高危操作 | 示例 |
|---------|------|
| `TRUNCATE TABLE` | 清空整表，不可恢复 |
| `DROP TABLE` / `DROP DATABASE` | 删除表/库结构与数据 |
| `DROP COLUMN` / `ALTER TABLE ... DROP` | 删除列，数据丢失 |
| `DELETE` 无 WHERE 子句 | 删除全表行数据 |
| 修改列类型（可能截断数据） | `ALTER TABLE ... MODIFY COLUMN` |
| `rm -rf` / 批量文件删除 | 不可恢复文件删除 |

**停止后向用户展示**：
```
⚠ 检测到高危操作：`{具体命令}`
操作类型：{TRUNCATE / DROP / 无条件DELETE 等}
影响范围：{表名/文件路径} — {预估影响行数或说明}
是否已有备份？请确认后回复「确认执行」，或说明跳过原因。
```

**不允许自动推进**：必须等待用户明确的「确认执行」回复。

---

### TDD Gate (Node 2-A)

Before implementing each task:
1. Write the failing test first (unit or integration, as appropriate)
2. Confirm the test fails for the **right reason** (feature missing — not a typo, not testing existing behavior)
3. Implement **minimal** code until the test passes — do not add features beyond what the test requires
4. **REFACTOR**: After green, clean up duplication/names/helpers while keeping all tests green — do not add new behavior in this phase

**Iron Law**: If you discover implementation code was written before the test → **delete it**. Do not keep it as "reference". Start over from a failing test.  
**Applies to bug fixes too**: Before fixing any bug, you must first write a failing test that reproduces it.

**TDD 豁免申请（强制暂停）**：以下情况可申请豁免，但 Agent 不得自行决定，必须暂停并向用户展示：

```
⚠️ TDD 豁免申请 — Task {N}: {task-name}
申请理由: {reason}
豁免类型: 配置文件 / 迁移脚本 / 纯样式 / 注解更新 / 依赖升级 / 其他:{detail}
继续前请确认（y/n）:
```

用户回复 `n` → 必须按 TDD 流程重新执行。  

**可申请豁免的情况**：配置文件变更、数据库迁移脚本、纯样式/CSS 变更、注解/文档注释更新、依赖版本升级（无业务逻辑变更）。

**不可豁免（强制 TDD）**：
- 跨边界集成层（IPC 命令、REST endpoint、事件发布/订阅、消息队列消费者）
- 前端/UI 组件中含有条件逻辑、状态管理、数据转换的部分
- 任何序列化/反序列化逻辑
- 错误处理路径

> 申请上述类型豁免时，必须同时说明"**替代验证方式**"。若答案为"运行时手动看"，则驳回豁免申请，必须补写测试。

### 2. Execute Tasks in Order

For EACH task in "Step by Step Tasks":

#### a. Navigate to the task
- Identify the file and action required
- Read existing related files if modifying

#### b. Implement the task
- Follow the detailed specifications exactly
- Maintain consistency with existing code patterns
- Include proper type hints and documentation
- Add structured logging where appropriate

#### c. Verify as you go
- After each file change, check syntax
- Ensure imports are correct
- Verify types are properly defined

#### d. TDD 声明（强制）

Every non-exempt task must append the following record to `.agents/plans/{phase-name}.summary.md` under `## TDD Log`:

```
- Task {N} {task-name}:
  - Test: {test_file}#{test_name}
  - Red:  {test command} → FAILED ✅
  - Green: {test command} → PASSED ✅
```

Exempt tasks (user-confirmed) must record:

```
- Task {N} {task-name}: EXEMPT — {user-confirmed reason}
```

> If `## TDD Log` section does not exist in the summary file, create it.

### 3. Implement Testing Strategy

After completing implementation tasks:

- Create all test files specified in the plan
- Implement all test cases mentioned
- Follow the testing approach outlined
- Ensure tests cover edge cases

### 4. Run Validation Commands

Execute ALL validation commands from the plan in order:

```bash
# Run each command exactly as specified in plan
```

If any command fails:
- Capture the error output
- Load `systematic-debugging` Skill — complete Phase 1 (root cause investigation) **before** proposing any fix
- **Do not propose any fix before identifying the root cause**
- Attempt **one** fix based on the identified root cause
- Re-run the command
- If still failing, repeat: re-investigate → one fix → re-run (max 3 attempts total)
- **3 failed attempts → STOP**: Question the current architecture, present all attempted paths to the user, and wait for their decision before continuing — do not attempt a 4th fix automatically
- If a command passes, continue to next

**Hard gate (cannot skip):**
- Unit tests must pass
- Business workflow tests must pass (UI E2E or API workflow tests)
- If API was touched, contract/naming validation from the plan must pass

### 4.5 Smoke Test（强制，不可跳过）

在所有验证命令通过后，执行计划文件 `## Smoke Test Checklist` 中的每一条：

1. 使用计划中声明的启动命令启动应用/服务
2. 逐条验证 Checklist 条目，记录 ✅ PASS / ❌ FAIL
3. 任何 ❌ → 进入 bug 修复流程（systematic-debugging Skill），修复后重新执行完整 Smoke Test
4. **全部 ✅ 才能继续生成 Summary**

若计划文件缺少 `## Smoke Test Checklist` → **STOP**，提示：
> ⚠ Plan 缺少 Smoke Test Checklist。请补充后重新执行，或明确确认此 Phase 无需运行时验证（需用户明确书面确认）。

Smoke Test 结果写入 `.agents/plans/{phase-name}.summary.md` 的 `## Smoke Test Log` 节：
```
## Smoke Test Log
- [ ] 启动无崩溃 ✅/❌
- [ ] {功能路径 A}：{操作} → {预期结果} ✅/❌
- [ ] {功能路径 B}：{操作} → {预期结果} ✅/❌
```

### 5. Final Verification

Before completing, load the `verification-before-completion` skill.
Run all verification commands fresh — evidence before assertions.

**Gate**: "NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE."

- ✅ All tasks from plan completed
- ✅ All tests created and passing
- ✅ All validation commands pass
- ✅ Unit + Business workflow gates both passed
- ✅ Code follows project conventions
- ✅ Documentation added/updated as needed

## 输出报告

提供摘要：

### 已完成任务
- 已完成的任务列表
- 已创建的文件（含路径）
- 已修改的文件（含路径）

### 新增测试

| 类型 | 测试文件 | 测试用例名 | 覆盖的 AC | 结果 |
|------|----------|------------|----------|------|
| Unit | {path/to/test.ts} | {test name} | AC-{N} | ✅/❌ |
| Workflow | {path/to/e2e.ts} | {test name} | AC-{N} | ✅/❌ |

> 扫描来源：计划文件中声明的测试文件 + 本次新建/修改的测试文件。AC 编号对应 Spec-Lite 的验收标准。

### 验证结果
```bash
# 每个验证命令的输出
```

### 强制门禁状态
- 单元测试: PASS/FAIL
- 业务功能测试: PASS/FAIL
- API 合约/命名（如适用）: PASS/FAIL

### 准备提交
- 确认所有任务已完成
- 确认所有验证通过
- 准备执行 `/commit` 命令

### Phase 摘要（自动生成）

所有任务和验证通过后，生成 Phase 摘要文件供 `/close-phase` 归档使用：

**保存路径**: `.agents/plans/{plan-name}.summary.md`

**格式**:
```markdown
# Phase 摘要: {功能名称}

**完成日期**: {date}
**计划文件**: {path to the plan that was executed}

## 范围
{一句话描述本 Phase 交付内容}

## 产出
- **新文件**: {count}（{列出关键文件}）
- **修改文件**: {count}
- **新增测试**: {count} 个测试，{count} 个测试文件
- **数据库迁移**: {count，如有}

## Test Cases

### Unit Tests
| 测试文件 | 测试用例名 | 覆盖 AC | 结果 |
|----------|------------|---------|------|
| {path/to/test.ts} | {describe > it name} | AC-{N} | ✅/❌ |

### Business Workflow Tests
| 测试文件 | 测试用例名 | 覆盖 AC | 结果 |
|----------|------------|---------|------|
| {path/to/e2e.ts} | {scenario name} | AC-{N} | ✅/❌ |

> 用例名直接提取自测试文件的 describe/it/test 函数名；AC 编号对应 `.agents/specs/{phase}.spec.md` 中的验收标准编号。

## 计划偏差
{列出计划与实际实现的差异：
- 文件重命名、新增或跳过
- 实施过程中的架构变更
- 任务重排或合并}

## 发现并修复的 Bug
{列出实施过程中发现的 Bug：
- BUG-N: {描述} → {修复方案}}

## 未解决问题
{延期到后续 Phase 的已知问题}

## 经验教训
{供后续 Phase 参考的流程或技术洞察}

## Smoke Test Log
- [ ] {条目 1}：{操作} → {预期结果} ✅/❌
- [ ] {条目 2}：{操作} → {预期结果} ✅/❌
```

然后输出：

> Phase execution complete. ✅

## ⛔ 强制下一步（不可跳过）

| 步骤 | 操作 | 说明 |
|------|------|------|
| 1 | 🆕 **关闭当前会话，开新会话** | ⚠️ 避免实现上下文污染 code-review 判断，必须在全新 context window 中执行 |
| 2 | `/code-review {plan-file-path}` | Fix all Critical issues；review Important issues |
| 3 | `/verify-phase {plan-file-path}` | 合规审计，需要 code-review 先通过 |
| 4 | `/close-phase` → `/commit` | 归档并提交 |

> **Hard gate**: `/verify-phase` 会检查 code-review 是否已完成，跳过将触发警告并要求确认。

## Notes

- If you encounter issues not addressed in the plan, document them
- If you need to deviate from the plan, explain why
- If tests fail, fix implementation until they pass
- Don't skip validation steps
