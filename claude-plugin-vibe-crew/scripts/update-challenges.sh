#!/usr/bin/env bash
# scripts/update-challenges.sh
# Update challenge progress after /wrap
# Checks each active challenge against session metrics
# Completes challenges that meet their conditions
# Exit 0 on success, Exit 1 on failure

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"
GAMIFICATION_FILE="$VIBECREW_DIR/gamification.json"
STATE_FILE="$VIBECREW_DIR/state.json"
BACKLOG_FILE="$VIBECREW_DIR/backlog.json"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# --- Check gamification is enabled ---
ENABLED=$(jq -r '.gamification.enabled // true' "$VIBECREW_DIR/config.json" 2>/dev/null || echo "true")
if [[ "$ENABLED" == "false" ]]; then
  echo '{"challenges_completed":[],"message":"Gamification disabled"}'
  exit 0
fi

if [[ ! -f "$GAMIFICATION_FILE" ]]; then
  echo '{"challenges_completed":[],"message":"gamification.json not found"}'
  exit 0
fi

# --- Find latest score file ---
LATEST_SCORE=""
if [[ -d "$VIBECREW_DIR/scores" ]]; then
  LATEST_SCORE=$(ls -1t "$VIBECREW_DIR/scores"/score-*.json 2>/dev/null | head -1)
fi

if [[ -z "$LATEST_SCORE" ]]; then
  echo '{"challenges_completed":[],"message":"No score file"}'
  exit 0
fi

# --- Read session metrics ---
VIBE_SCORE=$(jq -r '.score // 0' "$LATEST_SCORE")
TOTAL_DEDUCTIONS=$(jq '[.deductions[].points] | map(. * -1) | add // 0' "$LATEST_SCORE")
CACHE_RATIO=$(jq -r '.metrics.tokens.cache_ratio // 0' "$LATEST_SCORE")
CHURN_SEQUENCES=$(jq -r '.metrics.prompt_churn.sequences // 0' "$LATEST_SCORE")
PEAK_CONTEXT=$(jq -r '.metrics.context.peak_usage_percent // 50' "$LATEST_SCORE")
TESTS_PASSED=$(jq -r '.metrics.quality.tests_passed // false' "$LATEST_SCORE")
COVERAGE=$(jq -r '.metrics.quality.coverage_percent // 0' "$LATEST_SCORE")

# Phase info
PHASES_COMPLETED_COUNT=$(jq '[.active_feature.phases_completed // []] | .[0] | length' "$STATE_FILE" 2>/dev/null || echo "0")

# Feature shipped check
FEATURE_SHIPPED=false
ACTIVE_FEATURE_ID=$(jq -r '.active_feature.id // empty' "$STATE_FILE" 2>/dev/null || echo "")
if [[ -n "$ACTIVE_FEATURE_ID" && -f "$BACKLOG_FILE" ]]; then
  FEATURE_COLUMN=$(jq -r --arg id "$ACTIVE_FEATURE_ID" '.features[] | select(.id == $id) | .column' "$BACKLOG_FILE" 2>/dev/null || echo "")
  FEATURE_PHASES=$(jq -r '.active_feature.phases_completed // [] | length' "$STATE_FILE" 2>/dev/null || echo "0")
  if [[ "$FEATURE_COLUMN" == "done" || "$FEATURE_COLUMN" == "review" && "$FEATURE_PHASES" -ge 5 ]]; then
    FEATURE_SHIPPED=true
  fi
fi

# --- Evaluate each active challenge ---
COMPLETED_CHALLENGES="[]"
XP_FROM_CHALLENGES=0

ACTIVE_COUNT=$(jq '.active_challenges | length' "$GAMIFICATION_FILE")

for ((i = ACTIVE_COUNT - 1; i >= 0; i--)); do
  CHALLENGE_ID=$(jq -r ".active_challenges[$i].id" "$GAMIFICATION_FILE")
  CHALLENGE_TYPE=$(jq -r ".active_challenges[$i].type" "$GAMIFICATION_FILE")
  CHALLENGE_XP=$(jq -r ".active_challenges[$i].xp_reward // 0" "$GAMIFICATION_FILE")
  CHALLENGE_NAME=$(jq -r ".active_challenges[$i].name // \"\"" "$GAMIFICATION_FILE")
  MET=false

  # Evaluate condition based on challenge ID pattern
  case "$CHALLENGE_ID" in
    *"clean-sweep"*)
      [[ "$TOTAL_DEDUCTIONS" -eq 0 ]] && MET=true ;;
    *"cache-champion"*)
      awk "BEGIN{exit !($CACHE_RATIO > 0.70)}" && MET=true ;;
    *"no-churn"* | *"clear-channel"*)
      [[ "$CHURN_SEQUENCES" -eq 0 ]] && MET=true ;;
    *"context-light"* | *"light-footprint"*)
      awk "BEGIN{exit !($PEAK_CONTEXT < 40)}" && MET=true ;;
    *"test-pass"* | *"green-light"*)
      [[ "$TESTS_PASSED" == "true" ]] && MET=true ;;
    *"phase-complete"* | *"phase-finisher"*)
      [[ "$PHASES_COMPLETED_COUNT" -gt 0 ]] && MET=true ;;
    *"ship-week"*)
      [[ "$FEATURE_SHIPPED" == "true" ]] && MET=true ;;
    *"perfect-week"*)
      [[ "$VIBE_SCORE" -ge 90 ]] && MET=true ;;
    *"coverage-push"*)
      awk "BEGIN{exit !($COVERAGE > 80)}" && MET=true ;;
    *"blueprint"*)
      # Check if plan phase was completed
      HAS_PLAN=$(jq -r '.active_feature.phases_completed // [] | map(select(. == "plan")) | length > 0' "$STATE_FILE" 2>/dev/null || echo "false")
      [[ "$HAS_PLAN" == "true" ]] && MET=true ;;
    *"speed-ship"*)
      [[ "$FEATURE_SHIPPED" == "true" ]] && MET=true ;;
    *"full-coverage"*)
      awk "BEGIN{exit !($COVERAGE > 90)}" && MET=true ;;
    *"perfect-ten"*)
      # Check consecutive scores from history
      CONSEC=$(jq '
        [(.stats.score_history // []) | .[].score] | reverse |
        until(length == 0 or .[0] < 85; .[1:]) |
        (([(.stats.score_history // []) | .[].score] | length) - length)
      ' "$GAMIFICATION_FILE" 2>/dev/null || echo "0")
      [[ "$CONSEC" -ge 10 ]] && MET=true ;;
    *"context-master"*)
      # Count sessions under 50% context from score files
      COUNT=0
      if [[ -d "$VIBECREW_DIR/scores" ]]; then
        for sf in "$VIBECREW_DIR/scores"/score-*.json; do
          [[ -f "$sf" ]] || continue
          pc=$(jq -r '.metrics.context.peak_usage_percent // 100' "$sf" 2>/dev/null || echo "100")
          awk "BEGIN{exit !($pc < 50)}" && COUNT=$((COUNT + 1))
        done
      fi
      [[ "$COUNT" -ge 20 ]] && MET=true ;;
    *"marathon"*)
      # Would need week-level feature tracking; approximate
      [[ "$FEATURE_SHIPPED" == "true" ]] && MET=true ;;
  esac

  if [[ "$MET" == "true" ]]; then
    COMPLETED_CHALLENGES=$(echo "$COMPLETED_CHALLENGES" | jq \
      --arg id "$CHALLENGE_ID" --arg name "$CHALLENGE_NAME" \
      --argjson xp "$CHALLENGE_XP" --arg ts "$TIMESTAMP" \
      '. + [{"id": $id, "name": $name, "xp_awarded": $xp, "completed_at": $ts}]')
    XP_FROM_CHALLENGES=$((XP_FROM_CHALLENGES + CHALLENGE_XP))

    # Move from active to completed
    TMP_FILE="${GAMIFICATION_FILE}.tmp"
    jq --arg id "$CHALLENGE_ID" --argjson xp "$CHALLENGE_XP" --arg ts "$TIMESTAMP" '
      .active_challenges = [.active_challenges[] | select(.id != $id)] |
      .completed_challenges += [{"id": $id, "completed_at": $ts, "xp_awarded": $xp}] |
      .xp = (.xp + $xp) |
      .xp_this_level = (.xp_this_level + $xp)
    ' "$GAMIFICATION_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$GAMIFICATION_FILE"
  fi
done

# --- Output result ---
jq -n --argjson completed "$COMPLETED_CHALLENGES" --argjson total_xp "$XP_FROM_CHALLENGES" \
  '{challenges_completed: $completed, xp_from_challenges: $total_xp}'

exit 0
