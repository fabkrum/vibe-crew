#!/usr/bin/env bash
# scripts/award-xp.sh
# Calculate and award XP from session data after /wrap
# Reads the latest score file and session state to determine XP awards
# Updates gamification.json with earned XP
# Exit 0 on success, Exit 1 on failure

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBEOS_DIR="$PROJECT_ROOT/.vibeos"
GAMIFICATION_FILE="$VIBEOS_DIR/gamification.json"
STATE_FILE="$VIBEOS_DIR/state.json"
BACKLOG_FILE="$VIBEOS_DIR/backlog.json"

# --- Check gamification is enabled ---
ENABLED=$(jq -r '.gamification.enabled // true' "$VIBEOS_DIR/config.json" 2>/dev/null || echo "true")
if [[ "$ENABLED" == "false" ]]; then
  echo '{"xp_awarded":0,"breakdown":[],"message":"Gamification disabled"}'
  exit 0
fi

# --- Verify gamification.json exists ---
if [[ ! -f "$GAMIFICATION_FILE" ]]; then
  echo "Error: gamification.json not found. Run /setup first." >&2
  exit 1
fi

# --- Find latest score file ---
TODAY=$(date -u +%Y-%m-%d)
LATEST_SCORE=""
if [[ -d "$VIBEOS_DIR/scores" ]]; then
  LATEST_SCORE=$(ls -1t "$VIBEOS_DIR/scores"/score-*.json 2>/dev/null | head -1)
fi

if [[ -z "$LATEST_SCORE" ]]; then
  echo '{"xp_awarded":0,"breakdown":[],"message":"No score file found"}'
  exit 0
fi

# --- Read score data ---
VIBE_SCORE=$(jq -r '.score // 0' "$LATEST_SCORE" 2>/dev/null || echo "0")
TOTAL_DEDUCTIONS=$(jq '[.deductions[].points] | map(. * -1) | add // 0' "$LATEST_SCORE" 2>/dev/null || echo "0")

# --- Calculate XP breakdown ---
XP_TOTAL=0
BREAKDOWN="[]"

# 1. Base session XP: +10 for completing /wrap
XP_SESSION=10
XP_TOTAL=$((XP_TOTAL + XP_SESSION))
BREAKDOWN=$(echo "$BREAKDOWN" | jq --argjson xp "$XP_SESSION" '. + [{"source":"session_complete","xp":$xp,"reason":"Session completed with /wrap"}]')

# 2. Vibe Score bonus: +(score - 50) if score > 50
XP_SCORE_BONUS=0
if [[ "$VIBE_SCORE" -gt 50 ]]; then
  XP_SCORE_BONUS=$((VIBE_SCORE - 50))
  XP_TOTAL=$((XP_TOTAL + XP_SCORE_BONUS))
  BREAKDOWN=$(echo "$BREAKDOWN" | jq --argjson xp "$XP_SCORE_BONUS" --argjson score "$VIBE_SCORE" '. + [{"source":"vibe_score_bonus","xp":$xp,"reason":"Vibe Score \($score) > 50"}]')
fi

# 3. Clean session bonus: +25 if 0 deductions
if [[ "$TOTAL_DEDUCTIONS" -eq 0 ]]; then
  XP_CLEAN=25
  XP_TOTAL=$((XP_TOTAL + XP_CLEAN))
  BREAKDOWN=$(echo "$BREAKDOWN" | jq --argjson xp "$XP_CLEAN" '. + [{"source":"clean_session","xp":$xp,"reason":"Zero deductions — clean session"}]')
fi

# 4. Phase completion bonus: +5 per Tier 2 phase completed this session
PHASES_COMPLETED=$(jq -r '.active_feature.phases_completed // [] | length' "$STATE_FILE" 2>/dev/null || echo "0")
if [[ "$PHASES_COMPLETED" -gt 0 ]]; then
  # Check how many phases were newly completed (compare with gamification stats)
  # For simplicity, award based on phases in the active feature
  PHASE_NAMES=$(jq -r '.active_feature.phases_completed // [] | join(",")' "$STATE_FILE" 2>/dev/null || echo "")
  if [[ -n "$PHASE_NAMES" ]]; then
    PHASE_COUNT=$(echo "$PHASE_NAMES" | tr ',' '\n' | wc -l | tr -d ' ')
    XP_PHASES=$((PHASE_COUNT * 5))
    XP_TOTAL=$((XP_TOTAL + XP_PHASES))
    BREAKDOWN=$(echo "$BREAKDOWN" | jq --argjson xp "$XP_PHASES" --argjson count "$PHASE_COUNT" '. + [{"source":"phase_completion","xp":$xp,"reason":"\($count) Tier 2 phase(s) completed"}]')
  fi
fi

# 5. Feature shipped bonus: +50 if feature moved to done
if [[ -f "$BACKLOG_FILE" ]]; then
  ACTIVE_FEATURE_ID=$(jq -r '.active_feature.id // empty' "$STATE_FILE" 2>/dev/null || echo "")
  if [[ -n "$ACTIVE_FEATURE_ID" ]]; then
    FEATURE_COLUMN=$(jq -r --arg id "$ACTIVE_FEATURE_ID" '.features[] | select(.id == $id) | .column' "$BACKLOG_FILE" 2>/dev/null || echo "")
    FEATURE_PHASES=$(jq -r '.active_feature.phases_completed // [] | length' "$STATE_FILE" 2>/dev/null || echo "0")
    if [[ "$FEATURE_COLUMN" == "done" ]] || [[ "$FEATURE_COLUMN" == "review" && "$FEATURE_PHASES" -ge 5 ]]; then
      XP_SHIP=50
      XP_TOTAL=$((XP_TOTAL + XP_SHIP))
      BREAKDOWN=$(echo "$BREAKDOWN" | jq --argjson xp "$XP_SHIP" '. + [{"source":"feature_shipped","xp":$xp,"reason":"Feature shipped (all 5 phases)"}]')
    fi
  fi
fi

# 6. Foundation complete bonus: +100
FOUNDATION_COMPLETE=$(jq -r '.foundation.complete // false' "$STATE_FILE" 2>/dev/null || echo "false")
ALREADY_GOT_FOUNDATION=$(jq -r '.stats.total_features_shipped == 0 and .level >= 1' "$GAMIFICATION_FILE" 2>/dev/null || echo "false")
# Only award once — check if we have a foundation badge already
HAS_FOUNDATION_BADGE=$(jq '[.badges[] | select(.id == "first-foundation")] | length' "$GAMIFICATION_FILE" 2>/dev/null || echo "0")
if [[ "$FOUNDATION_COMPLETE" == "true" && "$HAS_FOUNDATION_BADGE" -eq 0 ]]; then
  XP_FOUNDATION=100
  XP_TOTAL=$((XP_TOTAL + XP_FOUNDATION))
  BREAKDOWN=$(echo "$BREAKDOWN" | jq --argjson xp "$XP_FOUNDATION" '. + [{"source":"foundation_complete","xp":$xp,"reason":"Tier 1 foundation completed"}]')
fi

# 7. Tests pass on first run bonus: +15
TESTS_PASSED=$(jq -r '.metrics.quality.tests_passed // false' "$LATEST_SCORE" 2>/dev/null || echo "false")
TESTS_FAILED=$(jq -r '.metrics.quality.tests_failed // 0' "$LATEST_SCORE" 2>/dev/null || echo "0")
# Consider "first run" as having tests_passed=true in the final score (no retries detected)
if [[ "$TESTS_PASSED" == "true" ]]; then
  XP_TESTS=15
  XP_TOTAL=$((XP_TOTAL + XP_TESTS))
  BREAKDOWN=$(echo "$BREAKDOWN" | jq --argjson xp "$XP_TESTS" '. + [{"source":"tests_first_pass","xp":$xp,"reason":"All tests passed"}]')
fi

# --- Apply XP to gamification.json ---
CURRENT_XP=$(jq -r '.xp // 0' "$GAMIFICATION_FILE")
CURRENT_LEVEL=$(jq -r '.level // 1' "$GAMIFICATION_FILE")
CURRENT_XP_THIS_LEVEL=$(jq -r '.xp_this_level // 0' "$GAMIFICATION_FILE")
NEW_XP=$((CURRENT_XP + XP_TOTAL))
NEW_XP_THIS_LEVEL=$((CURRENT_XP_THIS_LEVEL + XP_TOTAL))

# Update stats
CURRENT_SESSIONS=$(jq -r '.stats.total_sessions // 0' "$GAMIFICATION_FILE")
NEW_SESSIONS=$((CURRENT_SESSIONS + 1))
CURRENT_BEST=$(jq -r '.stats.best_vibe_score // 0' "$GAMIFICATION_FILE")
NEW_BEST=$CURRENT_BEST
if [[ "$VIBE_SCORE" -gt "$CURRENT_BEST" ]]; then
  NEW_BEST=$VIBE_SCORE
fi

# Track perfect sessions
CURRENT_PERFECT=$(jq -r '.stats.perfect_sessions // 0' "$GAMIFICATION_FILE")
NEW_PERFECT=$CURRENT_PERFECT
if [[ "$VIBE_SCORE" -ge 90 && "$TOTAL_DEDUCTIONS" -eq 0 ]]; then
  NEW_PERFECT=$((CURRENT_PERFECT + 1))
fi

# Update score history (keep last 30 entries)
SCORE_ENTRY="{\"date\":\"$TODAY\",\"score\":$VIBE_SCORE}"

TMP_FILE="${GAMIFICATION_FILE}.tmp"
jq --argjson xp "$NEW_XP" \
   --argjson xp_this "$NEW_XP_THIS_LEVEL" \
   --argjson sessions "$NEW_SESSIONS" \
   --argjson best "$NEW_BEST" \
   --argjson perfect "$NEW_PERFECT" \
   --argjson score_entry "$SCORE_ENTRY" \
   '
   .xp = $xp |
   .xp_this_level = $xp_this |
   .stats.total_sessions = $sessions |
   .stats.best_vibe_score = $best |
   .stats.perfect_sessions = $perfect |
   .stats.score_history = ((.stats.score_history // []) + [$score_entry] | .[-30:])
   ' "$GAMIFICATION_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$GAMIFICATION_FILE"

# --- Output result ---
jq -n --argjson total "$XP_TOTAL" --argjson breakdown "$BREAKDOWN" \
  '{xp_awarded: $total, breakdown: $breakdown}'

exit 0
