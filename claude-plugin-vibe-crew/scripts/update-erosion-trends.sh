#!/usr/bin/env bash
# scripts/update-erosion-trends.sh
# Rolling 20-session trend analysis, file churn tracking, alert detection.
# Usage: update-erosion-trends.sh [project_root]
# Output: Updated trends summary to stdout
# Exit 0 on success

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
EROSION_DIR="$PROJECT_ROOT/.vibecrew/erosion"
TRENDS_FILE="$EROSION_DIR/trends.json"
CONFIG_FILE="$PROJECT_ROOT/.vibecrew/config.json"

mkdir -p "$EROSION_DIR"

# --- Read config thresholds ---
RAPID_DECLINE_POINTS=15
RAPID_DECLINE_SESSIONS=3
HOT_FILE_CHURN=5

if [[ -f "$CONFIG_FILE" ]]; then
  RAPID_DECLINE_POINTS=$(jq -r '.erosion.rapid_decline_points // 15' "$CONFIG_FILE" 2>/dev/null || echo "15")
  RAPID_DECLINE_SESSIONS=$(jq -r '.erosion.rapid_decline_sessions // 3' "$CONFIG_FILE" 2>/dev/null || echo "3")
  HOT_FILE_CHURN=$(jq -r '.erosion.hot_file_churn_count // 5' "$CONFIG_FILE" 2>/dev/null || echo "5")
fi

# --- Collect recent erosion snapshots (last 20) ---
SNAPSHOTS=()
for f in $(find "$EROSION_DIR" -maxdepth 1 -name 'erosion-*.json' 2>/dev/null | sort -r | head -20); do
  SNAPSHOTS+=("$f")
done

if [[ ${#SNAPSHOTS[@]} -eq 0 ]]; then
  echo "No erosion snapshots found. Nothing to trend."
  exit 0
fi

# --- Calculate rolling averages ---
TOTAL_SCORE=0
SCORES=()
for snap in "${SNAPSHOTS[@]}"; do
  S=$(jq -r '.score // 100' "$snap" 2>/dev/null || echo "100")
  TOTAL_SCORE=$((TOTAL_SCORE + S))
  SCORES+=("$S")
done

WINDOW_SIZE=${#SNAPSHOTS[@]}
AVG_SCORE=$((TOTAL_SCORE / WINDOW_SIZE))

# Determine trend direction
DIRECTION="stable"
if [[ "$WINDOW_SIZE" -ge 3 ]]; then
  # Compare first half to second half
  HALF=$((WINDOW_SIZE / 2))
  FIRST_HALF_SUM=0
  SECOND_HALF_SUM=0
  for ((i=0; i<HALF; i++)); do
    FIRST_HALF_SUM=$((FIRST_HALF_SUM + ${SCORES[i]}))
  done
  for ((i=HALF; i<WINDOW_SIZE; i++)); do
    SECOND_HALF_SUM=$((SECOND_HALF_SUM + ${SCORES[i]}))
  done
  FIRST_AVG=$((FIRST_HALF_SUM / HALF))
  SECOND_AVG=$((SECOND_HALF_SUM / (WINDOW_SIZE - HALF)))

  if [[ $((FIRST_AVG - SECOND_AVG)) -gt 5 ]]; then
    DIRECTION="improving"
  elif [[ $((SECOND_AVG - FIRST_AVG)) -gt 5 ]]; then
    DIRECTION="declining"
  fi
fi

# --- Track file churn ---
# Read existing churn data or initialize
FILE_CHURN="{}"
if [[ -f "$TRENDS_FILE" ]]; then
  FILE_CHURN=$(jq -c '.file_churn // {}' "$TRENDS_FILE" 2>/dev/null || echo "{}")
fi

# Update churn from latest snapshot
LATEST_SNAP="${SNAPSHOTS[0]}"
MODIFIED_FILES=$(jq -r '.metrics.file_metrics[]?.file // empty' "$LATEST_SNAP" 2>/dev/null || true)
while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  CURRENT_COUNT=$(echo "$FILE_CHURN" | jq -r --arg f "$file" '.[$f].count // 0' 2>/dev/null || echo "0")
  CURRENT_COUNT=$((CURRENT_COUNT + 1))
  FILE_CHURN=$(echo "$FILE_CHURN" | jq --arg f "$file" --argjson c "$CURRENT_COUNT" \
    '.[$f].count = $c | .[$f].last_modified = (now | todate)')
done <<< "$MODIFIED_FILES"

# --- Detect rapid decline alert ---
ALERT=""
if [[ "$WINDOW_SIZE" -ge "$RAPID_DECLINE_SESSIONS" ]]; then
  # Check if recent N sessions show rapid decline
  RECENT_SUM=0
  for ((i=0; i<RAPID_DECLINE_SESSIONS && i<WINDOW_SIZE; i++)); do
    RECENT_SUM=$((RECENT_SUM + ${SCORES[i]}))
  done
  RECENT_AVG=$((RECENT_SUM / RAPID_DECLINE_SESSIONS))

  OLDER_SUM=0
  OLDER_COUNT=0
  for ((i=RAPID_DECLINE_SESSIONS; i<WINDOW_SIZE; i++)); do
    OLDER_SUM=$((OLDER_SUM + ${SCORES[i]}))
    OLDER_COUNT=$((OLDER_COUNT + 1))
  done

  if [[ "$OLDER_COUNT" -gt 0 ]]; then
    OLDER_AVG=$((OLDER_SUM / OLDER_COUNT))
    DECLINE=$((OLDER_AVG - RECENT_AVG))
    if [[ "$DECLINE" -ge "$RAPID_DECLINE_POINTS" ]]; then
      ALERT="rapid-decline"
    fi
  fi
fi

# --- Detect hot files ---
HOT_FILES=$(echo "$FILE_CHURN" | jq -c --argjson churn "$HOT_FILE_CHURN" \
  '[to_entries[] | select(.value.count >= $churn and (.value.last_simplified // null) == null) | .key]' 2>/dev/null || echo "[]")

# --- Write trends file ---
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

jq -n \
  --arg ts "$TIMESTAMP" \
  --arg direction "$DIRECTION" \
  --argjson window "$WINDOW_SIZE" \
  --argjson avg "$AVG_SCORE" \
  --argjson churn "$FILE_CHURN" \
  --argjson hot "$HOT_FILES" \
  --arg alert "$ALERT" \
  '{
    schema_version: "1.0.0",
    updated_at: $ts,
    direction: $direction,
    window_size: $window,
    average_score: $avg,
    file_churn: $churn,
    hot_files: $hot,
    alert: (if $alert == "" then null else $alert end)
  }' > "$TRENDS_FILE"

# --- Output summary ---
echo "Erosion trend: $DIRECTION over $WINDOW_SIZE sessions (avg $AVG_SCORE/100)"
HOT_COUNT=$(echo "$HOT_FILES" | jq 'length' 2>/dev/null || echo "0")
if [[ "$HOT_COUNT" -gt 0 ]]; then
  echo "  Hot files ($HOT_COUNT): $(echo "$HOT_FILES" | jq -r 'join(", ")' 2>/dev/null)"
fi
if [[ -n "$ALERT" ]]; then
  echo "  ALERT: $ALERT — consider a dedicated simplification session"
fi
