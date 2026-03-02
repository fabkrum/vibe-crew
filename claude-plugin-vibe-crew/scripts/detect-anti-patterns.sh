#!/usr/bin/env bash
# scripts/detect-anti-patterns.sh
# Scans score history for recurring deduction categories.
# Outputs frequency data: category, count, sessions, total_points.
# Exit 0 always.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SCORES_DIR="$PROJECT_ROOT/.vibecrew/scores"

# --- Check for score files ---
if [[ ! -d "$SCORES_DIR" ]]; then
  echo '{"patterns":[],"total_sessions":0}'
  exit 0
fi

SCORE_FILES=$(ls -1t "$SCORES_DIR"/score-*.json 2>/dev/null | head -10 || true)
FILE_COUNT=$(echo "$SCORE_FILES" | grep -c '.' 2>/dev/null || true)
FILE_COUNT=${FILE_COUNT:-0}

if [[ "$FILE_COUNT" -eq 0 ]]; then
  echo '{"patterns":[],"total_sessions":0}'
  exit 0
fi

# --- Build pattern frequency map ---
# For each score file, extract deduction categories with points and session IDs
PATTERN_DATA="[]"

while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  [[ ! -f "$file" ]] && continue

  session_id=$(jq -r '.session_id // "unknown"' "$file" 2>/dev/null || echo "unknown")

  # Extract each deduction as {category, points, session_id}
  deductions=$(jq --arg sid "$session_id" '[
    .deductions // [] |
    .[] |
    {category: .category, points: .points, session_id: $sid}
  ]' "$file" 2>/dev/null || echo "[]")

  PATTERN_DATA=$(echo "$PATTERN_DATA" | jq --argjson d "$deductions" '. + $d')
done <<< "$SCORE_FILES"

# --- Aggregate by category ---
PATTERNS=$(echo "$PATTERN_DATA" | jq '
  group_by(.category) |
  map({
    category: .[0].category,
    count: length,
    sessions: [.[].session_id] | unique,
    session_count: ([.[].session_id] | unique | length),
    total_points: [.[].points] | map(. * -1) | add,
    average_points: ([.[].points] | map(. * -1) | add / length | . * 10 | round / 10)
  }) |
  sort_by(-.session_count, -.total_points)
')

# --- Output ---
jq -n \
  --argjson patterns "$PATTERNS" \
  --argjson total "$FILE_COUNT" \
  '{
    patterns: $patterns,
    total_sessions: $total
  }'

exit 0
