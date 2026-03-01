#!/usr/bin/env bash
# scripts/phase-gate.sh
# PreToolUse hook for Write|Edit -- blocks source code writes before foundation
# Exit 0 = allow, Exit 2 = deny with hookSpecificOutput

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE_FILE="$PROJECT_ROOT/.vibecrew/state.json"

# --- Parse input ---
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only apply to Write and Edit tools
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
  exit 0
fi

# Skip if no file path
if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# --- Check foundation status ---
if [[ ! -f "$STATE_FILE" ]]; then
  # No state file -- allow writes to .vibecrew/ itself (bootstrap)
  if [[ "$FILE_PATH" == *".vibecrew/"* ]]; then
    exit 0
  fi
  # Allow writes to plugin directories
  if [[ "$FILE_PATH" == *"claude-plugin-vibe-crew/"* ]]; then
    exit 0
  fi
  cat <<'HOOK_OUTPUT'
{
  "hookSpecificOutput": {
    "permissionDecision": "deny",
    "reason": "VibeCrew state not initialized. Run /setup first to create .vibecrew/ directory."
  }
}
HOOK_OUTPUT
  exit 2
fi

# Read foundation.complete from the canonical state.json schema
FOUNDATION_COMPLETE=$(jq -r '.foundation.complete // false' "$STATE_FILE" 2>/dev/null || echo "false")

# If foundation is complete, all writes are allowed
if [[ "$FOUNDATION_COMPLETE" == "true" ]]; then
  exit 0
fi

# --- Foundation is incomplete -- check if this is a planning artifact ---

RELATIVE_PATH="${FILE_PATH#$PROJECT_ROOT/}"
FILENAME=$(basename "$FILE_PATH")

# Always-allowed patterns during Tier 1
ALLOWED_PATTERNS=(
  "CLAUDE.md"
  "VISION.md"
  "design-system.css"
  "design-brief.md"
  "roadmap.md"
  ".vibecrew/"
  "docs/"
  "tdr/"
  "research/"
  "*.mmd"
  "package.json"
  "package-lock.json"
  "tsconfig.json"
  ".gitignore"
  ".env.example"
  ".prettierrc"
  ".eslintrc"
  "commitlint.config"
  "claude-plugin-vibe-crew/"
)

for pattern in "${ALLOWED_PATTERNS[@]}"; do
  if [[ "$RELATIVE_PATH" == "$pattern"* || "$FILENAME" == "$pattern"* ]]; then
    exit 0  # Planning artifact -- allow
  fi
done

# Check for TDR files by extension
if [[ "$FILENAME" == *.tdr.md ]]; then
  exit 0
fi

# --- This is a source code write during Tier 1 -- BLOCK ---

# Collect missing artifacts for the error message
MISSING=$(jq -r \
  '.foundation.artifacts | to_entries[] | select(.value.status != "complete") | "  - \(.key): \(.value.status)"' \
  "$STATE_FILE" 2>/dev/null || echo "  (unable to read state)")

REASON="Cannot write source code before the project foundation is complete.

File: $FILE_PATH

VibeCrew requires these Tier 1 artifacts before any source code:
  1. VISION.md -- Project goals and target users
  2. design-system.css -- Design tokens and component styles
  3. TDR -- Technology Decision Record
  4. roadmap.md -- Feature roadmap with priorities
  5. Architecture Diagrams -- Mermaid diagrams in .vibecrew/architecture/
  6. CLAUDE.md -- Project rules and conventions

Incomplete artifacts:
$MISSING

Run /new-project to complete the foundation, then /status to verify."

# Escape the reason for JSON
REASON_ESCAPED=$(echo "$REASON" | jq -Rs '.')

cat <<HOOK_OUTPUT
{
  "hookSpecificOutput": {
    "permissionDecision": "deny",
    "reason": $REASON_ESCAPED
  }
}
HOOK_OUTPUT
exit 2
