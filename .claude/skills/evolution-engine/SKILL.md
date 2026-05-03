---
description: Scan feedback index and generate evolution proposals when thresholds are met
---

# Skill: evolution-engine

## 触发条件

以下任一情况激活：
1. `/prime` 命令执行时（SessionStart 扫描）
2. 用户手动调用：「扫描反馈」「检查进化」

## 执行流程

### Step 1: 读取规则和反馈

- 读取 `.claude/EVOLUTION.md`（进化阈值规则）
- 读取 `.agents/feedback/index.md`（所有反馈及频次）

### Step 2: 统计分析

- 统计各类别、各主题的反馈频次
- 识别「毕业候选」（达到阈值的条目）
- 识别「低评分 skill」（skill-issue 类达阈值）
- 识别「未覆盖模式」（skill-gap 类达阈值）

### Step 3: 输出扫描摘要（后台静默）

若**无**毕业候选：
```
[进化层] 已扫描 {N} 条反馈，当前无毕业候选。最近一条: {主题} ({N}次/{threshold}次)
```
（此消息以静默方式呈现，不打断对话流）

若**有**毕业候选：
```
💡 进化建议就绪（{N} 条候选）
   运行 /prime 后可查看，或现在查看？(y/n)
```

### Step 4: 生成进化建议

对每个毕业候选，读取对应的 `entries/FB-*.md` 文件，生成建议：

```markdown
═══════════════════════════════════════
📈 进化建议 #{N} / {总条数}

建议类型: 规则升级 / skill优化 / 新建skill
来源反馈: {FB-ID列表}
频次统计: {N} 次相同主题（阈值: {threshold}）

反馈主题: {主题描述}

建议内容:
  文件: {具体文件路径}
  变更: {在哪里增加什么规则，1-3行}
  
影响范围: 影响 {skill/gate/命令} 的 {具体行为}
风险评估: Low — 新增规则，不改变现有行为

执行此建议？(y/n/skip)
═══════════════════════════════════════
```

### Step 5: 处理用户决定

- `y` → 执行变更，写入 EVOLUTION-LOG.md，更新 feedback/index.md 状态为 `evolved`
- `n` → 写入 EVOLUTION-LOG.md（状态: dismissed），更新 index.md 状态
- `skip` → 本次跳过，下次 /prime 仍会出现

### Step 6: 单次上限

每次 /prime 最多显示 3 条建议，优先展示频次最高的。


## 语言与输出规范

- **交互语言**：检测用户消息使用语言，以相同语言回复（中文用户 → 全程中文交互；英文用户 → 英文交互）
- **持久化文档**（写入文件的内容）采用 **zh/en 双语**：
  - 标题行：`## 配色系统 / Color System`
  - 表格表头：`| 角色 / Role | 说明 / Description |`
  - 描述段落：中文正文 + 英文括号辅助 `（English clarification）`
  - 代码、路径、命令：保持英文，不翻译
- **状态/提示消息**（如 ✅ ⚠️ 前缀行）：使用检测到的用户语言，无需双语

> AICAM 整体文档（CLAUDE.md / WORKFLOW.md / README）为三语版本（zh/en/zh-tw）。  
> 新 Skill 产出的 .md 文档遵循 **zh/en 双语**规范；README 同步由 Phase F-2a/b/c 完成。

## 约束

- 扫描只读，不主动修改任何文件
- 建议执行前必须用户明确输入 y
- 每次 /prime 的后台扫描不超过 3 秒
- 如 .agents/feedback/ 目录不存在，静默跳过（不报错）
