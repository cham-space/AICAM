---
description: Standardized release process — version management, build, changelog, GitHub Release
---

# Skill: release-builder

## 触发条件

以下任一情况激活：
- 用户明确说「发布」「打版本」「做 release」
- 所有开发 Phase 已 close，准备对外发布

**前置条件**:
1. 所有开发 Phase 已完成（CLAUDE.md 迭代日志中有对应记录）
2. 最近一次 /verify-phase 已通过
3. 已完成 /commit（代码已推送至远端）

## 执行流程

### Step 1: 版本号建议

读取 git log，分析最近一个 tag 以来的 commit 类型：
- 有 `feat:` → Minor version bump（如 v1.0.0 → v1.1.0）
- 只有 `fix:` / `chore:` → Patch bump（如 v1.0.0 → v1.0.1）
- 有破坏性变更（BREAKING CHANGE 标注） → Major bump

```
建议版本号: v{M.N.P}（基于 {分析依据}）
当前最新 tag: {tag 或 "无 tag，首次发布"}

确认版本号？(直接回车使用建议值，或输入自定义):
```

### Step 2: 生成 CHANGELOG 条目

读取所有 commit 信息（自上一个 tag 至今），生成 CHANGELOG.md 条目：

```markdown
## v{M.N.P} — {YYYY-MM-DD}

### ✨ 新功能
- {feat commit 摘要}

### 🐛 Bug 修复  
- {fix commit 摘要}

### 🔧 其他变更
- {chore/refactor commit 摘要}
```

追加到 `CHANGELOG.md`（不存在则创建）。

### Step 3: 发布前安全扫描

运行安全检查（与 /commit 相同门禁）：
- gitleaks detect（Secrets 检测）
- 若检查不通过 → STOP，不允许发布

### Step 4: 创建 GitHub Release

```bash
gh release create v{M.N.P} \
  --title "v{M.N.P} — {一句话发布摘要}" \
  --notes "$(cat {CHANGELOG_本次条目})" \
  --draft  # 先创建草稿，用户确认后发布
```

等待用户确认草稿内容后，执行：
```bash
gh release edit v{M.N.P} --draft=false
```

### Step 5: 更新 Active Layers

提示用户更新 CLAUDE.md 的 Active Layers：
```markdown
发布层: ✅ 完成 | CHANGELOG.md ✅ · GitHub Release ✅
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

## 与 /commit 的分工

| 命令 | 职责 |
|------|------|
| `/commit` | 单次代码提交 + 安全扫描 + push |
| `release-builder` | 版本封装 + CHANGELOG + GitHub Release |

不需要运行 `release-builder` 才能 `/commit`。`release-builder` 是对多次 commit 的版本级汇总。
