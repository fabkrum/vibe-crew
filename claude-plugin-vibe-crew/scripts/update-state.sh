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
# Consolidated check: block dangerous builtins as word matches in ANY context
if echo "$JQ_EXPR" | grep -qE '\b(env|debug|halt|halt_error|input|inputs|builtins|to_entries|from_entries|with_entries|keys_unsorted)\b' 2>/dev/null; then
  echo "ERROR: jq expression contains disallowed builtin reference" >&2
  exit 1
fi
# Block $ENV and ENV references (jq environment access)
if echo "$JQ_EXPR" | grep -qE '(\$ENV\b|\.ENV\b)' 2>/dev/null; then
  echo "ERROR: jq expression contains disallowed ENV reference" >&2
  exit 1
fi
# Block dangerous function calls with parens
if echo "$JQ_EXPR" | grep -qE '\b(@base64d|@sh|@html|@uri|getpath|setpath|delpaths|modulemeta|limit|first|last|range|ascii_downcase|ascii_upcase|implode|explode|tojson|fromjson|scan|test|match|capture|splits|sub|gsub|path|paths|leaf_paths|walk|recurse|reduce|foreach|label|break)\s*(\(|$)' 2>/dev/null; then
  echo "ERROR: jq expression contains disallowed function calls" >&2
  exit 1
fi
# Only allow safe state-update patterns: .key.path = value
if ! echo "$JQ_EXPR" | grep -qE '^\.[a-zA-Z_]' 2>/dev/null; then
  echo "ERROR: jq expression must start with a dot-path accessor" >&2
  exit 1
fi

# =============================================================================
# Semantic validation — enforce workflow invariants
# =============================================================================

# Block .foundation.complete = true when any artifact is not complete/skipped
if echo "$JQ_EXPR" | grep -qE '\.foundation\.complete\s*=\s*true' 2>/dev/null; then
  if [[ -f "$STATE_FILE" ]]; then
    INCOMPLETE=$(jq -r '
      [.foundation.artifacts | to_entries[] |
       select(.value.status != "complete" and .value.status != "skipped") |
       .key] | join(", ")' "$STATE_FILE" 2>/dev/null || true)
    if [[ -n "$INCOMPLETE" ]]; then
      echo "ERROR: Cannot set foundation.complete = true: incomplete artifacts: $INCOMPLETE" >&2
      exit 1
    fi
  fi
fi

# Block .active_feature.phase = "X" when X is not the legal next phase
if echo "$JQ_EXPR" | grep -qE '\.active_feature\.phase\s*=' 2>/dev/null; then
  # Extract the target phase value
  TARGET_PHASE=$(echo "$JQ_EXPR" | grep -oE '\.active_feature\.phase\s*=\s*"([^"]+)"' | sed 's/.*"\(.*\)"/\1/' || true)
  if [[ -n "$TARGET_PHASE" ]] && [[ -f "$STATE_FILE" ]]; then
    CURRENT_PHASE=$(jq -r '.active_feature.phase // empty' "$STATE_FILE" 2>/dev/null || true)
    # Allow "plan" as reset for new features (or when current phase is null/empty)
    if [[ "$TARGET_PHASE" != "plan" ]] && [[ -n "$CURRENT_PHASE" ]] && [[ "$CURRENT_PHASE" != "null" ]]; then
      # Read complexity from backlog for the active feature
      ACTIVE_FID=$(jq -r '.active_feature.id // empty' "$STATE_FILE" 2>/dev/null || true)
      FEATURE_COMPLEXITY="standard"
      if [[ -n "$ACTIVE_FID" ]] && [[ -f "$VIBECREW_DIR/backlog.json" ]]; then
        FEATURE_COMPLEXITY=$(jq -r --arg fid "$ACTIVE_FID" \
          '[.features[] | select(.id == $fid) | .complexity // "standard"] | .[0] // "standard"' \
          "$VIBECREW_DIR/backlog.json" 2>/dev/null || echo "standard")
      fi
      # Determine legal next phase from current (complexity-aware)
      case "$CURRENT_PHASE" in
        plan)
          if [[ "$FEATURE_COMPLEXITY" == "trivial" ]]; then LEGAL_NEXT="code"
          else LEGAL_NEXT="design"; fi ;;
        design) LEGAL_NEXT="code" ;;
        code)   LEGAL_NEXT="test" ;;
        test)
          if [[ "$FEATURE_COMPLEXITY" == "trivial" ]]; then LEGAL_NEXT="docs"
          else LEGAL_NEXT="review"; fi ;;
        review) LEGAL_NEXT="docs" ;;
        docs)   LEGAL_NEXT="done" ;;
        *)      LEGAL_NEXT="" ;;
      esac
      if [[ -n "$LEGAL_NEXT" ]] && [[ "$TARGET_PHASE" != "$LEGAL_NEXT" ]]; then
        echo "ERROR: Cannot set active_feature.phase to '$TARGET_PHASE': current phase is '$CURRENT_PHASE', legal next phase is '$LEGAL_NEXT'" >&2
        exit 1
      fi
    fi
  fi
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
