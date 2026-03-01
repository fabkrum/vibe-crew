#!/usr/bin/env bash
# scripts/lib/error-log.sh
# Utility for logging errors to .vibecrew/session-errors.jsonl
# Source this file and call log_error() instead of silencing failures with || true

# Resolve project root
_ERROR_LOG_PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
_ERROR_LOG_FILE="$_ERROR_LOG_PROJECT_ROOT/.vibecrew/session-errors.jsonl"

log_error() {
  local source="${1:-unknown}"
  local message="${2:-unspecified error}"
  local timestamp
  timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  # Ensure directory exists
  mkdir -p "$(dirname "$_ERROR_LOG_FILE")"

  # Append JSON line (escape special characters in message)
  local escaped_message
  escaped_message="$(echo "$message" | jq -Rs '.' 2>/dev/null || echo "\"$message\"")"

  printf '{"timestamp":"%s","source":"%s","message":%s}\n' \
    "$timestamp" "$source" "$escaped_message" \
    >> "$_ERROR_LOG_FILE" 2>/dev/null || true
}
