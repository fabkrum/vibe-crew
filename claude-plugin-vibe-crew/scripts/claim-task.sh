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

acquire_state_lock "claim-task"

BACKLOG=$(cat "$BACKLOG_FILE")

# =============================================================================
# Find the feature to claim
# =============================================================================

if [[ -n "$FEATURE_ID" ]]; then
  # Specific feature requested -- verify it exists and is in "planned" column
  FEATURE_JSON=$(echo "$BACKLOG" | jq --arg id "$FEATURE_ID" \
    '[.features[] | select(.id == $id)] | .[0] // null')

  if [[ "$FEATURE_JSON" == "null" ]]; then
    echo "ERROR: Feature '$FEATURE_ID' not found in backlog." >&2
    release_state_lock
    exit 1
  fi

  FEATURE_COLUMN=$(echo "$FEATURE_JSON" | jq -r '.column // "unknown"')
  if [[ "$FEATURE_COLUMN" != "planned" ]]; then
    echo "ERROR: Feature '$FEATURE_ID' is in column '$FEATURE_COLUMN', not 'planned'." >&2
    release_state_lock
    exit 1
  fi
else
  # Auto-select: find highest-priority planned feature

  # Check WIP limit first
  WIP_LIMIT=$(echo "$BACKLOG" | jq \
    '[.columns[] | select(.id == "in-progress") | .wip_limit] | .[0] // null')
  IN_PROGRESS_COUNT=$(echo "$BACKLOG" | jq \
    '[.features[] | select(.column == "in-progress")] | length')

  if [[ "$WIP_LIMIT" != "null" ]] && [[ "$IN_PROGRESS_COUNT" -ge "$WIP_LIMIT" ]]; then
    echo "ERROR: WIP limit reached. $IN_PROGRESS_COUNT feature(s) already in-progress (limit: $WIP_LIMIT)." >&2
    release_state_lock
    exit 1
  fi

  # Get all planned features sorted by priority (lowest number = highest priority)
  READY_FEATURES=$(echo "$BACKLOG" | jq \
    '[.features[] | select(.column == "planned")] | sort_by(.priority // 999)')

  READY_COUNT=$(echo "$READY_FEATURES" | jq 'length')

  if [[ "$READY_COUNT" -eq 0 ]]; then
    echo "No planned features."
    release_state_lock
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
    release_state_lock
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
        release_state_lock
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
# Write both files atomically (with write-ahead journal)
# =============================================================================

# Prepare write-ahead journal (both intended states recorded before any write)
prepare_dual_write "$VIBECREW_DIR" "$BACKLOG_FILE" "$UPDATED_BACKLOG" "$STATE_FILE" "$UPDATED_STATE"

if ! atomic_write "$BACKLOG_FILE" "$UPDATED_BACKLOG"; then
  echo "ERROR: Failed to write backlog.json" >&2
  # Do NOT finalize journal — let sync-state.sh recover from it
  release_state_lock
  exit 1
fi

if ! atomic_write "$STATE_FILE" "$UPDATED_STATE"; then
  echo "ERROR: Failed to write state.json, rolling back backlog.json" >&2
  # Rollback backlog from backup (mv is atomic on same filesystem)
  if [[ -f "${BACKLOG_FILE}.bak" ]]; then
    mv "${BACKLOG_FILE}.bak" "$BACKLOG_FILE"
  fi
  # Do NOT finalize journal — let sync-state.sh recover from it
  rm -f "${STATE_FILE}.bak"
  release_state_lock
  exit 1
fi

# Both writes succeeded — clean up journal and backups
finalize_dual_write "$VIBECREW_DIR"
rm -f "${BACKLOG_FILE}.bak" "${STATE_FILE}.bak"

release_state_lock

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
