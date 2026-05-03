#!/usr/bin/env bash
# stop-gate.sh — Agent 准备结束会话前检查 Phase 审查状态

PLANS_DIR=".agents/plans"
REVIEWS_DIR=".agents/reviews"

[ -d "$PLANS_DIR" ] || exit 0

missing=()
shopt -s nullglob
for summary in "$PLANS_DIR"/*.summary.md; do
  [ -f "$summary" ] || continue
  phase=$(basename "$summary" .summary.md)
  [ -f "$REVIEWS_DIR/${phase}-code-review.md" ] || missing+=("$phase")
done
shopt -u nullglob

if [ ${#missing[@]} -gt 0 ]; then
  echo "⚠️  [stop-gate] 以下 Phase 缺少 code review 记录:"
  for p in "${missing[@]}"; do echo "   - $p"; done
  echo "   建议运行 /code-review，或确认已完成审查后继续。"
fi

exit 0
