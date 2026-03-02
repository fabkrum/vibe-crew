#!/usr/bin/env bash
# scripts/update-backlog-raw.sh
# Locked backlog.json updater for arbitrary jq expressions.
# Mirrors update-state.sh but targets backlog.json.
# Usage: update-backlog-raw.sh [--dry-run] '<jq-expression>' [--arg key val ...]
# Example: update-backlog-raw.sh '.features += [{id: "feat-001", name: "New"}]'
# Example: update-backlog-raw.sh '(.features[] | select(.id == "feat-001")) |= (.column = "blocked")' --arg reason "Tests failed"
# Exit 0 on success, Exit 1 on failure

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"
BACKLOG_FILE="$VIBECREW_DIR/backlog.json"

DRY_RUN=false

# Parse arguments: extract --dry-run and the jq expression, pass remainder as extra jq args
JQ_EXPR=""
EXTRA_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --arg|--argjson)
      # Collect jq argument pairs
      EXTRA_ARGS+=("$1" "$2" "$3")
      shift 3
      ;;
    *)
      if [[ -z "$JQ_EXPR" ]]; then
        JQ_EXPR="$1"
      else
        EXTRA_ARGS+=("$1")
      fi
      shift
      ;;
  esac
done

if [[ -z "$JQ_EXPR" ]]; then
  echo "Usage: update-backlog-raw.sh [--dry-run] '<jq-expression>' [--arg key val ...]" >&2
  exit 1
fi

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

# Allow expressions starting with dot-path OR open paren (for select patterns)
if ! echo "$JQ_EXPR" | grep -qE '^\.[a-zA-Z_]|^\(' 2>/dev/null; then
  echo "ERROR: jq expression must start with a dot-path accessor or parenthesized selector" >&2
  exit 1
fi

if [[ ! -f "$BACKLOG_FILE" ]]; then
  echo "ERROR: backlog.json not found." >&2
  exit 1
fi

# Source shared lock library
source "$(dirname "$0")/lib/lock.sh"

acquire_state_lock "update-backlog-raw"

# Read current backlog
CONTENT=$(cat "$BACKLOG_FILE")

# Apply jq expression with any extra args
UPDATED=$(echo "$CONTENT" | jq "${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}" "$JQ_EXPR" 2>&1) || {
  echo "ERROR: jq expression failed: $UPDATED" >&2
  release_state_lock
  exit 1
}

# Dry-run mode: show diff and exit
if [[ "$DRY_RUN" == "true" ]]; then
  echo "DRY RUN — Changes that would be applied:"
  echo ""
  echo "Before:"
  jq . "$BACKLOG_FILE" 2>/dev/null
  echo ""
  echo "After:"
  echo "$UPDATED" | jq .
  release_state_lock
  exit 0
fi

# Validate JSON
TMP="${BACKLOG_FILE}.tmp.$$"
echo "$UPDATED" > "$TMP"
if ! jq empty "$TMP" 2>/dev/null; then
  echo "ERROR: JSON validation failed after jq expression" >&2
  rm -f "$TMP"
  release_state_lock
  exit 1
fi

# Atomic rename
mv "$TMP" "$BACKLOG_FILE"

release_state_lock
exit 0
