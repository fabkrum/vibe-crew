#!/usr/bin/env bash
# scripts/sync-state.sh
# Reconciles state.json and backlog.json when inconsistencies are detected.
# Fixes: orphaned active features, phase/column mismatches, foundation flags.
# Reports: orphaned in-progress features.
# Uses advisory locking and atomic writes for safety.
# Exit 0 always (fail open -- sync issues should not block sessions)

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBEOS_DIR="$PROJECT_ROOT/.vibeos"
STATE_FILE="$VIBEOS_DIR/state.json"
BACKLOG_FILE="$VIBEOS_DIR/backlog.json"
LOCK_DIR="$VIBEOS_DIR/locks/sync-state"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

ISSUES=0
FIXES=()
WARNINGS=()

# =============================================================================
# Timestamp helpers (macOS + GNU compatible)
# =============================================================================

parse_timestamp() {
  local ts="$1"
  if date -j -f "%Y-%m-%dT%H:%M:%SZ" "$ts" "+%s" &>/dev/null; then
    date -j -f "%Y-%m-%dT%H:%M:%SZ" "$ts" "+%s" 2>/dev/null || echo "0"
  else
    date -d "$ts" "+%s" 2>/dev/null || echo "0"
  fi
}

# =============================================================================
# Locking helpers (mkdir-based advisory lock, 30 second timeout)
# =============================================================================

LOCK_ACQUIRED=false

cleanup() {
  if [[ "$LOCK_ACQUIRED" == "true" ]]; then
    rm -rf "$LOCK_DIR"
  fi
}

trap cleanup EXIT

is_lock_stale() {
  local lock_info="$LOCK_DIR/info.json"
  if [[ ! -f "$lock_info" ]]; then
    return 0  # No info file means stale
  fi
  local locked_at
  locked_at=$(jq -r '.locked_at // empty' "$lock_info" 2>/dev/null || echo "")
  if [[ -z "$locked_at" ]]; then
    return 0
  fi
  local lock_epoch now_epoch
  lock_epoch=$(parse_timestamp "$locked_at")
  now_epoch=$(date "+%s")
  local age=$(( now_epoch - lock_epoch ))
  [[ "$age" -gt 30 ]]
}

acquire_lock() {
  mkdir -p "$VIBEOS_DIR/locks"

  # Try to acquire
  if mkdir "$LOCK_DIR" 2>/dev/null; then
    LOCK_ACQUIRED=true
    cat > "$LOCK_DIR/info.json" <<EOF
{
  "locked_by": "sync-state.sh",
  "pid": $$,
  "locked_at": "$TIMESTAMP",
  "target_file": "state.json,backlog.json",
  "timeout_seconds": 30
}
EOF
    return 0
  fi

  # Lock exists -- check if stale
  if is_lock_stale; then
    rm -rf "$LOCK_DIR"
    if mkdir "$LOCK_DIR" 2>/dev/null; then
      LOCK_ACQUIRED=true
      cat > "$LOCK_DIR/info.json" <<EOF
{
  "locked_by": "sync-state.sh",
  "pid": $$,
  "locked_at": "$TIMESTAMP",
  "target_file": "state.json,backlog.json",
  "timeout_seconds": 30
}
EOF
      return 0
    fi
  fi

  # Wait up to 30 seconds, polling every 0.5s
  local attempts=0
  while [[ "$attempts" -lt 60 ]]; do
    sleep 0.5
    if mkdir "$LOCK_DIR" 2>/dev/null; then
      LOCK_ACQUIRED=true
      cat > "$LOCK_DIR/info.json" <<EOF
{
  "locked_by": "sync-state.sh",
  "pid": $$,
  "locked_at": "$TIMESTAMP",
  "target_file": "state.json,backlog.json",
  "timeout_seconds": 30
}
EOF
      return 0
    fi

    # Check for stale lock while waiting
    if is_lock_stale; then
      rm -rf "$LOCK_DIR"
      # Loop will try mkdir on next iteration
    fi

    ((attempts++))
  done

  # Fail open -- could not acquire lock, skip sync
  WARNINGS+=("Could not acquire lock after 30 seconds, skipping sync")
  return 1
}

release_lock() {
  rm -rf "$LOCK_DIR"
  LOCK_ACQUIRED=false
}

# =============================================================================
# Atomic write with validation
# =============================================================================

atomic_write() {
  local target="$1"
  local content="$2"
  local tmp="${target}.tmp.$$"

  # Write to temp file
  echo "$content" > "$tmp"

  # Validate JSON
  if ! jq empty "$tmp" 2>/dev/null; then
    rm -f "$tmp"
    WARNINGS+=("JSON validation failed writing $(basename "$target"), skipped")
    return 1
  fi

  # Atomic rename
  mv "$tmp" "$target"
  return 0
}

# =============================================================================
# Phase-to-column mapping
# =============================================================================

phase_to_column() {
  local phase="$1"
  case "$phase" in
    plan)   echo "planned" ;;
    design) echo "in-progress" ;;
    code)   echo "in-progress" ;;
    test)   echo "testing" ;;
    docs)   echo "review" ;;
    *)      echo "" ;;
  esac
}

# =============================================================================
# Pre-flight: check files exist
# =============================================================================

if [[ ! -f "$STATE_FILE" ]]; then
  echo "State sync: skipped (state.json not found)"
  exit 0
fi

if [[ ! -f "$BACKLOG_FILE" ]]; then
  echo "State sync: skipped (backlog.json not found)"
  exit 0
fi

# =============================================================================
# Acquire lock
# =============================================================================

if ! acquire_lock; then
  echo "State sync: skipped (could not acquire lock)"
  echo "  - Warning: ${WARNINGS[*]}"
  exit 0
fi

# =============================================================================
# Read current state
# =============================================================================

STATE=$(cat "$STATE_FILE")
BACKLOG=$(cat "$BACKLOG_FILE")
STATE_MODIFIED=false
BACKLOG_MODIFIED=false

# =============================================================================
# Check 1: Active feature consistency
# If state.json has an active_feature.id, verify it exists in backlog.json
# =============================================================================

ACTIVE_ID=$(echo "$STATE" | jq -r '.active_feature.id // empty')

if [[ -n "$ACTIVE_ID" ]]; then
  FEATURE_EXISTS=$(echo "$BACKLOG" | jq --arg id "$ACTIVE_ID" \
    '[.features[] | select(.id == $id)] | length')

  if [[ "$FEATURE_EXISTS" -eq 0 ]]; then
    # Feature not found in backlog -- clear active_feature in state.json
    STATE=$(echo "$STATE" | jq --arg ts "$TIMESTAMP" '
      .active_feature.id = null |
      .active_feature.name = null |
      .active_feature.worktree = null |
      .active_feature.phase = null |
      .active_feature.phases_completed = [] |
      .updated_at = $ts
    ')
    STATE_MODIFIED=true
    ((ISSUES++))
    FIXES+=("Cleared active_feature '$ACTIVE_ID' (not found in backlog)")
    ACTIVE_ID=""
  fi
fi

# =============================================================================
# Check 2: Phase consistency
# If state.json has active_feature.phase, verify backlog column matches
# =============================================================================

ACTIVE_PHASE=$(echo "$STATE" | jq -r '.active_feature.phase // empty')

if [[ -n "$ACTIVE_ID" ]] && [[ -n "$ACTIVE_PHASE" ]]; then
  EXPECTED_COLUMN=$(phase_to_column "$ACTIVE_PHASE")

  if [[ -n "$EXPECTED_COLUMN" ]]; then
    CURRENT_COLUMN=$(echo "$BACKLOG" | jq -r --arg id "$ACTIVE_ID" \
      '[.features[] | select(.id == $id) | .column] | .[0] // "unknown"')

    if [[ "$CURRENT_COLUMN" != "$EXPECTED_COLUMN" ]]; then
      # Mismatch -- update backlog column to match state phase
      BACKLOG=$(echo "$BACKLOG" | jq --arg id "$ACTIVE_ID" --arg col "$EXPECTED_COLUMN" --arg ts "$TIMESTAMP" '
        .features = [
          .features[] |
          if .id == $id then
            .column = $col |
            .updated_at = $ts
          else
            .
          end
        ]
      ')
      BACKLOG_MODIFIED=true
      ((ISSUES++))
      FIXES+=("Updated backlog column for '$ACTIVE_ID': '$CURRENT_COLUMN' -> '$EXPECTED_COLUMN' (to match phase '$ACTIVE_PHASE')")
    fi
  fi
fi

# =============================================================================
# Check 3: Orphaned in-progress features
# Features in backlog with column "in-progress" that are NOT the active feature
# =============================================================================

ORPHANED_FEATURES=$(echo "$BACKLOG" | jq -r --arg active "${ACTIVE_ID:-__none__}" \
  '[.features[] | select(.column == "in-progress" and .id != $active)] | .[] | "\(.id) (\(.name // "unnamed"))"')

if [[ -n "$ORPHANED_FEATURES" ]]; then
  while IFS= read -r orphan; do
    ((ISSUES++))
    WARNINGS+=("Orphaned in-progress feature: $orphan")
  done <<< "$ORPHANED_FEATURES"
fi

# =============================================================================
# Check 4: Foundation consistency
# If foundation.complete is true, verify all 5 artifacts are "complete"
# =============================================================================

FOUNDATION_COMPLETE=$(echo "$STATE" | jq -r '.foundation.complete // false')

if [[ "$FOUNDATION_COMPLETE" == "true" ]]; then
  INCOMPLETE_ARTIFACTS=$(echo "$STATE" | jq -r '
    .foundation.artifacts // {} |
    to_entries[] |
    select(.value.status != "complete") |
    .key
  ')

  if [[ -n "$INCOMPLETE_ARTIFACTS" ]]; then
    # Some artifacts are not complete -- set foundation.complete back to false
    STATE=$(echo "$STATE" | jq --arg ts "$TIMESTAMP" '
      .foundation.complete = false |
      .foundation.completed_at = null |
      .updated_at = $ts
    ')
    STATE_MODIFIED=true
    ((ISSUES++))

    INCOMPLETE_LIST=""
    while IFS= read -r artifact; do
      ARTIFACT_STATUS=$(echo "$STATE" | jq -r --arg a "$artifact" \
        '.foundation.artifacts[$a].status // "unknown"')
      INCOMPLETE_LIST="${INCOMPLETE_LIST}${artifact} (${ARTIFACT_STATUS}), "
    done <<< "$INCOMPLETE_ARTIFACTS"
    INCOMPLETE_LIST="${INCOMPLETE_LIST%, }"

    FIXES+=("Reset foundation.complete to false (incomplete artifacts: $INCOMPLETE_LIST)")
  fi
fi

# =============================================================================
# Write modified files atomically
# =============================================================================

if [[ "$STATE_MODIFIED" == "true" ]]; then
  if ! atomic_write "$STATE_FILE" "$STATE"; then
    WARNINGS+=("Failed to write state.json fixes")
  fi
fi

if [[ "$BACKLOG_MODIFIED" == "true" ]]; then
  if ! atomic_write "$BACKLOG_FILE" "$BACKLOG"; then
    WARNINGS+=("Failed to write backlog.json fixes")
  fi
fi

# =============================================================================
# Release lock
# =============================================================================

release_lock

# =============================================================================
# Output report
# =============================================================================

if [[ "$ISSUES" -eq 0 ]]; then
  echo "State sync: consistent"
else
  echo "State sync: $ISSUES issues found"
fi

for fix in "${FIXES[@]+"${FIXES[@]}"}"; do
  echo "  - Fixed: $fix"
done

for warn in "${WARNINGS[@]+"${WARNINGS[@]}"}"; do
  echo "  - Warning: $warn"
done

exit 0
