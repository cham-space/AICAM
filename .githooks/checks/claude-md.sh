#!/usr/bin/env bash
# Check: CLAUDE.md size
# Warns when CLAUDE.md exceeds the configured line limit.
# Exit 0 = always pass (warning only).

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

MAX_LINES="${CLAUDE_MD_MAX_LINES:-150}"

if [ ! -f "CLAUDE.md" ]; then
  echo "  ℹ  No CLAUDE.md — skipping"
  exit 0
fi

LINES=$(wc -l < CLAUDE.md | tr -d ' ')

if [ "$LINES" -gt "$MAX_LINES" ]; then
  echo -e "  ${YELLOW}⚠  CLAUDE.md is $LINES lines (>$MAX_LINES threshold)${NC}"
  echo "     Consider running /close-phase to compress iteration log."
  exit 0
fi

echo -e "  ${GREEN}✅${NC} CLAUDE.md: $LINES lines"
exit 0
