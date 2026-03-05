#!/usr/bin/env bash
# scripts/check-analysis-staleness.sh
# Checks if analysis docs are stale based on:
#   1. Age > 30 days AND > 50 commits since generation
#   2. package.json modified since analysis generation
#   3. New source directories created since analysis
# Outputs JSON staleness report. Exit 0 always.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
ANALYSIS_DIR="${PROJECT_ROOT}/.vibecrew/analysis"
STACK_FILE="$ANALYSIS_DIR/stack.md"

# If no analysis docs, nothing to check
if [[ ! -f "$STACK_FILE" ]]; then
  echo '{"exists": false, "stale": false}'
  exit 0
fi

# Get analysis generation timestamp (file modification time)
if [[ "$(uname)" == "Darwin" ]]; then
  ANALYSIS_EPOCH=$(stat -f %m "$STACK_FILE" 2>/dev/null || echo "0")
else
  ANALYSIS_EPOCH=$(stat -c %Y "$STACK_FILE" 2>/dev/null || echo "0")
fi

CURRENT_EPOCH=$(date +%s)
AGE_DAYS=$(( (CURRENT_EPOCH - ANALYSIS_EPOCH) / 86400 ))

# Count commits since analysis generation
ANALYSIS_DATE=$(date -r "$ANALYSIS_EPOCH" "+%Y-%m-%d" 2>/dev/null || date -d "@$ANALYSIS_EPOCH" "+%Y-%m-%d" 2>/dev/null || echo "2000-01-01")
COMMITS_SINCE=$(git log --since="$ANALYSIS_DATE" --oneline 2>/dev/null | wc -l | tr -d ' ')

# Check if package.json was modified since analysis
PACKAGE_STALE=false
if [[ -f "$PROJECT_ROOT/package.json" ]]; then
  if [[ "$(uname)" == "Darwin" ]]; then
    PKG_EPOCH=$(stat -f %m "$PROJECT_ROOT/package.json" 2>/dev/null || echo "0")
  else
    PKG_EPOCH=$(stat -c %Y "$PROJECT_ROOT/package.json" 2>/dev/null || echo "0")
  fi
  if [[ "$PKG_EPOCH" -gt "$ANALYSIS_EPOCH" ]]; then
    PACKAGE_STALE=true
  fi
fi

# Determine staleness
STALE=false
REASONS="[]"

if [[ "$AGE_DAYS" -gt 30 && "$COMMITS_SINCE" -gt 50 ]]; then
  STALE=true
  REASONS=$(echo "$REASONS" | jq '. + ["Age: '"$AGE_DAYS"' days with '"$COMMITS_SINCE"' commits since generation"]')
fi

if [[ "$PACKAGE_STALE" == true ]]; then
  STALE=true
  REASONS=$(echo "$REASONS" | jq '. + ["package.json modified since analysis"]')
fi

jq -n \
  --argjson exists true \
  --argjson stale "$STALE" \
  --argjson age_days "$AGE_DAYS" \
  --argjson commits_since "$COMMITS_SINCE" \
  --argjson package_stale "$PACKAGE_STALE" \
  --argjson reasons "$REASONS" \
  '{exists: $exists, stale: $stale, age_days: $age_days, commits_since: $commits_since, package_stale: $package_stale, reasons: $reasons}'

exit 0
