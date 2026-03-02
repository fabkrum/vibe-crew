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
VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"
STATE_FILE="$VIBECREW_DIR/state.json"
BACKLOG_FILE="$VIBECREW_DIR/backlog.json"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# =============================================================================
# Shared locking
# =============================================================================

source "$(dirname "$0")/lib/lock.sh"

# =============================================================================
# Atomic write with validation (shared library)
# =============================================================================

source "$(dirname "$0")/lib/atomic-write.sh"

# =============================================================================
# Write-ahead journal for dual-file atomicity
# =============================================================================

source "$(dirname "$0")/lib/dual-write.sh"

# =============================================================================
# Validation
# =============================================================================

if [[ ! -d "$VIBECREW_DIR" ]]; then
  echo "ERROR: .vibecrew/ directory not found. Run /setup first." >&2
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

  acquire_state_lock "complete-phase-foundation"

  UPDATED=$(jq \
    --arg ts "$TIMESTAMP" \
    '.foundation.complete = true | .foundation.completed_at = $ts | .updated_at = $ts' \
    "$STATE_FILE")

  if ! atomic_write "$STATE_FILE" "$UPDATED"; then
    echo "ERROR: Failed to write state.json" >&2
    rm -f "${STATE_FILE}.bak"
    release_state_lock
    exit 1
  fi

  rm -f "${STATE_FILE}.bak"
  release_state_lock
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
VALID_PHASES=("plan" "design" "code" "test" "review" "docs")
PHASE_VALID=false
for p in "${VALID_PHASES[@]}"; do
  if [[ "$p" == "$COMPLETED_PHASE" ]]; then
    PHASE_VALID=true
    break
  fi
done

if [[ "$PHASE_VALID" == "false" ]]; then
  echo "ERROR: Invalid phase '$COMPLETED_PHASE'. Must be one of: plan, design, code, test, review, docs" >&2
  exit 1
fi

# Determine next column based on completed phase
determine_next_column() {
  local phase="$1"
  case "$phase" in
    plan)   echo "planned" ;;
    design) echo "in-progress" ;;
    code)   echo "testing" ;;
    test)   echo "review" ;;
    review) echo "review" ;;
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
    test)   echo "review" ;;
    review) echo "docs" ;;
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
acquire_state_lock "complete-phase"

# Read backlog
BACKLOG=$(cat "$BACKLOG_FILE")

# Find the feature by ID
FEATURE_INDEX=$(echo "$BACKLOG" | jq --arg id "$FEATURE_ID" \
  '[.features | to_entries[] | select(.value.id == $id) | .key] | .[0] // -1')

if [[ "$FEATURE_INDEX" == "-1" ]] || [[ "$FEATURE_INDEX" == "null" ]]; then
  echo "ERROR: Feature '$FEATURE_ID' not found in backlog." >&2
  release_state_lock
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

# Prepare write-ahead journal (both intended states recorded before any write)
prepare_dual_write "$VIBECREW_DIR" "$BACKLOG_FILE" "$UPDATED_BACKLOG" "$STATE_FILE" "$UPDATED_STATE"

# Write backlog atomically
if ! atomic_write "$BACKLOG_FILE" "$UPDATED_BACKLOG"; then
  echo "ERROR: Failed to write backlog.json" >&2
  finalize_dual_write "$VIBECREW_DIR"
  rm -f "${BACKLOG_FILE}.bak" "${STATE_FILE}.bak"
  release_state_lock
  exit 1
fi

# Write state atomically
if ! atomic_write "$STATE_FILE" "$UPDATED_STATE"; then
  echo "ERROR: Failed to write state.json, rolling back backlog.json" >&2
  # Rollback backlog from backup (mv is atomic on same filesystem)
  if [[ -f "${BACKLOG_FILE}.bak" ]]; then
    mv "${BACKLOG_FILE}.bak" "$BACKLOG_FILE"
  fi
  finalize_dual_write "$VIBECREW_DIR"
  rm -f "${STATE_FILE}.bak"
  release_state_lock
  exit 1
fi

# Both writes succeeded — clean up journal and backups
finalize_dual_write "$VIBECREW_DIR"
rm -f "${BACKLOG_FILE}.bak" "${STATE_FILE}.bak"

release_state_lock

echo "$FEATURE_ID: completed $COMPLETED_PHASE, now in $NEXT_COLUMN"
exit 0
