#!/usr/bin/env bash
# scripts/increment-plan-revision.sh
# Atomically increment plan_revision_count in state.json.
# Outputs the new count and warnings at thresholds.
# Usage: increment-plan-revision.sh
# Exit 0 on success, Exit 1 on failure

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE_FILE="$PROJECT_ROOT/.vibecrew/state.json"

if [[ ! -f "$STATE_FILE" ]]; then
  echo "ERROR: state.json not found." >&2
  exit 1
fi

# Source shared libraries
source "$SCRIPT_DIR/lib/lock.sh"
source "$SCRIPT_DIR/lib/atomic-write.sh"

acquire_state_lock "increment-plan-revision"

# Read current count
CURRENT=$(jq -r '.active_feature.plan_revision_count // 0' "$STATE_FILE" 2>/dev/null || echo "0")
NEW_COUNT=$(( CURRENT + 1 ))

# Update atomically
UPDATED=$(jq --argjson count "$NEW_COUNT" \
  '.active_feature.plan_revision_count = $count' "$STATE_FILE")

if ! atomic_write "$STATE_FILE" "$UPDATED"; then
  echo "ERROR: Failed to write state.json" >&2
  rm -f "${STATE_FILE}.bak"
  release_state_lock
  exit 1
fi

rm -f "${STATE_FILE}.bak"
release_state_lock

echo "plan_revision_count: $NEW_COUNT"

if [[ "$NEW_COUNT" -ge 3 ]]; then
  echo "WARNING: Plan revised $NEW_COUNT times. Strongly recommend starting a fresh session with /compact or a new terminal. Repeated plan changes indicate the scope may need re-evaluation."
elif [[ "$NEW_COUNT" -ge 2 ]]; then
  echo "WARNING: Plan revised $NEW_COUNT times. Consider using /compact to reset context. Frequent plan changes reduce session efficiency (-5 Vibe Score)."
fi

exit 0
