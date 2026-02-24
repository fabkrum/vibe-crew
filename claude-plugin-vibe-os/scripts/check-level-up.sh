#!/usr/bin/env bash
# scripts/check-level-up.sh
# Check if the player has enough XP to level up
# Applies leveling curve: XP_needed = floor(100 * 1.15^(level-1))
# Updates gamification.json with new level and unlocked features
# Exit 0 on success, Exit 1 on failure

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBEOS_DIR="$PROJECT_ROOT/.vibeos"
GAMIFICATION_FILE="$VIBEOS_DIR/gamification.json"

# --- Check gamification is enabled ---
ENABLED=$(jq -r '.gamification.enabled // true' "$VIBEOS_DIR/config.json" 2>/dev/null || echo "true")
if [[ "$ENABLED" == "false" ]]; then
  echo '{"leveled_up":false,"message":"Gamification disabled"}'
  exit 0
fi

if [[ ! -f "$GAMIFICATION_FILE" ]]; then
  echo "Error: gamification.json not found." >&2
  exit 1
fi

# --- Read current state ---
CURRENT_LEVEL=$(jq -r '.level // 1' "$GAMIFICATION_FILE")
XP_THIS_LEVEL=$(jq -r '.xp_this_level // 0' "$GAMIFICATION_FILE")
XP_TO_NEXT=$(jq -r '.xp_to_next_level // 100' "$GAMIFICATION_FILE")

# --- Calculate XP needed for a given level ---
# XP_needed = floor(100 * 1.15^(level-1))
# Using awk for floating point math
calc_xp_needed() {
  local level=$1
  awk -v lvl="$level" 'BEGIN { printf "%d", int(100 * (1.15 ^ (lvl - 1))) }'
}

# --- Level title lookup ---
get_level_title() {
  local level=$1
  if [[ $level -eq 1 ]]; then echo "Newcomer"
  elif [[ $level -le 3 ]]; then echo "Apprentice"
  elif [[ $level -le 5 ]]; then echo "Focused Builder"
  elif [[ $level -le 8 ]]; then echo "Efficient Coder"
  elif [[ $level -le 12 ]]; then echo "Seasoned Viber"
  elif [[ $level -le 18 ]]; then echo "Workflow Master"
  elif [[ $level -le 25 ]]; then echo "Context Architect"
  elif [[ $level -le 35 ]]; then echo "Vibe Sensei"
  elif [[ $level -le 45 ]]; then echo "Grand Master"
  elif [[ $level -le 50 ]]; then echo "Vibe Legend"
  else echo "Vibe Legend"
  fi
}

# --- Unlockable features by level ---
get_unlocks_for_level() {
  local level=$1
  local unlocks="[]"
  case $level in
    2)  unlocks='["daily_challenges"]' ;;
    3)  unlocks='["quiz_command"]' ;;
    5)  unlocks='["weekly_challenges","skill_tree_display"]' ;;
    8)  unlocks='["onetime_challenges"]' ;;
    10) unlocks='["custom_title"]' ;;
    15) unlocks='["advanced_quizzes"]' ;;
    20) unlocks='["detailed_analytics"]' ;;
  esac
  echo "$unlocks"
}

# --- Level up loop ---
LEVELED_UP=false
NEW_LEVEL=$CURRENT_LEVEL
REMAINING_XP=$XP_THIS_LEVEL
LEVELS_GAINED=0
NEW_UNLOCKS="[]"
MAX_LEVEL=50

while [[ $REMAINING_XP -ge $XP_TO_NEXT && $NEW_LEVEL -lt $MAX_LEVEL ]]; do
  LEVELED_UP=true
  REMAINING_XP=$((REMAINING_XP - XP_TO_NEXT))
  NEW_LEVEL=$((NEW_LEVEL + 1))
  LEVELS_GAINED=$((LEVELS_GAINED + 1))

  # Check for unlocks at this level
  LEVEL_UNLOCKS=$(get_unlocks_for_level "$NEW_LEVEL")
  if [[ "$LEVEL_UNLOCKS" != "[]" ]]; then
    NEW_UNLOCKS=$(echo "$NEW_UNLOCKS" "$LEVEL_UNLOCKS" | jq -s 'add | unique')
  fi

  # Calculate XP needed for next level
  XP_TO_NEXT=$(calc_xp_needed "$NEW_LEVEL")
done

# --- Get title ---
NEW_TITLE=$(get_level_title "$NEW_LEVEL")

# --- Update gamification.json ---
if [[ "$LEVELED_UP" == "true" || $NEW_LEVEL -ne $CURRENT_LEVEL ]]; then
  TMP_FILE="${GAMIFICATION_FILE}.tmp"
  jq --argjson level "$NEW_LEVEL" \
     --argjson xp_this "$REMAINING_XP" \
     --argjson xp_next "$XP_TO_NEXT" \
     --argjson new_unlocks "$NEW_UNLOCKS" \
     '
     .level = $level |
     .xp_this_level = $xp_this |
     .xp_to_next_level = $xp_next |
     .unlocked_features = ((.unlocked_features // []) + $new_unlocks | unique)
     ' "$GAMIFICATION_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$GAMIFICATION_FILE"
fi

# Even if no level up, recalculate xp_to_next in case it was stale
if [[ "$LEVELED_UP" == "false" ]]; then
  CORRECT_XP_TO_NEXT=$(calc_xp_needed "$CURRENT_LEVEL")
  TMP_FILE="${GAMIFICATION_FILE}.tmp"
  jq --argjson xp_next "$CORRECT_XP_TO_NEXT" \
     '.xp_to_next_level = $xp_next' \
     "$GAMIFICATION_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$GAMIFICATION_FILE"
fi

# --- Output result ---
jq -n \
  --argjson leveled_up "$LEVELED_UP" \
  --argjson old_level "$CURRENT_LEVEL" \
  --argjson new_level "$NEW_LEVEL" \
  --arg title "$NEW_TITLE" \
  --argjson levels_gained "$LEVELS_GAINED" \
  --argjson xp_this "$REMAINING_XP" \
  --argjson xp_next "$XP_TO_NEXT" \
  --argjson unlocks "$NEW_UNLOCKS" \
  '{
    leveled_up: $leveled_up,
    old_level: $old_level,
    new_level: $new_level,
    title: $title,
    levels_gained: $levels_gained,
    xp_this_level: $xp_this,
    xp_to_next_level: $xp_next,
    new_unlocks: $unlocks
  }'

exit 0
