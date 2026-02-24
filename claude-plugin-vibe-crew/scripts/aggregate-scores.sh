#!/usr/bin/env bash
# scripts/aggregate-scores.sh
# Reads last 10 score files from .vibecrew/scores/, outputs trend JSON.
# Trend directions: improving, declining, recurring, plateau, volatile
# Exit 0 always (analysis failures should not block the session)

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SCORES_DIR="$PROJECT_ROOT/.vibecrew/scores"

# --- Check for score files ---
if [[ ! -d "$SCORES_DIR" ]]; then
  echo '{"direction":"unknown","window_size":0,"average_score":0,"scores":[],"top_recurring_patterns":[]}'
  exit 0
fi

SCORE_FILES=$(ls -1t "$SCORES_DIR"/score-*.json 2>/dev/null | head -10)
FILE_COUNT=$(echo "$SCORE_FILES" | grep -c '.' 2>/dev/null || echo "0")

if [[ "$FILE_COUNT" -eq 0 ]]; then
  echo '{"direction":"unknown","window_size":0,"average_score":0,"scores":[],"top_recurring_patterns":[]}'
  exit 0
fi

# --- Extract scores and deduction categories ---
SCORES_ARRAY="[]"
ALL_DEDUCTIONS="[]"

while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  [[ ! -f "$file" ]] && continue

  score=$(jq -r '.score // 0' "$file" 2>/dev/null || echo "0")
  session_id=$(jq -r '.session_id // "unknown"' "$file" 2>/dev/null || echo "unknown")
  timestamp=$(jq -r '.timestamp // ""' "$file" 2>/dev/null || echo "")

  SCORES_ARRAY=$(echo "$SCORES_ARRAY" | jq --argjson s "$score" --arg sid "$session_id" --arg ts "$timestamp" \
    '. + [{"score": $s, "session_id": $sid, "timestamp": $ts}]')

  # Extract deduction categories from this score file
  deductions=$(jq -r '[.deductions[]?.category // empty]' "$file" 2>/dev/null || echo "[]")
  ALL_DEDUCTIONS=$(echo "$ALL_DEDUCTIONS" | jq --argjson d "$deductions" '. + $d')
done <<< "$SCORE_FILES"

# --- Calculate average ---
AVERAGE=$(echo "$SCORES_ARRAY" | jq '[.[].score] | if length > 0 then (add / length | . * 10 | round / 10) else 0 end')

# --- Determine trend direction ---
# Compare first half vs second half of the window
DIRECTION="plateau"

if [[ "$FILE_COUNT" -ge 3 ]]; then
  HALF=$(( FILE_COUNT / 2 ))

  FIRST_HALF_AVG=$(echo "$SCORES_ARRAY" | jq --argjson h "$HALF" \
    '[.[:$h] | .[].score] | if length > 0 then (add / length) else 0 end')
  SECOND_HALF_AVG=$(echo "$SCORES_ARRAY" | jq --argjson h "$HALF" \
    '[.[$h:] | .[].score] | if length > 0 then (add / length) else 0 end')

  DIFF=$(echo "$SECOND_HALF_AVG $FIRST_HALF_AVG" | awk '{printf "%.1f", $1 - $2}')

  # Calculate standard deviation for volatility check
  STDDEV=$(echo "$SCORES_ARRAY" | jq --argjson avg "$AVERAGE" \
    '[.[].score | . - $avg | . * .] | if length > 0 then (add / length | sqrt | . * 10 | round / 10) else 0 end')

  if (( $(echo "$STDDEV > 15" | bc -l 2>/dev/null || echo "0") )); then
    DIRECTION="volatile"
  elif (( $(echo "$DIFF > 5" | bc -l 2>/dev/null || echo "0") )); then
    DIRECTION="improving"
  elif (( $(echo "$DIFF < -5" | bc -l 2>/dev/null || echo "0") )); then
    DIRECTION="declining"
  else
    DIRECTION="plateau"
  fi
fi

# --- Find recurring patterns (appear in 3+ sessions) ---
TOP_PATTERNS=$(echo "$ALL_DEDUCTIONS" | jq '
  group_by(.) |
  map({category: .[0], count: length}) |
  sort_by(-.count) |
  [.[] | select(.count >= 2)] |
  .[:5]
')

# Check if any pattern appears in 3+ sessions (mark as recurring)
HAS_RECURRING=$(echo "$TOP_PATTERNS" | jq '[.[] | select(.count >= 3)] | length')
if [[ "$HAS_RECURRING" -gt 0 && "$DIRECTION" == "plateau" ]]; then
  DIRECTION="recurring"
fi

# --- Satisfaction correlation (if user_feedback exists) ---
SATISFACTION_CORR="null"
HAS_FEEDBACK=$(echo "$SCORE_FILES" | head -1 | xargs -I{} jq -r '.user_feedback // empty' {} 2>/dev/null || echo "")
if [[ -n "$HAS_FEEDBACK" ]]; then
  SATISFACTION_CORR=$(echo "$SCORE_FILES" | while IFS= read -r file; do
    [[ -z "$file" || ! -f "$file" ]] && continue
    jq -r 'select(.user_feedback != null) | "\(.score) \(.user_feedback.rating)"' "$file" 2>/dev/null
  done | awk '
    BEGIN { n=0; sx=0; sy=0; sxy=0; sx2=0; sy2=0 }
    { n++; sx+=$1; sy+=$2; sxy+=($1*$2); sx2+=($1*$1); sy2+=($2*$2) }
    END {
      if (n < 3) { print "null"; exit }
      denom = sqrt((n*sx2 - sx*sx) * (n*sy2 - sy*sy))
      if (denom == 0) { print "null"; exit }
      printf "%.2f", (n*sxy - sx*sy) / denom
    }
  ' 2>/dev/null || echo "null")
fi

# --- Output trend JSON ---
jq -n \
  --arg dir "$DIRECTION" \
  --argjson ws "$FILE_COUNT" \
  --argjson avg "$AVERAGE" \
  --argjson scores "$SCORES_ARRAY" \
  --argjson patterns "$TOP_PATTERNS" \
  --argjson sat_corr "${SATISFACTION_CORR:-null}" \
  '{
    direction: $dir,
    window_size: $ws,
    average_score: $avg,
    scores: $scores,
    top_recurring_patterns: $patterns,
    satisfaction_correlation: $sat_corr
  }'

exit 0
