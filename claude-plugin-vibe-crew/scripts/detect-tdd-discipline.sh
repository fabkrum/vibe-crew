#!/usr/bin/env bash
# scripts/detect-tdd-discipline.sh
# Detects TDD discipline by searching recent git log for commits with
# "TDD cycle" trailer. Used by calculate-vibe-score.sh and /wrap.
# Usage: detect-tdd-discipline.sh [project_root]
# Output: JSON object to stdout

set -euo pipefail

PROJECT_ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

DISCIPLINE_DETECTED=false
CYCLE_COUNT=0

if command -v git &>/dev/null && git -C "$PROJECT_ROOT" rev-parse --git-dir &>/dev/null; then
  # Search last 50 commits for TDD cycle trailers
  CYCLE_COUNT=$(git -C "$PROJECT_ROOT" log --format='%B' -50 2>/dev/null \
    | grep -c "TDD cycle:" 2>/dev/null || true)
  CYCLE_COUNT=${CYCLE_COUNT:-0}

  if [[ "$CYCLE_COUNT" -gt 0 ]]; then
    DISCIPLINE_DETECTED=true
  fi
fi

jq -n \
  --argjson discipline_detected "$DISCIPLINE_DETECTED" \
  --argjson cycle_count "$CYCLE_COUNT" \
  '{
    discipline_detected: $discipline_detected,
    cycle_count: $cycle_count
  }'
