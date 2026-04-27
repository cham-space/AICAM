#!/usr/bin/env bash
# Check: Secrets detection
# Detects accidentally committed credentials, private keys, tokens.
# Exit 1 = block commit. Exit 0 = clean.

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

SECRETS_TOOL="${SECRETS_TOOL:-auto}"

echo "  Checking secrets..."

use_gitleaks() {
  if gitleaks detect --source . --no-git --verbose 2>/dev/null; then
    echo -e "  ${GREEN}✅${NC} Secrets: clean (gitleaks)"
    return 0
  else
    echo -e "  ${RED}❌ Secrets detected by gitleaks!${NC}"
    return 1
  fi
}

use_basic() {
  STAGED=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || true)
  local found=0
  for f in $STAGED; do
    if [ -f "$f" ]; then
      # Private keys
      if grep -q "BEGIN.*PRIVATE KEY" "$f" 2>/dev/null; then
        echo -e "  ${RED}❌ Private key found in staged file: $f${NC}"
        found=1
      fi
      # Hardcoded tokens (generic pattern)
      if grep -qiE "(secret|token|password)\s*[:=]\s*['\"][A-Za-z0-9_\-\.]{20,}['\"]" "$f" 2>/dev/null; then
        echo -e "  ${RED}❌ Possible hardcoded secret in staged file: $f${NC}"
        found=1
      fi
    fi
  done
  if [ "$found" -eq 0 ]; then
    echo "  ✅ Secrets: clean (basic scan)"
    return 0
  fi
  return 1
}

case "$SECRETS_TOOL" in
  gitleaks)
    use_gitleaks
    exit $?
    ;;
  basic)
    use_basic
    exit $?
    ;;
  auto|*)
    if command -v gitleaks &> /dev/null; then
      use_gitleaks
    else
      echo "  ⏭  gitleaks not installed — using basic regex scan"
      use_basic
    fi
    exit $?
    ;;
esac
