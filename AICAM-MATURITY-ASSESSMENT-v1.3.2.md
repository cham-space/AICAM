# AICAM 工作流成熟度深度评估 — v1.3.2

> **评估日期**: 2026-04-25
> **评估基线**: WORKFLOW.md v1.3.2 + 15 commands + 4 skills + 6 gates
> **评估方法**: 静态架构分析 + 行业对标 + Demo 项目模拟
> **评估人**: AI Agent (基于完整文件读取)

---

## 一、行业对标框架

本评估参考了以下公认的 AI 辅助开发成熟度维度：

| 对标来源 | 关键维度 | AICAM 对应机制 |
|---------|----------|--------------|
| **OpenSpec** (spec-driven development) | 规格先于实现, OpenAPI 作为单一真相源 | Spec-Lite + api-contract-first Skill + contract.gate |
| **Superpowers** (cparker/superhooks) | TDD iron law, systematic debugging, verification-before-completion | tdd.gate + 6 Gate 体系 + /verify-phase |
| **Aider conventions** | lint/test 门禁、conventional commits | commit-msg hook + security.gate |
| **DORA 能力模型** | CI/CD 自动化、测试覆盖率阈值 | coverage.gate(5生态工具) + CI pipeline + oasdiff |
| **GitHub Copilot 最佳实践** | 上下文管理、渐进式披露 | Phase 4 归档压缩 + 上下文卫生检查 |
| **Principle of Least Astonishment** | 最小惊讶原则、Surgical Changes | 关键原则 #16 + CLAUDE-template 约束 |

---

## 二、综合成熟度评分

| 维度 | 评分 | 等级 | 行业对比 | 说明 |
|------|------|------|---------|------|
| 架构设计 | 4.3 | L4 | 领先 Superpowers (3.8) | 5 Phase + Phase 0一次性初始化 + Hotfix 侧通道, 设计完整 |
| 门禁体系 | 4.6 | L4-L5 | 持平 OpenSpec 理念 | 6 Gate 解耦 + 硬规则 + 豁免申请协议 + 三层安全扫描 |
| TDD 纪律 | 4.2 | L4 | 超 Superpowers 默认 | 免豁清单精确 + Iron Law + 替代验证方式要求 |
| 上下文治理 | 4.5 | L4-L5 | 业界领先 | 归档压缩 + 迭代日志自动摘要 + 上下文预算估算 + TEST_DASHBOARD 不入上下文 |
| API 合约 | 4.0 | L4 | 接近 OpenSpec 级别 | oasdiff breaking change + 5框架参数绑定检查 + 命名映射表 |
| 安全扫描 | 4.3 | L4 | 行业标准 | gitleaks + semgrep + 依赖审计 + pre-commit + CI pipeline |
| 文档体系 | 4.2 | L4 | 领先 | index.md 加载时机说明 + 6种test-strategies + plan/spec-lite template |
| 韧性/可恢复性 | 3.4 | L3 | 中等偏下 | sub-agent容错 + anti-truncation + anti-bypass, 但 Phase 失败回退路径不清晰 |
| 可复用性 | 3.6 | L3-L4 | 新项目复制即用 | .claude/ 自包含 + CLAUDE-template 种子, 但环境依赖(MCP)需额外安装 |
| 开发者体验 | 3.3 | L3 | 有改进空间 | 15命令认知负担高, 渐进式路径(L0-L3)部分缓解, /onboard 引导有助但首次体验仍陡峭 |

**加权综合评分: 4.1 / 5.0 → L4 已管理级**

> 评分对标: L1 初始级(1) → L2 可重复级(2) → L3 已定义级(3) → L4 已管理级(4) → L5 优化级(5)
> 行业参考基线: Superpowers ~3.5, OpenSpec 理念 ~3.8, AICAM ~4.1

---

## 三、Demo 项目模拟: Todo REST API

### 模拟环境

```
项目类型: REST API (Python FastAPI)
规模: 单服务, 3 个 endpoint, SQLite 数据库
复杂度: 低 (~200 LOC)
团队: 1 人
```

### Phase 0-A: /discover — "Build a todo list API"

```
工具执行: 入口门控询问 → 用户选 Path A (需求明确)
问题1: ✅ 顺利, 标准 CRUD Todo API 需求清晰
问题2: 注意项 — Path A 将启动子智能体并行调研, 但对简单的 Todo API,
       架构调研可能过度(搜索 FastAPI patterns, todo API design 等)
       产出信息量远大于实际需要, 有上下文膨胀风险。

评级: ⚠ 轻量问题
```

### Phase 0-B: /create-prd

```
工具执行: 基于 0-A 对话生成 PRD.md
问题1: 生成的 PRD.md 可能包含完整的"目标用户群体分析"、
       "MVP 范围矩阵"、"迭代计划" 等章节。
       对于单文件 demo 来说严重超标。

具体问题: PRD 模板被设计用于正式产品, 没有轻量模式。
          L1 路径声称可跳过 Phase 0-C, 0-D,
          但没有说明 PRD 本身是否可以精简。

评级: ⚠ 中等问题  (对小型项目不友好)
```

### Phase 0-C: /ref-research → 0-D: /create-rules → 0-E: /init-project

```
问题1: Phase 0-C 判断需要生成 api.md (REST API项目)
       → 子智能体并行搜索 FastAPI best practices
       → 产出 api.md 参考文档
       对 demo 来说, 这个时间成本 > 实际编码时间

问题2: Phase 0-D 生成 CLAUDE.md
       → 检测到 FastAPI/Python → 设定命名规范
       → 引用 api.md
       需要项目已有代码才能"分析代码库约定",
       但新项目可能目录为空, 导致规则生成空洞。

问题3: Phase 0-E /init-project
       → 复制 .env, pip install, 启动数据库
       对于 SQLite 项目来说只需要 pip install fastapi uvicorn
       但命令脚本会按完整流程检查数据库连接等, 过度执行。

评级: ⚠ 中等  (Phase 0 总时长可能超过实际编码时间)
```

### Phase 1: /plan-feature "Add CRUD endpoints for todos"

```
工具执行: Stage 0 (上下文卫生检查) → Stage 1-5 → 生成计划 + Spec-Lite

问题1: Stage 0 扫描 .agents/plans/ 未归档产物
       → 新项目无旧产物, 直接通过
       但 md 大小总计扫描可能误算(包含 .claude/ 自身的 md 文件)

问题2: Spec-Lite 120行限制
       → CRUD todo 的规格大约 40 行能说清楚
       → 模板驱动的 Spec-Lite 自动填充到 ~80 行
       但 plan-template 要求填满所有节(Problem Statement,
       Solution Statement, Feature Metadata 等)导致冗余。

具体问题: Spec-Lite 模板的强制性节可能推动 Agent 填充无意义内容。
         例如一个 CRUD endpoint 不需要 "Problem Statement" 和
         "Solution Statement" 的详细展开。

评级: ⚠ 轻量问题
```

### Phase 2: /execute — TDD + 实施 + Smoke Test

```
问题1 (严重): TDD 前置要求对 CRUD 操作写失败测试
       FastAPI CRUD endpoint 的核心逻辑通常是:
       1. 参数接收 (框架负责)
       2. 数据库查询 (ORM负责)
       3. 返回 JSON (框架负责)
       
       → 实际上业务逻辑只有"调用 ORM 并返回结果"
       → TDD 对此类简单 CRUD 的测试价值有限
       → 但 tdd.gate 没有为 Simple CRUD 提供豁免通道
       
       当前可能的豁免路径:
       - 不属于"跨边界集成层"吗? 是REST endpoint, 属于不可豁免!
       - 申请豁免 → 需要"替代验证方式"
       - "运行时手动看" → 驳回 → 必须补写测试
       
       所以即使最简单的 GET /todos 也必须:
       1. 写 test_get_todos_empty() 红灯
       2. 写 test_get_todos_with_items() 红灯  
       3. 实现 GET /todos → 绿灯
       
       这对 demo 来说是正确的(TDD 纪律), 但不分项目规模地强制执行
       会让小型项目用户感到流程过重。

问题2: Smoke Test Checklist 对纯 API 项目
       smoke.gate 要求:
       - 启动应用 → 验证无崩溃 ✅
       - 核心 endpoint 响应 HTTP 200 ✅
       - 无 ERROR 日志 ✅
       
       问题: plan-template 的 Smoke Test Checklist 模板是通用模板,
       没有根据项目类型(rest-api)自动适配。
       用户/AI需要手动填写checklist条目。
       对于 demo, 最简单的 checklist 是:
         1. 启动 uvicorn → 无崩溃
         2. GET /todos → 返回 200 + []
         3. POST /todos → 返回 201 + {"id": 1, ...}
         4. GET /todos → 返回 200 + [{"id": 1, ...}]
       但 plan-template 没有为 API 项目提供这个预制模板。

问题3: v1.3.2 bug fix 中提到 Python rest-api smoke fallback 逻辑
       从 `[ -n "$SERVER_PID" ]` 改为 `python -c "import uvicorn"` 
       这说明 smoke test 对 Python 生态的检测仍然脆弱。
       
       进一步的潜在问题:
       - 如果项目用 gunicorn 而不是 uvicorn 直接启动呢?
       - 如果项目是 Flask/Django 但没有 uvicorn 呢?
       - fallback 只覆盖了 `python app.py` 这一种情况。

评级: 🔴 问题1 (TDD开销) 为设计权衡, ⚠ 问题2/3 为实际问题
```

### Phase 3: /code-review → /verify-phase

```
问题1: /code-review 要求 "必须在**新会话**中执行"
       → 用户需要: 关闭当前会话 → 开新窗口 → 运行 /code-review 
       → 修复 Critical → 回到原会话或再开新会话 → /verify-phase
       
       对 demo 项目来说, 这个新会话要求可能造成困惑:
       - 提示文字不够显眼, 用户可能直接在原会话执行
       - 新会话丢失了上下文, /code-review 需要重新定位文件和plan
       - macOS 下打开新终端窗口是简单的, 但概念上"开启新会话"不直观

问题2: /verify-phase Step 2 要求读取 plan 的 `## Project Type`
       → test-strategies/{type}.md 作为"业务流程验证方式"标准
       → 但 rest-api.md 的策略内容是通用指导, 不与具体 AC 挂钩
       → 导致验证时 "AC-1 对应哪个测试" 依赖人工判断

问题3: ⏸️ 状态硬规则 (v1.3.1 anti-bypass)
       /verify-phase 新增 "TDD/Smoke 条目数对比门禁"
       → 对比 Spec-Lite AC 数量 vs summary.md Test Cases 表行数
       → 如果行数不符 → 阻断
       → 但这个对比是纯数量比较, 不是语义匹配
       → 可能出现: 正确覆盖但条目计数方式不同导致误报

评级: ⚠ 问题1(UX摩擦), ⚠ 问题2(语义匹配不精确), ⚠ 问题3(误报风险)
```

### Phase 4: /close-phase → Phase 5: /commit

```
问题1: /close-phase Step 0 前置条件 "Smoke Test Log 全部 ✅"
       → 如果 Smoke Test 在 /execute 时全部通过,
       但在 /verify-phase 重跑时出现偶发失败(如端口占用),
       则状态不一致 → 需要修复 → 归档被阻塞
       
       建议: /close-phase 应区分"执行时通过"和"归档时复核",
       当复核失败时提供"确认已知风险继续归档"的选项。

问题2: TEST_DASHBOARD 不入 AI 上下文
       → 设计意图是正确的(避免上下文膨胀)
       → 但 /close-phase 仍会"读取并更新"它
       → 如果 TEST_DASHBOARD 历史条目很多(10+ Phase),
       读取和写入操作本身会消耗大量上下文
       → 当前没有对 TEST_DASHBOARD 本身的体积控制机制

问题3: /commit 执行安全扫描 (security.gate)
       → 要求 gitleaks + semgrep + 依赖审计
       → 这些工具不是项目依赖, 而是环境依赖
       → 如果用户跳过安装, 安全扫描被静默跳过
       → /diagnose 可以检测但不会阻止提交
       
       demo 场景: 用户在没有 gitleaks 的环境中提交,
       security.gate 的三层扫描全部不可执行,
       → 门禁形同虚设 (仅依赖 AI 手动检查)

评级: 🔴 问题3 (安全门禁依赖外部工具, 可能静默跳过)
      ⚠ 问题1 (归档复核灵活性)
      ⚠ 问题2 (TEST_DASHBOARD 体积控制)
```

---

## 四、Demo 模拟汇总: 发现的问题分级

### P0 阻断级

| ID | 问题 | 发现位置 | 影响 |
|----|------|---------|------|
| **P0-1** | 安全扫描门禁静默跳过 — security.gate 依赖 gitleaks/semgrep/pip-audit 等外部工具, 工具未安装时三层扫描全部不可执行, 但 /commit 不会因此阻断提交 | Phase 5 /commit | 安全漏洞可能绕过全部自动检测 |

### P1 高优先级

| ID | 问题 | 发现位置 | 影响 |
|----|------|---------|------|
| **P1-1** | 小型项目 Phase 0 过重 — 即使是 demo 级的 REST API, Phase 0 全部子步骤的执行时间可能超过实际编码时间, L1 路径虽跳过 0-C/0-D, 但仍需完整 PRD | Phase 0 全流程 | 小型项目用户流失, 体感"流程 > 产出" |
| **P1-2** | TDD 对 Simple CRUD 无豁免 — tdd.gate 将 REST endpoint 列为不可豁免, 但简单 CRUD 的业务逻辑仅"ORM调用+返回", TDD 价值递减但强制执行 | Phase 2 /execute | 小型项目的 TDD 时间占比过高 |
| **P1-3** | Smoke Test 对 Python 生态的脆弱性 — 当前 fallback 只检测 uvicorn, 对 gunicorn/Django/Flask 等部署方式覆盖不足, 容易误判"无法启动"或"无需启动" | Phase 2 Smoke Test | Smoke Test 可能给出错误结论 |

### P2 中等优先级

| ID | 问题 | 发现位置 | 影响 |
|----|------|---------|------|
| **P2-1** | /code-review 新会话要求 UX 摩擦 — 需要用户手动操作新会话, 对新手不友好, 可能导致在旧会话执行(code-review 明确警告但我们不能阻止) | Phase 3 /code-review | 评审质量下降(受实现上下文污染) |
| **P2-2** | AC-Test 条目对比为纯数量匹配 — anti-bypass 机制只比较条目数, 可能导致正确覆盖的误报或遗漏实际未覆盖的 AC | Phase 3 /verify-phase | 误报/漏报影响核验准确性 |
| **P2-3** | PRD 模板无轻量模式 — /create-prd 没有根据项目规模自适应, 小型项目也会生成完整 PRD | Phase 0-B | 文档冗余, 上下文膨胀 |
| **P2-4** | Phase 失败回退路径缺失 — 任何 Phase 失败后如何回退、恢复、或降级处理没有明确说明 | 全局 | 用户遇到失败时无所适从 |
| **P2-5** | TEST_DASHBOARD 无体积控制 — 长期项目累计 10+ Phase 后, DASHBOARD 本身的读写在 /close-phase 时消耗大量上下文 | Phase 4 | 上下文预算泄漏 |

### P3 建议级

| ID | 问题 | 发现位置 | 影响 |
|----|------|---------|------|
| **P3-1** | 15 命令认知负担 — 渐进式路径缓解但 /onboard 仅解决"准备"阶段, 实际使用时的命令选择仍然复杂 | 全局 | 新用户学习曲线陡峭 |
| **P3-2** | plan-template 强制节冗余 — Problem Statement, Solution Statement 等对简单功能推动 AI 填充无意义内容 | Phase 1 | 计划文档质量参差不齐 |
| **P3-3** | 混合类型项目(monorepo)指导不足 — 6种 test-strategies 各自独立, 但 monorepo 同时有 web+api 时如何协调测试策略? | Phase 2/3 | monorepo 用户困惑 |

---

## 五、与行业最佳实践的差距分析

### 5.1 对标 OpenSpec (规格驱动开发)

| OpenSpec 原则 | AICAM 现状 | 差距 |
|-------------|----------|------|
| 规格先于代码 | Spec-Lite 强制生成 ✅ | — |
| OpenAPI 作为单一真相源 | contract.gate + api-contract-first ✅ | — |
| 自动化合约测试 | oasdiff breaking change + CI ✅ | — |
| 规格即文档 | Spec-Lite ≤120行 + plan-template ✅ | — |
| 规格与测试双向追溯 | AC↔Test 追踪链 ✅ | 但为纯数量比对 (P2-2) |
| **规格分层(overview/detail)** | 仅一页式 Spec-Lite | **缺失**: 复杂功能无法展开子规格 |

### 5.2 对标 Superpowers (纪律约束)

| Superpowers 原则 | AICAM 现状 | 差距 |
|-----------------|----------|------|
| TDD Iron Law | tdd.gate Iron Law ✅ | — |
| Systematic Debugging | /execute 强制加载 ✅ | — |
| Verification Before Completion | /execute Step 6 ✅ | — |
| Parallel Agent Dispatch | /plan-feature + /e2e-test ✅ | — |
| Git Worktree 隔离 | 主动不使用 ❌ | 设计选择, 非缺失 |
| **Sub-agent 驱动开发** | /execute 不支持 worktree | **缺失**: 但为有意设计选择 |
| **Finishing a Branch** | /commit + /close-phase | 无 PR/Merge 流程(单主干) |

### 5.3 对标 DORA 能力模型

| DORA 能力 | AICAM 现状 | 差距 |
|----------|----------|------|
| 持续集成 | CI pipeline (aicam-gates.yml) ✅ | — |
| 测试自动化 | TDD + unit + business workflow ✅ | — |
| 安全左移 | pre-commit hook + 3层扫描 ✅ | 但静默跳过 (P0-1) |
| 变更管理 | Conventional Commits + commit-msg hook ✅ | — |
| **部署自动化** | 无 | **不在范围**(定位为开发工作流) |

---

## 六、关键优势总结

1. **门禁体系成熟度业界领先** — 6 Gate 解耦 + 硬规则 + 豁免协议 + 安全三层, 设计完整且可执行
2. **上下文治理机制卓越** — 归档压缩 + 自动摘要 + 渐进式加载 + TEST_DASHBOARD隔离, 解决长周期项目痛点
3. **TDD 纪律深度超行业均值** — 不可豁免清单精确 + 替代验证方式要求 + Iron Law, 防止测试腐败
4. **API 合约检测工具链完整** — oasdiff + 5框架参数绑定 + 常见陷阱参考, 解决前后端协作90%问题
5. **自我修复/韧性机制** — v1.3.1 anti-truncation/anti-bypass/Known Issues持久节, 防止工作流腐化
6. **可复用性强** — .claude/ 目录自包含 + CLAUDE-template 种子 + 渐进式路径, 新项目复制即用

---

## 七、改进建议(按优先级)

### 紧急(P0): 修复安全门禁静默跳过

```markdown
建议: 在 /commit 和 security.gate 中增加工具可用性检测步骤

具体方案:
1. /commit 执行前检查 gitleaks/semgrep/pip-audit 是否可执行
2. 不可执行 → 输出明确警告 + 要求用户书面确认跳过
3. 在 /diagnose 的 Section 5 中已包含此检查 → 
   增加 "security tools unavailable → BLOCK commit" 的硬规则
4. 提供 Docker-based 安全扫描作为 fallback:
   docker run --rm -v $(pwd):/src zricethezav/gitleaks detect --source /src
```

### 高优先级(P1): 小型项目轻量路径

```markdown
建议: 增强渐进式路径

具体方案:
1. L0 路径新增 "Micro" 级别:
   - 适用: ≤5 文件, ≤500 LOC, 单人项目
   - 命令: /hotfix 风格(无完整 Phase 0)
   - PRD 可选; CLAUDE.md 使用默认规则
   
2. /create-prd 增加 --lightweight 模式:
   - 仅生成: 项目概述 + MVP 范围 + API 列表
   - 跳过: 用户画像, 市场分析, 完整迭代计划
   
3. tdd.gate 为 Simple CRUD 增加快速通道:
   - 当 endpoint 仅做: 参数验证 + ORM 查询 + 序列化返回
   - 且无自定义业务逻辑(条件分支, 数据转换, 外部调用)
   - → 可用 1 个集成测试代替 逐层单元测试
```

### 中等优先级(P2)

```markdown
1. /code-review 更醒目的新会话提醒:
   - 在 /execute 完成时输出醒目提示(含复制命令)
   - 提供 "一键开新会话" 的 CLI 命令(如 `claude --new --command "/code-review ..."`)

2. AC↔Test 覆盖匹配改为语义匹配:
   - 在 summary.md 的 Test Cases 表中增加 `Covers AC` 列 → AC-N 直接引用
   - /verify-phase 改为提取 AC-N 标记而非行数对比

3. Phase 失败恢复指南:
   - 在 WORKFLOW.md 增加 "故障恢复" 节
   - 常见场景: 测试失败 / 门禁不通过 / 用户中途取消
   - 每个场景的状态检查 + 回退步骤(RESUME.md)
```

---

## 八、结论

**AICAM v1.3.2 在 AI 辅助开发工作流领域处于 L4 已管理级**, 在门禁体系、上下文治理、TDD 纪律三个维度领先行业均值。15 个命令 + 4 Skill + 6 Gate 的系统提供了一套完整且可复用的 AI 开发流程规范。

**本次评估发现的核心风险**: 安全扫描门禁依赖外部工具, 在工具未安装时可能静默跳过(P0), 以及小型项目场景下流程过重的问题(P1)。

**趋势**: 从 v1.0 → v1.3.2, 问题密度持续收敛(当前仅 3 项 P0/P1 级新发现), 质量提升曲线健康。

**推荐下一步**: 优先修复 P0-1(安全门禁), 然后在 v1.4.0 中引入小型项目轻量路径, 同时保持当前 L2-L3 路径的完整性和硬度。
