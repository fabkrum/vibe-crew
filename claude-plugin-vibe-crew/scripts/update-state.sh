#!/usr/bin/env bash
# scripts/update-state.sh
# Locked state.json updater for use by SKILL.md files and other scripts.
# Usage: update-state.sh '<jq-expression>'
# Example: update-state.sh '.foundation.artifacts.vision.status = "complete"'
# Exit 0 on success, Exit 1 on failure

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"
STATE_FILE="$VIBECREW_DIR/state.json"

if [[ $# -lt 1 ]]; then
  echo "Usage: update-state.sh '<jq-expression>'" >&2
  exit 1
fi

JQ_EXPR="$1"

if [[ ! -f "$STATE_FILE" ]]; then
  echo "ERROR: state.json not found." >&2
  exit 1
fi

# Source shared lock library
source "$(dirname "$0")/lib/lock.sh"

acquire_state_lock "update-state"

# Read current state
CONTENT=$(cat "$STATE_FILE")

# Apply jq expression
UPDATED=$(echo "$CONTENT" | jq "$JQ_EXPR" 2>&1) || {
  echo "ERROR: jq expression failed: $UPDATED" >&2
  release_state_lock
  exit 1
}

# Validate JSON
TMP="${STATE_FILE}.tmp.$$"
echo "$UPDATED" > "$TMP"
if ! jq empty "$TMP" 2>/dev/null; then
  echo "ERROR: JSON validation failed after jq expression" >&2
  rm -f "$TMP"
  release_state_lock
  exit 1
fi

# Atomic rename
mv "$TMP" "$STATE_FILE"

release_state_lock
exit 0
