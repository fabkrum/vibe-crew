#!/usr/bin/env bash
# scripts/complete-phase.sh
# Advance a feature's phase in backlog.json with lock-based concurrency control.
# Also handles marking foundation as complete.
# Usage:
#   scripts/complete-phase.sh <feature-id> <completed-phase>
#   scripts/complete-phase.sh foundation
# Idempotent: safe to run multiple times
# Exit 0 on success, Exit 1 on failure

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBEOS_DIR="$PROJECT_ROOT/.vibeos"
STATE_FILE="$VIBEOS_DIR/state.json"
BACKLOG_FILE="$VIBEOS_DIR/backlog.json"
LOCK_DIR="$VIBEOS_DIR/locks/backlog-json"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# =============================================================================
# Locking helpers
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
  # Check if lock is older than 30 seconds
  local lock_epoch now_epoch
  if date -j -f "%Y-%m-%dT%H:%M:%SZ" "$locked_at" "+%s" &>/dev/null; then
    # macOS date
    lock_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$locked_at" "+%s" 2>/dev/null || echo "0")
  else
    # GNU date
    lock_epoch=$(date -d "$locked_at" "+%s" 2>/dev/null || echo "0")
  fi
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
  "locked_by": "complete-phase.sh",
  "pid": $$,
  "locked_at": "$TIMESTAMP",
  "target_file": "backlog.json",
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
  "locked_by": "complete-phase.sh",
  "pid": $$,
  "locked_at": "$TIMESTAMP",
  "target_file": "backlog.json",
  "timeout_seconds": 30
}
EOF
      return 0
    fi
  fi

  # Wait up to 5 seconds, polling every 0.5s
  local attempts=0
  while [[ "$attempts" -lt 10 ]]; do
    sleep 0.5
    if mkdir "$LOCK_DIR" 2>/dev/null; then
      LOCK_ACQUIRED=true
      cat > "$LOCK_DIR/info.json" <<EOF
{
  "locked_by": "complete-phase.sh",
  "pid": $$,
  "locked_at": "$TIMESTAMP",
  "target_file": "backlog.json",
  "timeout_seconds": 30
}
EOF
      return 0
    fi
    ((attempts++))
  done

  echo "ERROR: Could not acquire lock on backlog.json after 5 seconds." >&2
  exit 1
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
  local tmp="${target}.tmp"
  local backup="${target}.bak"

  # Create backup
  if [[ -f "$target" ]]; then
    cp "$target" "$backup"
  fi

  # Write to temp file
  echo "$content" > "$tmp"

  # Validate JSON
  if ! jq empty "$tmp" 2>/dev/null; then
    echo "ERROR: JSON validation failed for $target" >&2
    rm -f "$tmp"
    # Restore from backup
    if [[ -f "$backup" ]]; then
      cp "$backup" "$target"
    fi
    return 1
  fi

  # Atomic rename
  mv "$tmp" "$target"
  rm -f "$backup"
  return 0
}

# =============================================================================
# Validation
# =============================================================================

if [[ ! -d "$VIBEOS_DIR" ]]; then
  echo "ERROR: .vibeos/ directory not found. Run /setup first." >&2
  exit 1
fi

if [[ $# -lt 1 ]]; then
  echo "Usage: complete-phase.sh <feature-id> <completed-phase>" >&2
  echo "       complete-phase.sh foundation" >&2
  exit 1
fi

# =============================================================================
# Foundation mode
# =============================================================================

if [[ "$1" == "foundation" ]]; then
  if [[ ! -f "$STATE_FILE" ]]; then
    echo "ERROR: state.json not found." >&2
    exit 1
  fi

  UPDATED=$(jq \
    --arg ts "$TIMESTAMP" \
    '.foundation.complete = true | .foundation.completed_at = $ts | .updated_at = $ts' \
    "$STATE_FILE")

  if ! atomic_write "$STATE_FILE" "$UPDATED"; then
    echo "ERROR: Failed to write state.json" >&2
    exit 1
  fi

  echo "Foundation marked complete."
  exit 0
fi

# =============================================================================
# Feature phase completion mode
# =============================================================================

if [[ $# -lt 2 ]]; then
  echo "Usage: complete-phase.sh <feature-id> <completed-phase>" >&2
  exit 1
fi

FEATURE_ID="$1"
COMPLETED_PHASE="$2"

# Validate phase name
VALID_PHASES=("plan" "design" "code" "test" "docs")
PHASE_VALID=false
for p in "${VALID_PHASES[@]}"; do
  if [[ "$p" == "$COMPLETED_PHASE" ]]; then
    PHASE_VALID=true
    break
  fi
done

if [[ "$PHASE_VALID" == "false" ]]; then
  echo "ERROR: Invalid phase '$COMPLETED_PHASE'. Must be one of: plan, design, code, test, docs" >&2
  exit 1
fi

# Determine next column based on completed phase
determine_next_column() {
  local phase="$1"
  case "$phase" in
    plan)   echo "in-progress" ;;
    design) echo "in-progress" ;;
    code)   echo "testing" ;;
    test)   echo "review" ;;
    docs)   echo "review" ;;
    *)      echo "in-progress" ;;
  esac
}

# Determine next phase for state.json
determine_next_phase() {
  local phase="$1"
  case "$phase" in
    plan)   echo "design" ;;
    design) echo "code" ;;
    code)   echo "test" ;;
    test)   echo "docs" ;;
    docs)   echo "done" ;;
    *)      echo "plan" ;;
  esac
}

NEXT_COLUMN=$(determine_next_column "$COMPLETED_PHASE")
NEXT_PHASE=$(determine_next_phase "$COMPLETED_PHASE")

# Check required files exist
if [[ ! -f "$BACKLOG_FILE" ]]; then
  echo "ERROR: backlog.json not found." >&2
  exit 1
fi

if [[ ! -f "$STATE_FILE" ]]; then
  echo "ERROR: state.json not found." >&2
  exit 1
fi

# Acquire lock
acquire_lock

# Read backlog
BACKLOG=$(cat "$BACKLOG_FILE")

# Find the feature by ID
FEATURE_INDEX=$(echo "$BACKLOG" | jq --arg id "$FEATURE_ID" \
  '[.features | to_entries[] | select(.value.id == $id) | .key] | .[0] // -1')

if [[ "$FEATURE_INDEX" == "-1" ]] || [[ "$FEATURE_INDEX" == "null" ]]; then
  echo "ERROR: Feature '$FEATURE_ID' not found in backlog." >&2
  release_lock
  exit 1
fi

# Get current feature column for the summary
CURRENT_COLUMN=$(echo "$BACKLOG" | jq -r --argjson idx "$FEATURE_INDEX" \
  '.features[$idx].column // "unknown"')

# Update backlog: add phase to phases_completed (if not present), update column and timestamp
UPDATED_BACKLOG=$(echo "$BACKLOG" | jq \
  --argjson idx "$FEATURE_INDEX" \
  --arg phase "$COMPLETED_PHASE" \
  --arg col "$NEXT_COLUMN" \
  --arg ts "$TIMESTAMP" \
  '
  .features[$idx].phases_completed = (
    .features[$idx].phases_completed //= [] |
    if (.features[$idx].phases_completed | index($phase)) then
      .features[$idx].phases_completed
    else
      .features[$idx].phases_completed + [$phase]
    end
  ) |
  .features[$idx].column = $col |
  .features[$idx].updated_at = $ts
  ')

# Update state.json: advance active_feature phase and phases_completed
STATE=$(cat "$STATE_FILE")
UPDATED_STATE=$(echo "$STATE" | jq \
  --arg phase "$NEXT_PHASE" \
  --arg completed "$COMPLETED_PHASE" \
  --arg ts "$TIMESTAMP" \
  '
  .active_feature.phase = $phase |
  .active_feature.phases_completed = (
    .active_feature.phases_completed //= [] |
    if (.active_feature.phases_completed | index($completed)) then
      .active_feature.phases_completed
    else
      .active_feature.phases_completed + [$completed]
    end
  ) |
  .updated_at = $ts
  ')

# Write backlog atomically
if ! atomic_write "$BACKLOG_FILE" "$UPDATED_BACKLOG"; then
  echo "ERROR: Failed to write backlog.json" >&2
  release_lock
  exit 1
fi

# Write state atomically
if ! atomic_write "$STATE_FILE" "$UPDATED_STATE"; then
  echo "ERROR: Failed to write state.json" >&2
  release_lock
  exit 1
fi

release_lock

echo "$FEATURE_ID: completed $COMPLETED_PHASE, now in $NEXT_COLUMN"
exit 0
