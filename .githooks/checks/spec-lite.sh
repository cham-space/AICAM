#!/usr/bin/env bash
# Check: Spec-Lite coverage
# Ensures every plan has a corresponding spec file.
# Exit 1 = block commit (more plans than specs). Exit 0 = pass.

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PLAN_DIR="${SPEC_LITE_PLAN_DIR:-.agents/plans}"
SPEC_DIR="${SPEC_LITE_SPEC_DIR:-.agents/specs}"

if [ ! -d "$PLAN_DIR" ]; then
  echo "  ℹ  No plans directory — skipping"
  exit 0
fi

PLAN_COUNT=$(find "$PLAN_DIR" -maxdepth 1 -name "*.md" ! -name "*.summary.md" 2>/dev/null | wc -l | tr -d ' ')
SPEC_COUNT=$(find "$SPEC_DIR" -name "*.spec.md" 2>/dev/null | wc -l | tr -d ' ')

if [ "$PLAN_COUNT" -gt "$SPEC_COUNT" ]; then
  echo -e "  ${YELLOW}⚠  Plan files ($PLAN_COUNT) > Spec-Lite files ($SPEC_COUNT)${NC}"
  echo "     Each plan must have a corresponding Spec-Lite."
  echo "     Run /plan-feature to generate missing Spec-Lite."
  exit 1
fi

echo -e "  ${GREEN}✅${NC} Spec-Lite: $SPEC_COUNT files"
exit 0
