---
description: Interactive onboarding — guide new developers through AICAM setup step by step
argument-hint: ""
---

# Onboard: AICAM Interactive Setup

## Mission

Guide a new developer through progressive AICAM setup, from zero to fully configured. Adapt based on their chosen level (L0-L3).

## Entry: Role & Context Routing

在进入级别选择前，先明确角色和项目状态，以便路由到最合适的配置路径。

### Q1: 你的角色？

```
你在这个项目中主要担任哪种角色？

  A) 产品经理 / 业务负责人
     → 关注: 需求定义、设计规范、产品文档
  
  B) UI/UX 设计师
     → 关注: 设计规范、原型图、设计→代码一致性
  
  C) 开发工程师
     → 关注: 代码质量、TDD、门禁、API合约
  
  D) 全栈独立开发 / 独立产品人
     → 关注: 全链路，从产品定义到发布，单人顺序模式
  
  E) 团队维护/迭代（项目已有 PRD 和代码）
     → 关注: 快速接入现有工作流，迭代开发

请输入 A/B/C/D/E:
```

### Q2: 项目当前状态？

根据 Q1 答案调整问法：

```
（A/B 看到）你是从零开始定义产品，还是接手已有 PRD？
  1) 全新项目，从零开始
  2) 已有 PRD，需要做设计规范/设计图
  
（C/D 看到）代码库状态？
  1) 全新项目（无代码，要从零开始）
  2) 已有 PRD 和设计图，准备开发
  3) 已有代码，接手维护/新增功能
  
（E 看到）→ 直接跳至「接手项目路径」
```

### Q3: 功能级别？

仅对 C/D/E 展示（A/B 跳过）：

```
选择配置深度（可随时通过再次运行 /onboard 升级）:
  L1 — 最小配置 (< 15 min)  适合 MVP/原型
  L2 — 标准配置 (< 1 hr)   ← 推荐
  L3 — 高级配置 (< 2 hr)   适合生产环境/团队协作
```

### 路由结果

| 角色 | 项目状态 | 路由到 |
|------|---------|-------|
| A — PM | 全新项目 | 产品定义层路径：/discover → /create-prd(多轮) → design-brief-builder |
| A — PM | 已有PRD | 提示 PRD 审查 → design-brief-builder |
| B — 设计师 | 已有PRD | design-brief-builder → design-maker（Pencil MCP 推荐 / Figma MCP 备选 / 无 MCP 自动降级 Playwright 管线或文字 Mockup） |
| C — 开发者 | 全新 | L1/L2/L3 原有流程 |
| C — 开发者 | 已有PRD | 跳过产品定义层，直接 /prime → /plan-feature |
| C — 开发者 | 接手代码 | /prime 接手流程 |
| D — 全栈独立 | 全新 | 全链路路径（见下方） |
| D — 全栈独立 | 接手 | 检测当前 Active Layers → 续点接入 |
| E — 维护 | — | /prime + 说明当前进度追踪方式 |

> ⚠️ **设计工具前置准备**：路由到产品定义层（含 design-maker）时，按所选工具提前准备：
> - **Pencil MCP**：在 VS Code 中安装 Pencil 扩展，MCP 二进制随扩展自带，无需额外账号
> - **Figma MCP**：需 Figma 账号 + Personal Access Token（figma.com → Settings → Personal Access Tokens）
> - **无 MCP**：自动降级 Playwright 渲染管线或文字 Mockup，流程不阻塞

#### 全栈独立开发 — 全新项目完整路径

```
[产品定义层]
1. /discover         → 需求沟通与架构调研
2. /create-prd       → 多轮追问生成 PRD.md
3. design-brief-builder → 生成 Design-Brief.md（有UI项目）
4. design-maker      → Figma MCP 原型图（可选）
5. /ref-research     → 组件/API 最佳实践调研

[开发质量层]
6. /create-rules     → 生成 CLAUDE.md（含 Active Layers 声明）
7. /init-project     → 本地环境初始化
8. /prime            → 加载全量上下文
9. 循环: /plan-feature → /execute → /code-review → /verify-phase → /close-phase → /commit

[发布层]（可选）
10. release-builder  → 版本管理 + GitHub Release

[进化层]（全程后台）
  - /prime 启动时自动扫描反馈
  - 修正信号词自动检测
```

> **Post-Setup Validation**（onboard 完成后输出）:
> ```
> 1. 运行 /diagnose — 确认 CLAUDE.md ✅ + Gates ✅ + Skills ✅ + MCP 工具 ✅
> 2. 进化层 ✅ 后台运行 — 你无需管理它。修正信号会被自动捕捉到 .agents/feedback/，
>    同类反馈达阈值后系统轻提示规则升级建议（需你手动确认才执行）。
>    查看已记录反馈: .agents/feedback/index.md
> ```

## Entry: Level Selection

Present the 4 levels and let the user choose:

```
Choose your AICAM setup level:

  L0 — Zero Config（< 5 min）
       One command: /hotfix for emergency fixes
       No CLAUDE.md, no skills, no gates

  L1 — Minimal（< 15 min）
       /plan-feature → /execute → /commit
       Default CLAUDE.md rules, no external research

  L2 — Standard（< 1 hr）← recommended for most projects
       Full 5 Phase lifecycle + 4 Skills
       CLAUDE.md + PRD.md + reference docs

  L3 — Advanced（< 2 hr）
       L2 + CI/CD gates + security scanning + MCP tools
       Production-ready for team collaboration

Which level? (L0 / L1 / L2 / L3)
```

## Level Paths

### L0 — Zero Config

1. Verify `.claude/commands/hotfix.md` exists
2. Done. Use `/hotfix [bug description]` for emergency fixes.
3. When ready for more structure, re-run `/onboard` and choose L1+.

### L1 — Minimal

1. **Copy template**: `cp .claude/CLAUDE-template.md CLAUDE.md`
2. **Fill in basics**: Edit CLAUDE.md → fill `{project description}`, `{tech stack}`, `{commands}`
3. **Verify**: Run `/diagnose` — should show CLAUDE.md ✅
4. **Ready**: Use `/plan-feature [feature]` → `/execute` → `/commit`
5. **Next**: Run `/onboard` and choose L2 for full workflow.

### L2 — Standard

Complete L1 first, then:

1. **Create PRD** (if not exists): `/create-prd`
2. **Run discovery** (new project): `/discover [project idea]`
3. **Set up reference docs**: `/ref-research`
4. **Generate rules**: `/create-rules`
5. **Init environment**: `/init-project`
6. **Prime session**: `/prime`
7. **Verify**: Run `/diagnose` — all gates + skills should show ✅
8. **Ready**: Full 5 Phase cycle — `/plan-feature` → `/execute` → `/code-review` → `/verify-phase` → `/close-phase` → `/commit`

### L3 — Advanced

Complete L2 first, then:

1. **Install gitleaks**: `brew install gitleaks`
   - **CI 注**: `gitleaks-action@v2` 对 public repo 免费，private repo 需付费 License。在 GitHub repo Settings → Secrets and variables → Actions 中添加 `GITLEAKS_LICENSE` secret。无 License 时 CI 已配置 `continue-on-error: true` 降级为非阻断 warning。也可替换为免费的 `trufflesecurity/trufflehog@main` action。
2. **Install semgrep**: `pip install semgrep`
3. **Install git hooks**: Choose one:
   ```bash
   # Option A: Set hooks path (recommended)
   git config core.hooksPath .githooks

   # Option B: Symlink individual hooks
   ln -sf ../../.githooks/pre-commit .git/hooks/pre-commit
   ln -sf ../../.githooks/commit-msg .git/hooks/commit-msg
   ```
4. **Configure checks**: Edit `.githooks/config` — comment out checks not needed for this project
5. **Set up CI**: Copy `.github/workflows/aicam-gates.yml` — adapt commands to project ecosystem
6. **Set up commitlint**: `npm install -D @commitlint/config-conventional`
7. **Configure MCP** (optional):
   - serena: `uv tool install -p 3.13 serena-agent@latest --prerelease=allow && serena setup claude-code`
   - typescript-lsp: `npm install -g ts-language-mcp && claude mcp add --scope user typescript-lsp -- npx -y ts-language-mcp`
8. **Verify**: Run `/diagnose` — security tools + CI should show ✅
9. **Ready**: Production-grade workflow with automated quality gates

## Post-Setup Validation

After completing the selected level, output:

```
✅ AICAM Level {N} setup complete!

Your workflow:
  Command:  /{primary-command}
  Skills:   {list of available skills}
  Gates:    {list of active gates}
  Security: {gitleaks/semgrep/CI status}

Next recommended action: {suggestion based on level}
```
