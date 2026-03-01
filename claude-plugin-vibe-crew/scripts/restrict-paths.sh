#!/usr/bin/env bash
# scripts/restrict-paths.sh
# PreToolUse hook for Write|Edit -- blocks writes outside project root
# and to sensitive files.
# Exit 0 = allow, Exit 2 = deny with hookSpecificOutput

set -euo pipefail

# Source the shared sandbox module
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/sandbox.sh"

# Read hook payload from stdin
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only apply to Write and Edit tools
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
  exit 0
fi

# Skip if no file path provided
if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# Validate the write target
VALIDATION_OUTPUT=$(sandbox_validate_write "$FILE_PATH" 2>&1)
if [[ $? -ne 0 ]]; then
  ESCAPED_REASON=$(printf '%s' "$VALIDATION_OUTPUT" | jq -Rs '.')
  printf '{"hookSpecificOutput":{"permissionDecision":"deny","reason":%s}}' "$ESCAPED_REASON"
  exit 2
fi

# All checks passed
exit 0
