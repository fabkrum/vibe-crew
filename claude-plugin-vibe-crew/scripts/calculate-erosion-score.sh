#!/usr/bin/env bash
# scripts/calculate-erosion-score.sh
# Computes 0-100 erosion score from current metrics vs baseline.
# Usage: calculate-erosion-score.sh [project_root]
# Output: JSON with score, rating, deductions, bonuses
# Exit 0 on success

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
EROSION_DIR="$PROJECT_ROOT/.vibecrew/erosion"
BASELINE_FILE="$EROSION_DIR/baseline.json"
TRENDS_FILE="$EROSION_DIR/trends.json"
CONFIG_FILE="$PROJECT_ROOT/.vibecrew/config.json"

# --- Read thresholds from config ---
FILE_MAX_LOC=300
FUNCTION_MAX_LOC=50
COMPLEXITY_MAX=10
HOT_FILE_CHURN=5

if [[ -f "$CONFIG_FILE" ]]; then
  FILE_MAX_LOC=$(jq -r '.erosion.file_max_loc // 300' "$CONFIG_FILE" 2>/dev/null || echo "300")
  FUNCTION_MAX_LOC=$(jq -r '.erosion.function_max_loc // 50' "$CONFIG_FILE" 2>/dev/null || echo "50")
  COMPLEXITY_MAX=$(jq -r '.erosion.complexity_max // 10' "$CONFIG_FILE" 2>/dev/null || echo "10")
  HOT_FILE_CHURN=$(jq -r '.erosion.hot_file_churn_count // 5' "$CONFIG_FILE" 2>/dev/null || echo "5")
fi

# --- Collect current metrics ---
METRICS=$(bash "$SCRIPT_DIR/collect-erosion-metrics.sh" "$PROJECT_ROOT" 2>/dev/null || echo '{}')
if [[ -z "$METRICS" || "$METRICS" == "{}" ]]; then
  echo '{"score":100,"rating":"healthy","deductions":[],"bonuses":[],"error":"no metrics"}'
  exit 0
fi

# --- Read baseline ---
BASELINE_LOC=0
BASELINE_DEPS=0
if [[ -f "$BASELINE_FILE" ]]; then
  BASELINE_LOC=$(jq -r '.total_project_loc // 0' "$BASELINE_FILE" 2>/dev/null || echo "0")
  BASELINE_DEPS=$(jq -r '.total_dependencies // 0' "$BASELINE_FILE" 2>/dev/null || echo "0")
fi

# --- Read trends for hot file detection ---
HOT_FILES="[]"
if [[ -f "$TRENDS_FILE" ]]; then
  HOT_FILES=$(jq -c --argjson churn "$HOT_FILE_CHURN" \
    '[.file_churn // {} | to_entries[] | select(.value.count >= $churn and (.value.last_simplified // null) == null) | .key]' \
    "$TRENDS_FILE" 2>/dev/null || echo "[]")
fi

# --- Calculate score ---
SCORE=100
DEDUCTIONS="[]"
BONUSES="[]"

CURRENT_LOC=$(echo "$METRICS" | jq -r '.total_project_loc // 0')
CURRENT_DEPS=$(echo "$METRICS" | jq -r '.total_dependencies // 0')
FILES_OVER_LOC=$(echo "$METRICS" | jq -r '.files_over_loc_limit // 0')
FUNCS_OVER_LEN=$(echo "$METRICS" | jq -r '.functions_over_length_limit // 0')
FUNCS_OVER_COMPLEXITY=$(echo "$METRICS" | jq -r '.functions_over_complexity_limit // 0')

# Deduction: files over LOC limit (-2 per file)
if [[ "$FILES_OVER_LOC" -gt 0 ]]; then
  POINTS=$((FILES_OVER_LOC * 2))
  SCORE=$((SCORE - POINTS))
  DEDUCTIONS=$(echo "$DEDUCTIONS" | jq --argjson pts "$POINTS" --argjson count "$FILES_OVER_LOC" --arg limit "$FILE_MAX_LOC" \
    '. + [{"category":"file-size","points": -$pts, "reason": (($count | tostring) + " file(s) over " + $limit + " LOC limit")}]')
fi

# Deduction: functions over length limit (-2 per function)
if [[ "$FUNCS_OVER_LEN" -gt 0 ]]; then
  POINTS=$((FUNCS_OVER_LEN * 2))
  SCORE=$((SCORE - POINTS))
  DEDUCTIONS=$(echo "$DEDUCTIONS" | jq --argjson pts "$POINTS" --argjson count "$FUNCS_OVER_LEN" --arg limit "$FUNCTION_MAX_LOC" \
    '. + [{"category":"function-length","points": -$pts, "reason": (($count | tostring) + " file(s) with functions over " + $limit + " lines")}]')
fi

# Deduction: functions over complexity limit (-2 per function)
if [[ "$FUNCS_OVER_COMPLEXITY" -gt 0 ]]; then
  POINTS=$((FUNCS_OVER_COMPLEXITY * 2))
  SCORE=$((SCORE - POINTS))
  DEDUCTIONS=$(echo "$DEDUCTIONS" | jq --argjson pts "$POINTS" --argjson count "$FUNCS_OVER_COMPLEXITY" --arg limit "$COMPLEXITY_MAX" \
    '. + [{"category":"complexity","points": -$pts, "reason": (($count | tostring) + " file(s) with complexity over " + $limit)}]')
fi

# Deduction: dependency spike (-5 if >3 new deps since baseline)
if [[ "$BASELINE_DEPS" -gt 0 ]]; then
  DEP_DIFF=$((CURRENT_DEPS - BASELINE_DEPS))
  if [[ "$DEP_DIFF" -gt 3 ]]; then
    SCORE=$((SCORE - 5))
    DEDUCTIONS=$(echo "$DEDUCTIONS" | jq --argjson diff "$DEP_DIFF" \
      '. + [{"category":"dependency-spike","points":-5,"reason": (($diff | tostring) + " new dependencies since baseline")}]')
  fi
fi

# Deduction: hot files (-3 per file)
HOT_FILE_COUNT=$(echo "$HOT_FILES" | jq 'length' 2>/dev/null || echo "0")
if [[ "$HOT_FILE_COUNT" -gt 0 ]]; then
  POINTS=$((HOT_FILE_COUNT * 3))
  SCORE=$((SCORE - POINTS))
  DEDUCTIONS=$(echo "$DEDUCTIONS" | jq --argjson pts "$POINTS" --argjson count "$HOT_FILE_COUNT" \
    '. + [{"category":"hot-files","points": -$pts, "reason": (($count | tostring) + " hot file(s) modified 5+ times without /simplify")}]')
fi

# Bonus: LOC decreased (+3)
if [[ "$BASELINE_LOC" -gt 0 && "$CURRENT_LOC" -lt "$BASELINE_LOC" ]]; then
  SCORE=$((SCORE + 3))
  BONUSES=$(echo "$BONUSES" | jq \
    '. + [{"category":"loc-decreased","points":3,"reason":"Total LOC decreased from baseline"}]')
fi

# Bonus: dependencies reduced (+2)
if [[ "$BASELINE_DEPS" -gt 0 && "$CURRENT_DEPS" -lt "$BASELINE_DEPS" ]]; then
  SCORE=$((SCORE + 2))
  BONUSES=$(echo "$BONUSES" | jq \
    '. + [{"category":"deps-reduced","points":2,"reason":"Dependencies reduced from baseline"}]')
fi

# Clamp score
[[ "$SCORE" -gt 100 ]] && SCORE=100
[[ "$SCORE" -lt 0 ]] && SCORE=0

# Determine rating
RATING="healthy"
if [[ "$SCORE" -lt 90 ]]; then RATING="moderate"; fi
if [[ "$SCORE" -lt 70 ]]; then RATING="concerning"; fi
if [[ "$SCORE" -lt 50 ]]; then RATING="critical"; fi

# --- Output ---
jq -n \
  --argjson score "$SCORE" \
  --arg rating "$RATING" \
  --argjson deductions "$DEDUCTIONS" \
  --argjson bonuses "$BONUSES" \
  --argjson metrics "$METRICS" \
  --argjson hot_files "$HOT_FILES" \
  '{
    score: $score,
    rating: $rating,
    deductions: $deductions,
    bonuses: $bonuses,
    hot_files: $hot_files,
    metrics: $metrics
  }'
