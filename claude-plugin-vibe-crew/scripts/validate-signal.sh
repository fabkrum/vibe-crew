#!/usr/bin/env bash
# scripts/validate-signal.sh
# PreToolUse hook for Write|Edit -- validates signal files in .vibecrew/signals/
# Ensures signal JSON has required fields, valid enums, and matching feature_id.
# Exit 0 = allow, Exit 2 = deny with hookSpecificOutput

set -euo pipefail

# --- Parse input ---
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only apply to Write tool (Edit patches can't be validated; initial Write was validated)
if [[ "$TOOL_NAME" != "Write" ]]; then
  exit 0
fi

# Fast exit for non-signal files (99.9% of writes)
if [[ "$FILE_PATH" != *".vibecrew/signals/"* ]] || [[ "$FILE_PATH" != *.json ]]; then
  exit 0
fi

# --- Extract file content from hook input ---
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // empty')

if [[ -z "$CONTENT" ]]; then
  exit 0
fi

# --- Validate JSON ---
if ! echo "$CONTENT" | jq empty 2>/dev/null; then
  cat <<'HOOK_OUTPUT'
{
  "hookSpecificOutput": {
    "permissionDecision": "deny",
    "reason": "Signal file contains invalid JSON."
  }
}
HOOK_OUTPUT
  exit 2
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

# --- Required fields ---
REQUIRED_FIELDS=("feature_id" "phase" "timestamp" "agent" "status")
for field in "${REQUIRED_FIELDS[@]}"; do
  VALUE=$(echo "$CONTENT" | jq -r ".$field // empty")
  if [[ -z "$VALUE" ]]; then
    deny "Signal file missing required field: $field"
  fi
done

# --- Enum validation ---

PHASE=$(echo "$CONTENT" | jq -r '.phase')
VALID_PHASES=("plan" "design" "code" "test" "review" "docs")
PHASE_VALID=false
for p in "${VALID_PHASES[@]}"; do
  if [[ "$p" == "$PHASE" ]]; then
    PHASE_VALID=true
    break
  fi
done
if [[ "$PHASE_VALID" == "false" ]]; then
  deny "Signal file has invalid phase: '$PHASE'. Must be one of: plan, design, code, test, review, docs"
fi

AGENT=$(echo "$CONTENT" | jq -r '.agent')
VALID_AGENTS=("builder" "verifier" "code-reviewer" "orchestrator" "ci-healer" "doc-generator" "performance-coach" "code-simplifier" "security-auditor" "code-auditor" "system-reviewer" "agent-observer")
AGENT_VALID=false
for a in "${VALID_AGENTS[@]}"; do
  if [[ "$a" == "$AGENT" ]]; then
    AGENT_VALID=true
    break
  fi
done
if [[ "$AGENT_VALID" == "false" ]]; then
  deny "Signal file has invalid agent: '$AGENT'. Must be one of: builder, verifier, code-reviewer, orchestrator, ci-healer, doc-generator, performance-coach, code-simplifier, security-auditor, code-auditor, system-reviewer"
fi

STATUS=$(echo "$CONTENT" | jq -r '.status')
VALID_STATUSES=("complete" "blocked" "error")
STATUS_VALID=false
for s in "${VALID_STATUSES[@]}"; do
  if [[ "$s" == "$STATUS" ]]; then
    STATUS_VALID=true
    break
  fi
done
if [[ "$STATUS_VALID" == "false" ]]; then
  deny "Signal file has invalid status: '$STATUS'. Must be one of: complete, blocked, error"
fi

# --- Cross-validation: feature_id must match active feature ---
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE_FILE="$PROJECT_ROOT/.vibecrew/state.json"

if [[ -f "$STATE_FILE" ]]; then
  ACTIVE_FEATURE_ID=$(jq -r '.active_feature.id // empty' "$STATE_FILE" 2>/dev/null || true)
  SIGNAL_FEATURE_ID=$(echo "$CONTENT" | jq -r '.feature_id')

  # Soft check: only enforce when active feature is set (non-null, non-empty)
  if [[ -n "$ACTIVE_FEATURE_ID" ]] && [[ "$ACTIVE_FEATURE_ID" != "null" ]]; then
    if [[ "$SIGNAL_FEATURE_ID" != "$ACTIVE_FEATURE_ID" ]]; then
      deny "Signal feature_id '$SIGNAL_FEATURE_ID' does not match active feature '$ACTIVE_FEATURE_ID' in state.json"
    fi
  fi
fi
# Missing state.json: allow (bootstrap/recovery)

exit 0
