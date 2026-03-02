#!/usr/bin/env bash
# scripts/validate-phase-transition.sh
# PreToolUse hook for Bash -- validates complete-phase.sh invocations
# Ensures phase transitions follow the correct order and foundation artifacts are complete.
# Exit 0 = allow, Exit 2 = deny with hookSpecificOutput

set -euo pipefail

# --- Parse input ---
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only apply to Bash tool
if [[ "$TOOL_NAME" != "Bash" ]]; then
  exit 0
fi

# Fast exit for commands not involving complete-phase.sh (99.9% of Bash calls)
if [[ "$COMMAND" != *"complete-phase.sh"* ]]; then
  exit 0
fi

# --- Helper: deny with message ---
deny() {
  local reason="$1"
  local escaped
  escaped=$(printf '%s' "$reason" | jq -Rs '.')
  cat <<HOOK_OUTPUT
{
  "hookSpecificOutput": {
    "permissionDecision": "deny",
    "reason": $escaped
  }
}
HOOK_OUTPUT
  exit 2
}

# --- Locate state.json ---
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE_FILE="$PROJECT_ROOT/.vibecrew/state.json"

# Missing state.json: allow (let complete-phase.sh handle its own error)
if [[ ! -f "$STATE_FILE" ]]; then
  exit 0
fi

# =============================================================================
# Foundation mode: complete-phase.sh foundation
# =============================================================================

if echo "$COMMAND" | grep -qE 'complete-phase\.sh\s+foundation'; then
  # Check ALL artifact statuses are "complete" or "skipped"
  INCOMPLETE=$(jq -r '
    [.foundation.artifacts | to_entries[] |
     select(.value.status != "complete" and .value.status != "skipped") |
     .key] | join(", ")' "$STATE_FILE" 2>/dev/null || true)

  if [[ -n "$INCOMPLETE" ]]; then
    deny "Cannot complete foundation: the following artifacts are not complete or skipped: $INCOMPLETE"
  fi

  exit 0
fi

# =============================================================================
# Feature mode: complete-phase.sh <feature-id> <phase>
# =============================================================================

# Extract the phase argument (second arg after complete-phase.sh)
# Pattern: complete-phase.sh <feature-id> <phase>
PHASE=$(echo "$COMMAND" | grep -oE 'complete-phase\.sh\s+\S+\s+(\S+)' | awk '{print $3}' || true)

if [[ -z "$PHASE" ]]; then
  # Can't parse phase — let complete-phase.sh handle validation
  exit 0
fi

# Get active feature's current phase and completed phases
ACTIVE_PHASE=$(jq -r '.active_feature.phase // empty' "$STATE_FILE" 2>/dev/null || true)
PHASES_COMPLETED=$(jq -r '.active_feature.phases_completed // [] | join(",")' "$STATE_FILE" 2>/dev/null || true)

# Check: completed phase must match active_feature.phase
if [[ -n "$ACTIVE_PHASE" ]] && [[ "$ACTIVE_PHASE" != "null" ]]; then
  if [[ "$PHASE" != "$ACTIVE_PHASE" ]]; then
    deny "Cannot complete phase '$PHASE': active feature is in phase '$ACTIVE_PHASE'"
  fi
fi

# Check: phase must not already be in phases_completed
if [[ -n "$PHASES_COMPLETED" ]]; then
  IFS=',' read -ra COMPLETED_ARRAY <<< "$PHASES_COMPLETED"
  for completed in "${COMPLETED_ARRAY[@]}"; do
    if [[ "$completed" == "$PHASE" ]]; then
      deny "Phase '$PHASE' has already been completed for the active feature"
    fi
  done
fi

exit 0
