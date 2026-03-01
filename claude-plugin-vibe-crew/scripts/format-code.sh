#!/usr/bin/env bash
# scripts/format-code.sh
# PostToolUse hook for Write|Edit -- auto-formats written files
# Detects project formatter and file type, runs formatter silently
# Exit 0 always (formatting failures should never block the agent)

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

source "$(dirname "$0")/lib/error-log.sh"

# Read hook payload from stdin
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only apply to Write and Edit tools
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
  exit 0
fi

# Skip if no file path or file doesn't exist
if [[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# Check if auto-formatting is enabled in config
AUTO_FORMAT=$(jq -r '.formatting.auto_format // true' "$PROJECT_ROOT/.vibecrew/config.json" 2>/dev/null || echo "true")
if [[ "$AUTO_FORMAT" == "false" ]]; then
  exit 0
fi

# Get configured formatter preference
FORMATTER=$(jq -r '.formatting.formatter // "prettier"' "$PROJECT_ROOT/.vibecrew/config.json" 2>/dev/null || echo "prettier")

# Get file extension
EXT="${FILE_PATH##*.}"

# Skip non-formattable files
case "$EXT" in
  json|md|yaml|yml|css|scss|less|js|jsx|ts|tsx|html|vue|svelte|graphql|gql)
    # Formattable -- continue
    ;;
  *)
    # Skip binary, image, and other non-text files
    exit 0
    ;;
esac

# Skip files outside project root (safety check)
CANONICAL=$(realpath "$FILE_PATH" 2>/dev/null || echo "$FILE_PATH")
PROJECT_CANONICAL=$(realpath "$PROJECT_ROOT" 2>/dev/null || echo "$PROJECT_ROOT")
if [[ "$CANONICAL" != "$PROJECT_CANONICAL"* ]]; then
  exit 0
fi

# --- Run formatter ---
case "$FORMATTER" in
  "prettier")
    if command -v npx &> /dev/null && [[ -f "$PROJECT_ROOT/node_modules/.bin/prettier" || -f "$PROJECT_ROOT/.prettierrc" || -f "$PROJECT_ROOT/.prettierrc.json" || -f "$PROJECT_ROOT/prettier.config.js" ]]; then
      npx prettier --write "$FILE_PATH" 2>/dev/null || log_error "format-code" "Failed to format with prettier: $FILE_PATH"
    fi
    ;;
  "biome")
    if command -v npx &> /dev/null && [[ -f "$PROJECT_ROOT/biome.json" || -f "$PROJECT_ROOT/biome.jsonc" ]]; then
      npx @biomejs/biome format --write "$FILE_PATH" 2>/dev/null || log_error "format-code" "Failed to format with biome: $FILE_PATH"
    fi
    ;;
  "none")
    # Formatting explicitly disabled
    ;;
  *)
    # Unknown formatter -- skip silently
    ;;
esac

exit 0
