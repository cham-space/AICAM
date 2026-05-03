# EVOLUTION.md — 进化引擎规则

> AICAM v2.0 进化层核心规则文件。定义反馈记录、频次统计、规则升级的运作方式。
> 本文件由 evolution-engine skill 在扫描时读取，不加入日常 AI 上下文。

## 一、反馈分类

| 类别 | 定义 | 示例 |
|------|------|------|
| `process` | 关于工作流步骤的反馈 | "每次都漏掉检查设计图" |
| `quality` | 关于代码/文档质量的反馈 | "API 命名应该用 camelCase" |
| `skill-gap` | 当前 skill 未覆盖的操作模式 | "需要一个发布前检查清单" |
| `skill-issue` | 某个 skill 执行效果持续偏低 | "design-brief 生成的规范太模糊" |

## 二、进化阈值规则

| 触发条件 | 阈值 | 执行动作 |
|---------|------|---------|
| 同类别 + 同主题反馈 ≥ 3 次 | count ≥ 3 | 标记为「毕业候选」，生成建议 |
| 某 skill 的 `skill-issue` 类反馈 ≥ 2 次 | count ≥ 2 | 生成「skill 优化建议」 |
| 同操作模式的 `skill-gap` 反馈 ≥ 3 次 | count ≥ 3 | 生成「新建 skill 建议」 |

## 三、建议生成格式

Evolution Runner 生成建议时，必须使用以下格式：

```markdown
## 进化建议 {YYYY-MM-DD}

**建议类型**: [规则升级 / skill优化 / 新建skill]
**来源反馈**: {反馈ID列表，如 FB-001, FB-003, FB-007}
**频次统计**: {N} 次相同主题反馈（阈值: {threshold}）
**建议内容**: 
  {具体建议，说明要修改哪个文件的哪个部分，增加什么规则}
**影响范围**: [影响哪个 skill / gate / 命令文件]
**风险评估**: [Low/Medium — 说明是否会改变现有行为]

确认执行此建议？(y/n) ← 必须用户手动确认
```

## 四、执行约束

1. **绝不自动修改规则**：所有进化建议必须经用户明确确认（输入 y）后才执行
2. **单次最多建议 3 条**：避免一次性建议过多造成认知负担
3. **建议记录**：每条建议执行结果写入 `.agents/feedback/EVOLUTION-LOG.md`
4. **扫描频率**：Session 启动时（/prime 触发）或手动调用 evolution-engine skill

## 五、跨项目延续说明

`.agents/feedback/` 目录随项目存储，不同项目各自独立。
如需跨项目共享积累，提供以下两种方式（按需选择）：

**方案 A — 符号链接（推荐）**  
将 `.agents/feedback/` 符号链接到用户级共享目录：
```bash
mkdir -p ~/.aicam/feedback
ln -s ~/.aicam/feedback .agents/feedback
```
新项目 /onboard 时可选择是否复用已有的 feedback 库。

**方案 B — 手动合并**  
定期将 `feedback/entries/*.md` 复制到共享位置，再合并 `index.md` 统计数字。

> **默认行为**：单项目独立积累，不自动跨项目共享。跨项目共享为可选高级用法。

## 六、与 CLAUDE.md Known Issues 的边界说明

> **M1 修正**：EVOLUTION.md 进化系统与 CLAUDE-template.md `Known Issues` 节的职责边界：

| 文件 | 职责 | 读取者 |
|------|------|--------|
| `CLAUDE.md ## Known Issues` | 当前技术债务和已知风险（AI 上下文用） | Claude 每次对话加载 |
| `.agents/feedback/` | 用户行为修正信号（进化引擎扫描用） | evolution-engine 专用，不加入对话上下文 |

两者**不交叉**：feedback/ 中不记录技术债务，Known Issues 中不记录行为反馈。

反馈可能来自一个层级，但应升级为另一层的规则。例如：
- 开发时发现"每次产品定义阶段遗漏边缘场景" → 升级为产品定义层规则
- 发布时发现"未检查安全扫描" → 升级为发布层 checklist

evolution-runner 记录反馈时，需标注：
- `source_layer`: 发现反馈时所在层（如 `development_quality`）
- `target_layer`: 规则应升级至的层（如 `product_definition`）
