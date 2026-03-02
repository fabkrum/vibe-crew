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

DRY_RUN=false

# Parse arguments
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    *) POSITIONAL_ARGS+=("$1"); shift ;;
  esac
done

if [[ ${#POSITIONAL_ARGS[@]} -lt 1 ]]; then
  echo "Usage: update-state.sh [--dry-run] '<jq-expression>'" >&2
  exit 1
fi

JQ_EXPR="${POSITIONAL_ARGS[0]}"

# Validate jq expression against allowlist — reject dangerous builtins
if echo "$JQ_EXPR" | grep -qE '\b(input|inputs|env|debug|halt|halt_error|builtins|@base64d|@sh|@html|@uri|getpath|delpaths|modulemeta|limit|first|last|range|ascii_downcase|ascii_upcase|implode|explode|tojson|fromjson|scan|test|match|capture|splits|sub|gsub)\s*\(' 2>/dev/null; then
  echo "ERROR: jq expression contains disallowed function calls" >&2
  exit 1
fi
# Block pipe-to-builtin and assignment-from-builtin patterns (no parens needed)
if echo "$JQ_EXPR" | grep -qE '\|\s*(env|debug|halt|halt_error|input|inputs|builtins)\b' 2>/dev/null; then
  echo "ERROR: jq expression contains disallowed builtin via pipe" >&2
  exit 1
fi
if echo "$JQ_EXPR" | grep -qE '=\s*(env|debug|halt|halt_error|input|inputs|builtins)\b' 2>/dev/null; then
  echo "ERROR: jq expression contains disallowed builtin via assignment" >&2
  exit 1
fi
# Only allow safe state-update patterns: .key.path = value
if ! echo "$JQ_EXPR" | grep -qE '^\.[a-zA-Z_]' 2>/dev/null; then
  echo "ERROR: jq expression must start with a dot-path accessor" >&2
  exit 1
fi

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

# Dry-run mode: show diff and exit
if [[ "$DRY_RUN" == "true" ]]; then
  echo "DRY RUN — Changes that would be applied:"
  echo ""
  echo "Before:"
  jq . "$STATE_FILE" 2>/dev/null
  echo ""
  echo "After:"
  echo "$UPDATED" | jq .
  release_state_lock
  exit 0
fi

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
