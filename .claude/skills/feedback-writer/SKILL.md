---
description: Record user feedback silently to the feedback index for evolution tracking
---

# Skill: feedback-writer

## 触发条件

以下任一情况时激活：
1. 用户明确说「记下来」「记录一下」「以后每次都要」
2. `detect-feedback-signal` hook 提醒主 agent 有反馈信号需记录
3. `/close-phase` 执行时，自动处理 lessons-learned

**不触发**：用户在问问题、查看文件、正常对话时不记录。

## 执行流程

### Step 1: 提取反馈内容

从当前上下文提取：
- **反馈主体**：用户想改变/改善什么行为？（1-2句话）
- **触发场景**：什么情况下发生的？
- **分类**：process / quality / skill-gap / skill-issue
- **来源层**：产品定义层 / 开发质量层 / 发布层
- **目标层**：反馈应升级至哪一层的规则（可与来源层相同）

### Step 2: 检查重复

读取 `.agents/feedback/index.md`，检查是否已有主题相近的条目：
- 相似度高 → 更新现有条目的频次（不新建）
- 全新主题 → 新建条目

### Step 3: 生成条目文件

在 `.agents/feedback/entries/` 下创建 `FB-{NNN}-{slug}.md`：

```markdown
# FB-{NNN}: {主题标题}

**日期**: {YYYY-MM-DD}
**分类**: {类别}
**来源层**: {layer}
**目标层**: {layer}
**频次**: 1（或已有条目+1）

## 反馈内容

{用户原话或意图描述}

## 触发场景

{发生了什么操作，用户为什么提出这个反馈}

## 期望的改变

{理想情况下，应该如何做不同？}

## 关联反馈

{相同主题的其他 FB ID，如有}
```

### Step 4: 更新索引

更新 `.agents/feedback/index.md`：
- 在反馈列表中新增/更新该条目
- 更新统计摘要数字
- 若频次 ≥ 阈值，将状态改为 `candidate`

### Step 5: 轻提示用户

```
✅ 反馈已记录：{主题摘要} (FB-{NNN})
   当前频次: {N}次  |  进化阈值: {threshold}次
   {若为 candidate: 💡 已达阈值，下次 /prime 时将生成进化建议}
```


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

- 静默操作，不打断用户当前工作流
- 不修改任何 skill、gate 或命令文件
- 每次记录控制在 5 秒内完成（不做复杂分析）
