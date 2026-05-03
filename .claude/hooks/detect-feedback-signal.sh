#!/usr/bin/env bash
# detect-feedback-signal.sh
# PostToolUse hook — 检测用户消息中的修正/不满意关键词
# Claude Code 通过 stdin 传入 JSON 上下文，包含用户消息等字段

set -euo pipefail

INPUT=$(cat)

# 提取用户消息内容（实施前打印 INPUT 确认实际字段路径）
USER_MSG=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    msg = (data.get('user_message') or
           data.get('message', {}).get('content', '') or
           data.get('input', {}).get('user_message', '') or '')
    print(str(msg))
except:
    print('')
" 2>/dev/null || echo "")

KEYWORDS=(
  "应该" "漏掉了" "不对" "记下来" "每次都" "总是忘"
  "下次要" "以后要" "这样不好" "能不能" "希望你"
  "你应该" "最好是" "建议你" "注意一下" "别再" "不要再"
)

MATCHED=""
for kw in "${KEYWORDS[@]}"; do
  if echo "$USER_MSG" | grep -q "$kw"; then
    MATCHED="$kw"
    break
  fi
done

if [ -n "$MATCHED" ]; then
  echo "💡 [feedback-signal] 检测到反馈信号词「$MATCHED」"
  echo "   是否需要记录？可调用 feedback-writer skill 或直接说「记下来」"
fi

exit 0  # 无关键词时静默，零噪音
