#!/usr/bin/env bash
# scripts/refresh-challenges.sh
# Expire/refresh daily and weekly challenges on SessionStart
# - Daily challenges expire at midnight UTC and get refreshed
# - Weekly challenges expire on Monday 00:00 UTC and get refreshed
# - One-time challenges remain until completed or level requirement unmet
# - Challenge selection is weighted toward the user's weakest skill domain
# Exit 0 always (never block session startup)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"
GAMIFICATION_FILE="$VIBECREW_DIR/gamification.json"
CHALLENGE_POOL="$PLUGIN_ROOT/templates/challenge-pool.json"

# Shared locking and atomic writes
source "$(dirname "$0")/lib/lock.sh"
source "$(dirname "$0")/lib/atomic-write.sh"

# --- Check gamification is enabled ---
ENABLED=$(jq -r '.gamification.enabled // true' "$VIBECREW_DIR/config.json" 2>/dev/null || echo "true")
if [[ "$ENABLED" == "false" ]]; then
  exit 0
fi

if [[ ! -f "$GAMIFICATION_FILE" || ! -f "$CHALLENGE_POOL" ]]; then
  exit 0
fi

# --- Get current state ---
CURRENT_LEVEL=$(jq -r '.level // 1' "$GAMIFICATION_FILE")
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
TODAY=$(date -u +%Y-%m-%d)
DOW=$(date -u +%u)  # 1=Monday, 7=Sunday

# Start of today (UTC)
TODAY_START="${TODAY}T00:00:00Z"

# Start of current week (Monday)
if [[ "$(uname)" == "Darwin" ]]; then
  DAYS_SINCE_MON=$(( ($(date -u +%u) - 1) ))
  WEEK_START=$(date -u -v-"${DAYS_SINCE_MON}"d +%Y-%m-%d)
else
  DAYS_SINCE_MON=$(( ($(date -u +%u) - 1) ))
  WEEK_START=$(date -u -d "$DAYS_SINCE_MON days ago" +%Y-%m-%d)
fi
WEEK_START_TS="${WEEK_START}T00:00:00Z"

# --- Check unlock levels ---
# Daily challenges unlock at level 2
# Weekly challenges unlock at level 5
# One-time challenges unlock at level 8
HAS_DAILY=false
HAS_WEEKLY=false
HAS_ONETIME=false

[[ "$CURRENT_LEVEL" -ge 2 ]] && HAS_DAILY=true
[[ "$CURRENT_LEVEL" -ge 5 ]] && HAS_WEEKLY=true
[[ "$CURRENT_LEVEL" -ge 8 ]] && HAS_ONETIME=true

# --- Find weakest skill for weighted selection ---
WEAKEST_SKILL=$(jq -r '
  .skills | to_entries |
  min_by(.value.xp) |
  .key
' "$GAMIFICATION_FILE" 2>/dev/null || echo "prompting")

# --- Expire old challenges ---
# Remove daily challenges that started before today
# Remove weekly challenges that started before this week's Monday
acquire_named_lock "gamification" "refresh-challenges"

UPDATED=$(jq --arg today "$TODAY_START" --arg week "$WEEK_START_TS" '
  .active_challenges = [
    .active_challenges[] |
    select(
      (.type == "daily" and .started_at >= $today) or
      (.type == "weekly" and .started_at >= $week) or
      (.type == "onetime")
    )
  ]
' "$GAMIFICATION_FILE")
atomic_write "$GAMIFICATION_FILE" "$UPDATED" --no-backup

# --- Get already-active and completed challenge IDs ---
ACTIVE_IDS=$(jq -r '[.active_challenges[].id] | join(",")' "$GAMIFICATION_FILE" 2>/dev/null || echo "")
COMPLETED_IDS=$(jq -r '[.completed_challenges[].id] | join(",")' "$GAMIFICATION_FILE" 2>/dev/null || echo "")

# --- Helper: pick challenges weighted toward weakest skill ---
pick_challenge() {
  local pool_key="$1"
  local challenge_type="$2"
  local max_picks="$3"

  # Get available challenges (not already active, not completed for one-time)
  local available
  available=$(jq --arg weakest "$WEAKEST_SKILL" --arg type "$challenge_type" \
    ".${pool_key} | sort_by(if .target_skill == \$weakest then 0 else 1 end)" \
    "$CHALLENGE_POOL" 2>/dev/null || echo "[]")

  local count
  count=$(echo "$available" | jq 'length')
  local picked=0

  for ((i = 0; i < count && picked < max_picks; i++)); do
    local cid
    cid=$(echo "$available" | jq -r ".[$i].id")

    # Skip if already active
    if echo ",$ACTIVE_IDS," | grep -q ",$cid,"; then
      continue
    fi

    # Skip completed one-time challenges
    if [[ "$challenge_type" == "onetime" ]] && echo ",$COMPLETED_IDS," | grep -q ",$cid,"; then
      continue
    fi

    # Check level requirement for one-time challenges
    if [[ "$challenge_type" == "onetime" ]]; then
      local unlock_level
      unlock_level=$(echo "$available" | jq -r ".[$i].unlock_level // 1")
      if [[ "$CURRENT_LEVEL" -lt "$unlock_level" ]]; then
        continue
      fi
    fi

    # Calculate expiry
    local expires_at
    if [[ "$challenge_type" == "daily" ]]; then
      if [[ "$(uname)" == "Darwin" ]]; then
        expires_at="$(date -u -v+1d +%Y-%m-%d)T00:00:00Z"
      else
        expires_at="$(date -u -d "tomorrow" +%Y-%m-%d)T00:00:00Z"
      fi
    elif [[ "$challenge_type" == "weekly" ]]; then
      if [[ "$(uname)" == "Darwin" ]]; then
        local days_to_mon=$((8 - $(date -u +%u)))
        [[ $days_to_mon -eq 7 ]] && days_to_mon=0
        expires_at="$(date -u -v+${days_to_mon}d +%Y-%m-%d)T00:00:00Z"
      else
        expires_at="$(date -u -d "next monday" +%Y-%m-%d)T00:00:00Z"
      fi
    else
      # One-time challenges don't expire
      expires_at="9999-12-31T23:59:59Z"
    fi

    # Add challenge to active list
    local challenge_json
    challenge_json=$(echo "$available" | jq --arg ts "$NOW" --arg exp "$expires_at" \
      ".[$i] | {id: .id, type: .type, name: .name, description: .description, started_at: \$ts, expires_at: \$exp, progress: 0, target: 1, xp_reward: .xp_reward}")

    local pick_updated
    pick_updated=$(jq --argjson challenge "$challenge_json" \
      '.active_challenges += [$challenge]' \
      "$GAMIFICATION_FILE")
    atomic_write "$GAMIFICATION_FILE" "$pick_updated" --no-backup

    picked=$((picked + 1))
    ACTIVE_IDS="${ACTIVE_IDS},${cid}"
  done
}

# --- Refresh challenges ---
# Check how many of each type are already active
ACTIVE_DAILY=$(jq '[.active_challenges[] | select(.type == "daily")] | length' "$GAMIFICATION_FILE")
ACTIVE_WEEKLY=$(jq '[.active_challenges[] | select(.type == "weekly")] | length' "$GAMIFICATION_FILE")
ACTIVE_ONETIME=$(jq '[.active_challenges[] | select(.type == "onetime")] | length' "$GAMIFICATION_FILE")

# Daily: pick up to 2
if [[ "$HAS_DAILY" == "true" && "$ACTIVE_DAILY" -lt 2 ]]; then
  NEEDED=$((2 - ACTIVE_DAILY))
  pick_challenge "daily_challenges" "daily" "$NEEDED"
fi

# Weekly: pick up to 1
if [[ "$HAS_WEEKLY" == "true" && "$ACTIVE_WEEKLY" -lt 1 ]]; then
  pick_challenge "weekly_challenges" "weekly" 1
fi

# One-time: pick up to 1 if none active
if [[ "$HAS_ONETIME" == "true" && "$ACTIVE_ONETIME" -lt 1 ]]; then
  pick_challenge "onetime_challenges" "onetime" 1
fi

# --- Output summary ---
FINAL_ACTIVE=$(jq '.active_challenges | length' "$GAMIFICATION_FILE")

release_named_lock "gamification"

echo "Challenges: $FINAL_ACTIVE active"

exit 0
