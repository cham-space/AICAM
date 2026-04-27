#!/usr/bin/env bash
# Check: Large file warning
# Warns when staged files exceed the configured size threshold.
# Exit 0 = always pass (warning only).

YELLOW='\033[1;33m'
NC='\033[0m'

THRESHOLD="${LARGE_FILES_THRESHOLD:-500000}"

STAGED=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || true)
LARGE=""
for f in $STAGED; do
  if [ -f "$f" ]; then
    SIZE=$(wc -c < "$f" | tr -d ' ')
    if [ "$SIZE" -gt "$THRESHOLD" ]; then
      KB=$(echo "scale=1; $SIZE/1024" | bc 2>/dev/null || echo "$SIZE")
      LARGE="${LARGE}  $f (${KB}B)\n"
    fi
  fi
done

if [ -n "$LARGE" ]; then
  echo -e "  ${YELLOW}⚠  Large files staged (>${THRESHOLD}B):${NC}"
  echo -e "$LARGE"
  echo "     Consider if these belong in the repo, .gitignore, or Git LFS."
fi

exit 0
