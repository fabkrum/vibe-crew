#!/usr/bin/env bash
# scripts/check-badges.sh
# Evaluate badge conditions after each /wrap
# Reads badge-catalog.json and checks current state against conditions
# Awards badges that are newly earned, skips already-earned badges
# Exit 0 on success, Exit 1 on failure

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"
GAMIFICATION_FILE="$VIBECREW_DIR/gamification.json"
STATE_FILE="$VIBECREW_DIR/state.json"
BACKLOG_FILE="$VIBECREW_DIR/backlog.json"
BADGE_CATALOG="$PLUGIN_ROOT/templates/badge-catalog.json"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# --- Check gamification is enabled ---
ENABLED=$(jq -r '.gamification.enabled // true' "$VIBECREW_DIR/config.json" 2>/dev/null || echo "true")
if [[ "$ENABLED" == "false" ]]; then
  echo '{"badges_earned":[],"message":"Gamification disabled"}'
  exit 0
fi

if [[ ! -f "$GAMIFICATION_FILE" ]]; then
  echo "Error: gamification.json not found." >&2
  exit 1
fi

if [[ ! -f "$BADGE_CATALOG" ]]; then
  echo "Error: badge-catalog.json not found at $BADGE_CATALOG" >&2
  exit 1
fi

# --- Get already-earned badge IDs ---
EARNED_IDS=$(jq -r '[.badges[].id] | join(",")' "$GAMIFICATION_FILE" 2>/dev/null || echo "")

# --- Get latest score file ---
LATEST_SCORE=""
if [[ -d "$VIBECREW_DIR/scores" ]]; then
  LATEST_SCORE=$(ls -1t "$VIBECREW_DIR/scores"/score-*.json 2>/dev/null | head -1)
fi

# --- Read current state ---
VIBE_SCORE=0
TOTAL_DEDUCTIONS=0
CACHE_RATIO=0
CHURN_SEQUENCES=0
PEAK_CONTEXT=0

if [[ -n "$LATEST_SCORE" ]]; then
  VIBE_SCORE=$(jq -r '.score // 0' "$LATEST_SCORE")
  TOTAL_DEDUCTIONS=$(jq '[.deductions[].points] | map(. * -1) | add // 0' "$LATEST_SCORE")
  CACHE_RATIO=$(jq -r '.metrics.tokens.cache_ratio // 0' "$LATEST_SCORE")
  CHURN_SEQUENCES=$(jq -r '.metrics.prompt_churn.sequences // 0' "$LATEST_SCORE")
  PEAK_CONTEXT=$(jq -r '.metrics.context.peak_usage_percent // 0' "$LATEST_SCORE")
fi

FOUNDATION_COMPLETE=$(jq -r '.foundation.complete // false' "$STATE_FILE" 2>/dev/null || echo "false")
TOTAL_SESSIONS=$(jq -r '.stats.total_sessions // 0' "$GAMIFICATION_FILE")
TOTAL_FEATURES=$(jq -r '.stats.total_features_shipped // 0' "$GAMIFICATION_FILE")
PERFECT_SESSIONS=$(jq -r '.stats.perfect_sessions // 0' "$GAMIFICATION_FILE")
BEST_SCORE=$(jq -r '.stats.best_vibe_score // 0' "$GAMIFICATION_FILE")
CURRENT_STREAK=$(jq -r '.streak.current // 0' "$GAMIFICATION_FILE")

# --- Count consecutive 90+ scores from history ---
CONSECUTIVE_90=$(jq -r '
  [.stats.score_history // [] | reverse | .[] | select(.score >= 90)] |
  length as $total |
  if $total == 0 then 0
  else
    [.stats.score_history // [] | reverse | .[] |
     .score >= 90] |
    [., [false]] | add |
    [limit(1; indices(false))] | .[0] // $total
  end
' "$GAMIFICATION_FILE" 2>/dev/null || echo "0")

# Better consecutive count: count from end until first non-90+ score
CONSECUTIVE_90=$(jq -r '
  [(.stats.score_history // []) | reverse | .[].score] |
  reduce .[] as $s (0; if $s >= 90 and . >= 0 then . + 1 else -1 end) |
  if . < 0 then (. + 1) * -1 | . - 1
  else . end
' "$GAMIFICATION_FILE" 2>/dev/null || echo "0")

# Simpler approach: count trailing 90+ scores
CONSECUTIVE_90=$(jq '
  [(.stats.score_history // []) | .[].score] | reverse |
  until(length == 0 or .[0] < 90; .[1:]) |
  (([(.stats.score_history // []) | .[].score] | length) - length)
' "$GAMIFICATION_FILE" 2>/dev/null || echo "0")

# --- Count sessions with high cache (>70%) ---
HIGH_CACHE_SESSIONS=$(jq '
  [(.stats.score_history // [])] | length
' "$GAMIFICATION_FILE" 2>/dev/null || echo "0")
# We need score files for detailed metric analysis, use score_history for count approximation
# For accurate badge tracking, count from score files
HIGH_CACHE_COUNT=0
ZERO_CHURN_COUNT=0
LOW_CONTEXT_COUNT=0
if [[ -d "$VIBECREW_DIR/scores" ]]; then
  for sf in "$VIBECREW_DIR/scores"/score-*.json; do
    [[ -f "$sf" ]] || continue
    cr=$(jq -r '.metrics.tokens.cache_ratio // 0' "$sf" 2>/dev/null || echo "0")
    cs=$(jq -r '.metrics.prompt_churn.sequences // 0' "$sf" 2>/dev/null || echo "0")
    pc=$(jq -r '.metrics.context.peak_usage_percent // 100' "$sf" 2>/dev/null || echo "100")
    # awk for float comparison
    if awk "BEGIN{exit !($cr > 0.70)}"; then
      HIGH_CACHE_COUNT=$((HIGH_CACHE_COUNT + 1))
    fi
    if [[ "$cs" -eq 0 ]]; then
      ZERO_CHURN_COUNT=$((ZERO_CHURN_COUNT + 1))
    fi
    if awk "BEGIN{exit !($pc < 50)}"; then
      LOW_CONTEXT_COUNT=$((LOW_CONTEXT_COUNT + 1))
    fi
  done
fi

# --- Check previous score for comeback badge ---
PREV_SCORE=100
SCORE_HISTORY_LEN=$(jq '[.stats.score_history // []] | .[0] | length' "$GAMIFICATION_FILE" 2>/dev/null || echo "0")
if [[ "$SCORE_HISTORY_LEN" -ge 2 ]]; then
  PREV_SCORE=$(jq '.stats.score_history[-2].score // 100' "$GAMIFICATION_FILE" 2>/dev/null || echo "100")
fi

# --- Evaluate each badge ---
NEW_BADGES="[]"
XP_FROM_BADGES=0

check_badge() {
  local badge_id="$1"
  local badge_name="$2"
  local xp_reward="$3"
  local earned=false

  # Skip if already earned
  if echo ",$EARNED_IDS," | grep -q ",$badge_id,"; then
    return
  fi

  case "$badge_id" in
    "first-setup")
      # Awarded during /setup, not here
      return ;;
    "first-foundation")
      [[ "$FOUNDATION_COMPLETE" == "true" ]] && earned=true ;;
    "first-feature")
      [[ "$TOTAL_FEATURES" -ge 1 ]] && earned=true ;;
    "five-features")
      [[ "$TOTAL_FEATURES" -ge 5 ]] && earned=true ;;
    "first-tdr")
      # Check if TDR artifact is complete in state.json
      TDR_STATUS=$(jq -r '.foundation.artifacts.tdr.status // "pending"' "$STATE_FILE" 2>/dev/null || echo "pending")
      [[ "$TDR_STATUS" == "complete" ]] && earned=true ;;
    "clean-session")
      [[ "$VIBE_SCORE" -ge 90 && "$TOTAL_DEDUCTIONS" -eq 0 ]] && earned=true ;;
    "clean-streak-3")
      [[ "$CONSECUTIVE_90" -ge 3 ]] && earned=true ;;
    "clean-streak-10")
      [[ "$CONSECUTIVE_90" -ge 10 ]] && earned=true ;;
    "high-cache")
      [[ "$HIGH_CACHE_COUNT" -ge 5 ]] && earned=true ;;
    "zero-churn")
      [[ "$ZERO_CHURN_COUNT" -ge 10 ]] && earned=true ;;
    "context-ninja")
      [[ "$LOW_CONTEXT_COUNT" -ge 10 ]] && earned=true ;;
    "perfect-100")
      [[ "$VIBE_SCORE" -eq 100 ]] && earned=true ;;
    "comeback")
      [[ "$PREV_SCORE" -lt 50 && "$VIBE_SCORE" -ge 90 ]] && earned=true ;;
    "week-streak-7")
      [[ "$CURRENT_STREAK" -ge 7 ]] && earned=true ;;
    "month-streak-30")
      [[ "$CURRENT_STREAK" -ge 30 ]] && earned=true ;;
    "tdd-warrior")
      # Would need per-feature TDD tracking; skip for now
      return ;;
  esac

  if [[ "$earned" == "true" ]]; then
    NEW_BADGES=$(echo "$NEW_BADGES" | jq --arg id "$badge_id" --arg name "$badge_name" --argjson xp "$xp_reward" --arg ts "$TIMESTAMP" \
      '. + [{"id": $id, "name": $name, "xp_reward": $xp, "earned_at": $ts}]')
    XP_FROM_BADGES=$((XP_FROM_BADGES + xp_reward))
  fi
}

# --- Iterate through badge catalog ---
BADGE_COUNT=$(jq '.badges | length' "$BADGE_CATALOG")
for ((i = 0; i < BADGE_COUNT; i++)); do
  BADGE_ID=$(jq -r ".badges[$i].id" "$BADGE_CATALOG")
  BADGE_NAME=$(jq -r ".badges[$i].name" "$BADGE_CATALOG")
  BADGE_XP=$(jq -r ".badges[$i].xp_reward // 0" "$BADGE_CATALOG")
  check_badge "$BADGE_ID" "$BADGE_NAME" "$BADGE_XP"
done

# --- Write newly earned badges to gamification.json ---
NEW_BADGE_COUNT=$(echo "$NEW_BADGES" | jq 'length')
if [[ "$NEW_BADGE_COUNT" -gt 0 ]]; then
  # Add badges and bonus XP
  TMP_FILE="${GAMIFICATION_FILE}.tmp"
  jq --argjson new_badges "$NEW_BADGES" \
     --argjson badge_xp "$XP_FROM_BADGES" \
     '
     .badges = (.badges + [$new_badges[] | {id: .id, earned_at: .earned_at}]) |
     .xp = (.xp + $badge_xp) |
     .xp_this_level = (.xp_this_level + $badge_xp)
     ' "$GAMIFICATION_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$GAMIFICATION_FILE"
fi

# --- Output result ---
jq -n --argjson badges "$NEW_BADGES" --argjson total_xp "$XP_FROM_BADGES" \
  '{badges_earned: $badges, xp_from_badges: $total_xp}'

exit 0
