#!/usr/bin/env bash
# scripts/detect-review-status.sh
# Checks .vibecrew/reviews/ for review reports matching the active feature.
# Used by calculate-vibe-score.sh and /wrap.
# Usage: detect-review-status.sh [project_root]
# Output: JSON object to stdout

set -euo pipefail

PROJECT_ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
STATE_FILE="$PROJECT_ROOT/.vibecrew/state.json"
REVIEWS_DIR="$PROJECT_ROOT/.vibecrew/reviews"

REVIEW_COMPLETED=false
FINDINGS_COUNT=0
VERDICT="none"

if [[ -f "$STATE_FILE" && -d "$REVIEWS_DIR" ]]; then
  # Get active feature ID
  FEATURE_ID=$(jq -r '.active_feature.id // empty' "$STATE_FILE" 2>/dev/null || echo "")

  if [[ -n "$FEATURE_ID" ]]; then
    # Find the most recent review for this feature
    LATEST_REVIEW=$(ls -1t "$REVIEWS_DIR"/review-"${FEATURE_ID}"-*.json 2>/dev/null | head -1)

    if [[ -n "$LATEST_REVIEW" && -f "$LATEST_REVIEW" ]]; then
      REVIEW_COMPLETED=true
      FINDINGS_COUNT=$(jq -r '.findings | length // 0' "$LATEST_REVIEW" 2>/dev/null || echo "0")
      VERDICT=$(jq -r '.verdict // "none"' "$LATEST_REVIEW" 2>/dev/null || echo "none")
    fi
  fi
fi

jq -n \
  --argjson review_completed "$REVIEW_COMPLETED" \
  --argjson findings_count "$FINDINGS_COUNT" \
  --arg verdict "$VERDICT" \
  '{
    review_completed: $review_completed,
    findings_count: $findings_count,
    verdict: $verdict
  }'
