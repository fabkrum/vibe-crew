#!/usr/bin/env bash
# scripts/update-streak.sh
# Update streak counter with grace period logic
# Rules:
#   - Increment on calendar days where /wrap runs
#   - Saturdays/Sundays don't break streaks, don't consume grace credits
#   - 2 grace days per month: missing one weekday preserves the streak
#   - Grace days reset on the 1st of each month
#   - No penalty for broken streaks (counter resets to 0, no XP lost)
# Exit 0 on success, Exit 1 on failure

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"
GAMIFICATION_FILE="$VIBECREW_DIR/gamification.json"

# Shared locking and atomic writes
source "$(dirname "$0")/lib/lock.sh"
source "$(dirname "$0")/lib/atomic-write.sh"

# --- Check gamification is enabled ---
ENABLED=$(jq -r 'if .gamification.enabled == false then "false" else "true" end' "$VIBECREW_DIR/config.json" 2>/dev/null || echo "true")
if [[ "$ENABLED" == "false" ]]; then
  echo '{"streak_updated":false,"message":"Gamification disabled"}'
  exit 0
fi

if [[ ! -f "$GAMIFICATION_FILE" ]]; then
  echo "Error: gamification.json not found." >&2
  exit 1
fi

# --- Get current date info ---
TODAY=$(date -u +%Y-%m-%d)
DAY_OF_WEEK=$(date -u +%u)  # 1=Monday, 7=Sunday
DAY_OF_MONTH=$(date -u +%d)

# --- Read current streak state ---
acquire_named_lock "gamification" "update-streak"

CURRENT_STREAK=$(jq -r '.streak.current // 0' "$GAMIFICATION_FILE")
LONGEST_STREAK=$(jq -r '.streak.longest // 0' "$GAMIFICATION_FILE")
LAST_SESSION_DATE=$(jq -r '.streak.last_session_date // "none"' "$GAMIFICATION_FILE")
GRACE_REMAINING=$(jq -r '.streak.grace_days_remaining // 2' "$GAMIFICATION_FILE")
FROZEN_TODAY=$(jq -r '.streak.frozen_today // false' "$GAMIFICATION_FILE")

# --- Reset grace days on 1st of month ---
if [[ "$DAY_OF_MONTH" == "01" ]]; then
  GRACE_REMAINING=2
fi

# --- Already logged today? ---
if [[ "$LAST_SESSION_DATE" == "$TODAY" ]]; then
  # Already wrapped today, no change
  jq -n \
    --argjson streak "$CURRENT_STREAK" \
    --argjson longest "$LONGEST_STREAK" \
    --arg last "$TODAY" \
    --argjson grace "$GRACE_REMAINING" \
    '{streak_updated: false, current: $streak, longest: $longest, last_session_date: $last, grace_remaining: $grace, message: "Already wrapped today"}'
  exit 0
fi

# --- Calculate days since last session ---
NEW_STREAK=$CURRENT_STREAK
STREAK_BROKEN=false
GRACE_USED=false

if [[ "$LAST_SESSION_DATE" == "none" || "$LAST_SESSION_DATE" == "null" ]]; then
  # First ever session
  NEW_STREAK=1
else
  # Calculate the difference in days
  if [[ "$(uname)" == "Darwin" ]]; then
    LAST_EPOCH=$(date -j -f "%Y-%m-%d" "$LAST_SESSION_DATE" "+%s" 2>/dev/null || echo "0")
    TODAY_EPOCH=$(date -j -f "%Y-%m-%d" "$TODAY" "+%s" 2>/dev/null || echo "0")
  else
    LAST_EPOCH=$(date -d "$LAST_SESSION_DATE" "+%s" 2>/dev/null || echo "0")
    TODAY_EPOCH=$(date -d "$TODAY" "+%s" 2>/dev/null || echo "0")
  fi

  if [[ "$LAST_EPOCH" -eq 0 || "$TODAY_EPOCH" -eq 0 ]]; then
    # Fallback: can't calculate, just increment
    NEW_STREAK=$((CURRENT_STREAK + 1))
  else
    DAYS_DIFF=$(( (TODAY_EPOCH - LAST_EPOCH) / 86400 ))

    if [[ $DAYS_DIFF -le 0 ]]; then
      # Same day or clock skew
      NEW_STREAK=$CURRENT_STREAK
    elif [[ $DAYS_DIFF -eq 1 ]]; then
      # Consecutive day
      NEW_STREAK=$((CURRENT_STREAK + 1))
    else
      # Multiple days gap — check for weekends and grace days
      MISSED_WEEKDAYS=0
      WEEKEND_ONLY=true

      # Count each missed day
      for ((d = 1; d < DAYS_DIFF; d++)); do
        if [[ "$(uname)" == "Darwin" ]]; then
          CHECK_DOW=$(date -j -f "%s" "$((LAST_EPOCH + d * 86400))" "+%u" 2>/dev/null || echo "0")
        else
          CHECK_DOW=$(date -d "@$((LAST_EPOCH + d * 86400))" "+%u" 2>/dev/null || echo "0")
        fi
        # 6=Saturday, 7=Sunday
        if [[ "$CHECK_DOW" -ne 6 && "$CHECK_DOW" -ne 7 ]]; then
          MISSED_WEEKDAYS=$((MISSED_WEEKDAYS + 1))
          WEEKEND_ONLY=false
        fi
      done

      if [[ "$WEEKEND_ONLY" == "true" || $MISSED_WEEKDAYS -eq 0 ]]; then
        # Only missed weekend days — streak continues
        NEW_STREAK=$((CURRENT_STREAK + 1))
      elif [[ $MISSED_WEEKDAYS -le $GRACE_REMAINING ]]; then
        # Grace days cover the gap
        GRACE_REMAINING=$((GRACE_REMAINING - MISSED_WEEKDAYS))
        GRACE_USED=true
        NEW_STREAK=$((CURRENT_STREAK + 1))
      else
        # Streak broken
        STREAK_BROKEN=true
        NEW_STREAK=1
      fi
    fi
  fi
fi

# --- Update longest streak ---
NEW_LONGEST=$LONGEST_STREAK
if [[ $NEW_STREAK -gt $LONGEST_STREAK ]]; then
  NEW_LONGEST=$NEW_STREAK
fi

# --- Write updated state ---
UPDATED=$(jq --argjson streak "$NEW_STREAK" \
   --argjson longest "$NEW_LONGEST" \
   --arg last "$TODAY" \
   --argjson grace "$GRACE_REMAINING" \
   --argjson frozen "$GRACE_USED" \
   '
   .streak.current = $streak |
   .streak.longest = $longest |
   .streak.last_session_date = $last |
   .streak.grace_days_remaining = $grace |
   .streak.frozen_today = $frozen
   ' "$GAMIFICATION_FILE")

atomic_write "$GAMIFICATION_FILE" "$UPDATED" --no-backup

release_named_lock "gamification"

# --- Output result ---
jq -n \
  --argjson streak "$NEW_STREAK" \
  --argjson longest "$NEW_LONGEST" \
  --arg last "$TODAY" \
  --argjson grace "$GRACE_REMAINING" \
  --argjson broken "$STREAK_BROKEN" \
  --argjson grace_used "$GRACE_USED" \
  '{
    streak_updated: true,
    current: $streak,
    longest: $longest,
    last_session_date: $last,
    grace_remaining: $grace,
    streak_broken: $broken,
    grace_used: $grace_used
  }'

exit 0
