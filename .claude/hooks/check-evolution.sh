#!/usr/bin/env bash
# check-evolution.sh — 新会话启动时扫描反馈候选
# 对应 PM 4.0 的 evolution runner（轻量 shell 版本）

FEEDBACK_INDEX=".agents/feedback/index.md"

[ -f "$FEEDBACK_INDEX" ] || exit 0

CANDIDATE_COUNT=$(grep -c "candidate" "$FEEDBACK_INDEX" 2>/dev/null || echo 0)
TOTAL_COUNT=$(grep -c "^| FB-" "$FEEDBACK_INDEX" 2>/dev/null || echo 0)

if [ "$CANDIDATE_COUNT" -gt 0 ]; then
  echo "📈 [evolution] ${CANDIDATE_COUNT} 条反馈已达进化阈值（共 ${TOTAL_COUNT} 条）"
  echo "   运行 evolution-engine skill 查看进化建议，或等待 /prime 时自动触发。"
elif [ "$TOTAL_COUNT" -gt 0 ]; then
  echo "🔄 [evolution] 已积累 ${TOTAL_COUNT} 条反馈，暂无毕业候选。"
fi

exit 0
