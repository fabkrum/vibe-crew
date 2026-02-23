#!/usr/bin/env bash
# scripts/claim-task.sh
# Atomically claim a ready feature for an agent using advisory locks.
# Usage:
#   scripts/claim-task.sh <agent-name>               # Claim highest-priority ready feature
#   scripts/claim-task.sh <agent-name> <feature-id>   # Claim a specific feature
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
  "locked_by": "claim-task.sh",
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
  "locked_by": "claim-task.sh",
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
  "locked_by": "claim-task.sh",
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
  echo "Usage: claim-task.sh <agent-name> [feature-id]" >&2
  exit 1
fi

AGENT_NAME="$1"
FEATURE_ID="${2:-}"

if [[ ! -f "$BACKLOG_FILE" ]]; then
  echo "ERROR: backlog.json not found." >&2
  exit 1
fi

if [[ ! -f "$STATE_FILE" ]]; then
  echo "ERROR: state.json not found." >&2
  exit 1
fi

# =============================================================================
# Acquire lock and read backlog
# =============================================================================

acquire_lock

BACKLOG=$(cat "$BACKLOG_FILE")

# =============================================================================
# Find the feature to claim
# =============================================================================

if [[ -n "$FEATURE_ID" ]]; then
  # Specific feature requested -- verify it exists and is in "ready" column
  FEATURE_JSON=$(echo "$BACKLOG" | jq --arg id "$FEATURE_ID" \
    '[.features[] | select(.id == $id)] | .[0] // null')

  if [[ "$FEATURE_JSON" == "null" ]]; then
    echo "ERROR: Feature '$FEATURE_ID' not found in backlog." >&2
    release_lock
    exit 1
  fi

  FEATURE_COLUMN=$(echo "$FEATURE_JSON" | jq -r '.column // "unknown"')
  if [[ "$FEATURE_COLUMN" != "ready" ]]; then
    echo "ERROR: Feature '$FEATURE_ID' is in column '$FEATURE_COLUMN', not 'ready'." >&2
    release_lock
    exit 1
  fi
else
  # Auto-select: find highest-priority ready feature

  # Check WIP limit first
  WIP_LIMIT=$(echo "$BACKLOG" | jq \
    '[.columns[] | select(.id == "in-progress") | .wip_limit] | .[0] // null')
  IN_PROGRESS_COUNT=$(echo "$BACKLOG" | jq \
    '[.features[] | select(.column == "in-progress")] | length')

  if [[ "$WIP_LIMIT" != "null" ]] && [[ "$IN_PROGRESS_COUNT" -ge "$WIP_LIMIT" ]]; then
    echo "ERROR: WIP limit reached. $IN_PROGRESS_COUNT feature(s) already in-progress (limit: $WIP_LIMIT)." >&2
    release_lock
    exit 1
  fi

  # Get all ready features sorted by priority (lowest number = highest priority)
  READY_FEATURES=$(echo "$BACKLOG" | jq \
    '[.features[] | select(.column == "ready")] | sort_by(.priority // 999)')

  READY_COUNT=$(echo "$READY_FEATURES" | jq 'length')

  if [[ "$READY_COUNT" -eq 0 ]]; then
    echo "No ready features."
    release_lock
    exit 0
  fi

  # Iterate through ready features, checking dependencies
  FEATURE_JSON="null"
  for i in $(seq 0 $((READY_COUNT - 1))); do
    CANDIDATE=$(echo "$READY_FEATURES" | jq ".[$i]")
    CANDIDATE_ID=$(echo "$CANDIDATE" | jq -r '.id')

    # Check dependencies: all features this one depends on must be in "done" column
    DEPS=$(echo "$CANDIDATE" | jq -r '.depends_on // [] | .[]' 2>/dev/null)
    DEPS_MET=true

    if [[ -n "$DEPS" ]]; then
      while IFS= read -r dep_id; do
        DEP_COLUMN=$(echo "$BACKLOG" | jq -r --arg did "$dep_id" \
          '[.features[] | select(.id == $did) | .column] | .[0] // "unknown"')
        if [[ "$DEP_COLUMN" != "done" ]]; then
          DEPS_MET=false
          break
        fi
      done <<< "$DEPS"
    fi

    if [[ "$DEPS_MET" == "true" ]]; then
      FEATURE_JSON="$CANDIDATE"
      FEATURE_ID="$CANDIDATE_ID"
      break
    fi
  done

  if [[ "$FEATURE_JSON" == "null" ]]; then
    echo "No ready features with satisfied dependencies."
    release_lock
    exit 0
  fi
fi

# =============================================================================
# Verify dependencies for the chosen feature (also for explicit feature_id)
# =============================================================================

if [[ -n "$FEATURE_ID" ]] && [[ "${FEATURE_JSON:-null}" != "null" ]]; then
  DEPS=$(echo "$FEATURE_JSON" | jq -r '.depends_on // [] | .[]' 2>/dev/null)
  if [[ -n "$DEPS" ]]; then
    while IFS= read -r dep_id; do
      DEP_COLUMN=$(echo "$BACKLOG" | jq -r --arg did "$dep_id" \
        '[.features[] | select(.id == $did) | .column] | .[0] // "unknown"')
      if [[ "$DEP_COLUMN" != "done" ]]; then
        echo "ERROR: Dependency '$dep_id' is in column '$DEP_COLUMN', not 'done'." >&2
        release_lock
        exit 1
      fi
    done <<< "$DEPS"
  fi
fi

# =============================================================================
# Extract feature details
# =============================================================================

FEATURE_NAME=$(echo "$FEATURE_JSON" | jq -r '.name // "Unnamed"')
FEATURE_PRIORITY=$(echo "$FEATURE_JSON" | jq '.priority // 999')
ACCEPTANCE_CRITERIA=$(echo "$FEATURE_JSON" | jq '.spec.acceptance_criteria // []')

# =============================================================================
# Update backlog: move feature to in-progress
# =============================================================================

UPDATED_BACKLOG=$(echo "$BACKLOG" | jq \
  --arg id "$FEATURE_ID" \
  --arg ts "$TIMESTAMP" \
  '
  .features = [
    .features[] |
    if .id == $id then
      .column = "in-progress" |
      .updated_at = $ts
    else
      .
    end
  ]
  ')

# =============================================================================
# Update state.json: set active feature
# =============================================================================

STATE=$(cat "$STATE_FILE")
UPDATED_STATE=$(echo "$STATE" | jq \
  --arg id "$FEATURE_ID" \
  --arg name "$FEATURE_NAME" \
  --arg ts "$TIMESTAMP" \
  '
  .active_feature.id = $id |
  .active_feature.name = $name |
  .active_feature.phase = "plan" |
  .active_feature.phases_completed = [] |
  .updated_at = $ts
  ')

# =============================================================================
# Write both files atomically
# =============================================================================

if ! atomic_write "$BACKLOG_FILE" "$UPDATED_BACKLOG"; then
  echo "ERROR: Failed to write backlog.json" >&2
  release_lock
  exit 1
fi

if ! atomic_write "$STATE_FILE" "$UPDATED_STATE"; then
  echo "ERROR: Failed to write state.json" >&2
  release_lock
  exit 1
fi

release_lock

# =============================================================================
# Output result as JSON
# =============================================================================

jq -n \
  --argjson claimed true \
  --arg feature_id "$FEATURE_ID" \
  --arg feature_name "$FEATURE_NAME" \
  --argjson priority "$FEATURE_PRIORITY" \
  --argjson acceptance_criteria "$ACCEPTANCE_CRITERIA" \
  '{
    claimed: $claimed,
    feature_id: $feature_id,
    feature_name: $feature_name,
    priority: $priority,
    acceptance_criteria: $acceptance_criteria
  }'

exit 0
