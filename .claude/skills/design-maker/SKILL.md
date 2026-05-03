---
description: Generate UI prototype mockups using Figma MCP based on PRD and Design Brief
---

# Skill: design-maker

## 触发条件

以下任一情况激活：
- 工作流节点 0-B3（Design-Brief.md 已生成，已配置 Figma MCP）
- 用户明确说「画设计图」「生成原型图」

**前置要求**：
1. PRD.md 已存在
2. Design-Brief.md 已存在  
3. Figma MCP 已配置（见下方配置指南；pencil-mcp 不可用，见说明）

## MCP 配置指南

### 方案 A: Pencil MCP（推荐 - 支持 AI 自动生成设计图）

Pencil 是 VS Code 扩展内置的 MCP server，通过 stdio 二进制连接，**支持 AI 全自动绘制原型图**（对应 PM 4.0 博客中的 "Pencil"）。

```bash
# 1. 在 VS Code 中安装 Pencil 扩展
# 2. 注册 MCP 到 Claude Code（路径根据实际二进制位置调整）
claude mcp add --scope user pencil -- \
  /Users/<user>/.pencil/mcp/visual_studio_code/out/mcp-server-darwin-arm64 \
  --app visual_studio_code

# 3. 验证连接
claude mcp list  # 确认 pencil 出现在列表中且 Connected
```

### 方案 B: Figma MCP（适合已有 Figma 设计稿）

方向是 **Figma→读取→代码**，适合设计师已画好 Figma 稿时一键实现前端代码。

```bash
# 需 Figma 账号 + Personal Access Token
claude mcp add --scope user figma -- \
  npx -y figma-developer-mcp --figma-api-key="$FIGMA_TOKEN" --stdio
```

### 方案 C: Playwright 设计生成管线（零外部依赖）

无 Pencil/Figma 时，用 Playwright MCP 渲染 frontend-design skill 生成的 HTML/CSS 原型为可视化截图：

```
PRD.md + Design-Brief.md → frontend-design skill（生成 HTML/CSS 原型页面）
  → Playwright MCP browser_navigate → browser_take_screenshot → 设计稿截图
```

**优势**：零外部依赖，Playwright MCP 已配置，截图可直接用于开发参考 + QA 归档。

### 方案 D: 文字版 Mockup（终极降级）

无任何 MCP 时自动降级：生成 `Design-Mockup-Description.md`（Markdown + ASCII 图描述布局）。

## 执行流程

### Step 1: 规划设计范围

读取 PRD.md + Design-Brief.md，规划：

```
输出规划清单（等待用户确认后再开始绘制）:
  组件库: {N} 个基础组件
  主页面: {列表，如 登录页/主界面/设置页}
  变体页面: {列表，如 空状态/加载状态/错误状态}
  
是否有遗漏的页面？(确认后开始绘制)
```

### Step 2: 用户确认后开始绘制

**绘制顺序**: 基础组件 → 主页面 → 变体页面 → 空状态页面

每个页面绘制完成后简短报告：
```
✅ {页面名} 绘制完成
```

### Step 3: 全部完成后核查

```
🎨 原型图绘制完成！

已完成:
  ✅ {N} 个组件
  ✅ {N} 个主页面  
  ✅ {N} 个变体页面

请在 Figma 中检查:
  □ 所有页面的布局是否符合 Design-Brief
  □ 配色是否正确
  □ 是否有遗漏的页面/状态

检查完成后，请在 CLAUDE.md 的 Key Files 中记录设计图路径/链接。
```

### Step 4: 更新 CLAUDE.md

提示用户在 CLAUDE.md 的 `## Key Files` 中手动添加：
```markdown
| `{Figma链接}` | UI 原型设计图 — 开发最高优先级参考 |
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

## 权重说明

⚠️ **开发时优先级**: 设计图 > Design-Brief.md > PRD.md

- 设计图有明确视觉呈现的，以设计图为准
- 设计图未覆盖的细节，参考 Design-Brief.md
- 功能逻辑问题，参考 PRD.md

## 无 MCP 时的降级方案

若无 Figma MCP，输出文字版原型描述：

生成 `Design-Mockup-Description.md`，用 Markdown 表格 + ASCII 图描述每个页面的布局、元素位置和交互，作为开发参考。
