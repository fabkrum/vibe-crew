#!/usr/bin/env bash
# scripts/update-backlog.sh
# Update feature fields in backlog.json with validation.
# Usage:
#   scripts/update-backlog.sh <feature-id> <field> <value>
# Examples:
#   scripts/update-backlog.sh feat-001 column testing
#   scripts/update-backlog.sh feat-001 priority 2
#   scripts/update-backlog.sh feat-001 spec.acceptance_criteria '["Login with email","OAuth support"]'
#   scripts/update-backlog.sh feat-001 worktree ".claude/worktrees/builder-feat-001"
# Idempotent: safe to run multiple times
# Exit 0 on success, Exit 1 on failure

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"
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
# Validation
# =============================================================================

if [[ ! -d "$VIBECREW_DIR" ]]; then
  echo "ERROR: .vibecrew/ directory not found. Run /setup first." >&2
  exit 1
fi

if [[ $# -lt 3 ]]; then
  echo "Usage: update-backlog.sh <feature-id> <field> <value>" >&2
  exit 1
fi

FEATURE_ID="$1"
FIELD_PATH="$2"
VALUE="$3"

if [[ ! -f "$BACKLOG_FILE" ]]; then
  echo "ERROR: backlog.json not found." >&2
  exit 1
fi

# =============================================================================
# Validate field path
# =============================================================================

ALLOWED_FIELDS=(
  "column"
  "priority"
  "labels"
  "description"
  "name"
  "worktree"
  "phases_completed"
  "sessions"
  "completed_at"
  "spec.acceptance_criteria"
  "spec.ui_description"
  "spec.business_logic"
  "spec.technical_notes"
  "source"
  "type"
  "github_issue_number"
  "github_issue_url"
)

FIELD_VALID=false
for f in "${ALLOWED_FIELDS[@]}"; do
  if [[ "$f" == "$FIELD_PATH" ]]; then
    FIELD_VALID=true
    break
  fi
done

if [[ "$FIELD_VALID" == "false" ]]; then
  echo "ERROR: Invalid field: $FIELD_PATH" >&2
  echo "Allowed fields: ${ALLOWED_FIELDS[*]}" >&2
  exit 1
fi

# =============================================================================
# Validate field-specific constraints
# =============================================================================

# Validate column values
if [[ "$FIELD_PATH" == "column" ]]; then
  VALID_COLUMNS=("idea" "planning" "planned" "in-progress" "testing" "review" "done")
  COLUMN_VALID=false
  for c in "${VALID_COLUMNS[@]}"; do
    if [[ "$c" == "$VALUE" ]]; then
      COLUMN_VALID=true
      break
    fi
  done
  if [[ "$COLUMN_VALID" == "false" ]]; then
    echo "ERROR: Invalid column '$VALUE'. Must be one of: ${VALID_COLUMNS[*]}" >&2
    exit 1
  fi
fi

# Validate priority is a positive integer
if [[ "$FIELD_PATH" == "priority" ]]; then
  if ! [[ "$VALUE" =~ ^[1-9][0-9]*$ ]]; then
    echo "ERROR: Priority must be a positive integer, got '$VALUE'" >&2
    exit 1
  fi
fi

# =============================================================================
# Acquire lock and read backlog
# =============================================================================

acquire_state_lock "update-backlog"

BACKLOG=$(cat "$BACKLOG_FILE")

# =============================================================================
# Find the feature by ID
# =============================================================================

FEATURE_INDEX=$(echo "$BACKLOG" | jq --arg id "$FEATURE_ID" \
  '[.features | to_entries[] | select(.value.id == $id) | .key] | .[0] // -1')

if [[ "$FEATURE_INDEX" == "-1" ]] || [[ "$FEATURE_INDEX" == "null" ]]; then
  echo "ERROR: Feature '$FEATURE_ID' not found in backlog." >&2
  release_state_lock
  exit 1
fi

# =============================================================================
# Build the jq update expression
# =============================================================================

# Determine if value is raw JSON or a string
IS_RAW_JSON=false
if [[ "$VALUE" == "["* ]] || [[ "$VALUE" == "{"* ]]; then
  # Validate it's actually valid JSON
  if echo "$VALUE" | jq empty 2>/dev/null; then
    IS_RAW_JSON=true
  fi
fi

# Handle numeric fields (priority)
IS_NUMBER=false
if [[ "$FIELD_PATH" == "priority" ]]; then
  IS_NUMBER=true
fi

# Build jq path from dot-separated field path
# e.g., "spec.acceptance_criteria" -> .features[$idx].spec.acceptance_criteria
JQ_PATH=".features[$FEATURE_INDEX]"
IFS='.' read -ra PARTS <<< "$FIELD_PATH"
for part in "${PARTS[@]}"; do
  JQ_PATH="${JQ_PATH}.${part}"
done

# Build the jq expression
if [[ "$IS_RAW_JSON" == "true" ]]; then
  UPDATED_BACKLOG=$(echo "$BACKLOG" | jq \
    --argjson idx "$FEATURE_INDEX" \
    --argjson val "$VALUE" \
    --arg ts "$TIMESTAMP" \
    "${JQ_PATH} = \$val | .features[\$idx].updated_at = \$ts")
elif [[ "$IS_NUMBER" == "true" ]]; then
  UPDATED_BACKLOG=$(echo "$BACKLOG" | jq \
    --argjson idx "$FEATURE_INDEX" \
    --argjson val "$VALUE" \
    --arg ts "$TIMESTAMP" \
    "${JQ_PATH} = \$val | .features[\$idx].updated_at = \$ts")
else
  UPDATED_BACKLOG=$(echo "$BACKLOG" | jq \
    --argjson idx "$FEATURE_INDEX" \
    --arg val "$VALUE" \
    --arg ts "$TIMESTAMP" \
    "${JQ_PATH} = \$val | .features[\$idx].updated_at = \$ts")
fi

# =============================================================================
# Write atomically
# =============================================================================

if ! atomic_write "$BACKLOG_FILE" "$UPDATED_BACKLOG"; then
  echo "ERROR: Failed to write backlog.json" >&2
  release_state_lock
  exit 1
fi

release_state_lock

# Truncate long values for the summary
DISPLAY_VALUE="$VALUE"
if [[ ${#DISPLAY_VALUE} -gt 80 ]]; then
  DISPLAY_VALUE="${DISPLAY_VALUE:0:77}..."
fi

echo "Updated $FEATURE_ID.$FIELD_PATH = $DISPLAY_VALUE"
exit 0
