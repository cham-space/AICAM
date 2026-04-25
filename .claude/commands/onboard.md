---
description: Interactive onboarding — guide new developers through AICAM setup step by step
argument-hint: ""
---

# Onboard: AICAM Interactive Setup

## Mission

Guide a new developer through progressive AICAM setup, from zero to fully configured. Adapt based on their chosen level (L0-L3).

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
3. **Install git hooks**:
   ```bash
   ln -sf ../../.githooks/pre-commit .git/hooks/pre-commit
   ln -sf ../../.githooks/commit-msg .git/hooks/commit-msg
   ```
4. **Set up CI**: Copy `.github/workflows/aicam-gates.yml` — adapt commands to project ecosystem
5. **Set up commitlint**: `npm install -D @commitlint/config-conventional`
6. **Configure MCP** (optional):
   - serena: `uv tool install -p 3.13 serena-agent@latest --prerelease=allow && serena setup claude-code`
   - typescript-lsp: `npm install -g ts-language-mcp && claude mcp add --scope user typescript-lsp -- npx -y ts-language-mcp`
7. **Verify**: Run `/diagnose` — security tools + CI should show ✅
8. **Ready**: Production-grade workflow with automated quality gates

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
