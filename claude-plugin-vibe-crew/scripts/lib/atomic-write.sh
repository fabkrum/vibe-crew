#!/usr/bin/env bash
# scripts/lib/atomic-write.sh
# Shared atomic write with JSON validation for state files.
# Usage:
#   source "$(dirname "$0")/lib/atomic-write.sh"
#   atomic_write <target-file> <json-content> [--no-backup]
#
# Behavior:
#   - PID-suffixed temp files (${target}.tmp.$$) to eliminate race conditions
#   - Creates .bak before writing (unless --no-backup passed)
#   - Validates JSON via jq empty before atomic mv
#   - On validation failure: restores from .bak (if it exists), removes temp file
#   - Never deletes .bak — callers manage rollback and cleanup

atomic_write() {
  local target="$1"
  local content="$2"
  local no_backup=false

  if [[ "${3:-}" == "--no-backup" ]]; then
    no_backup=true
  fi

  local tmp="${target}.tmp.$$"
  local backup="${target}.bak"

  # Create backup (unless --no-backup)
  if [[ "$no_backup" == "false" && -f "$target" ]]; then
    cp "$target" "$backup"
  fi

  # Write to PID-suffixed temp file
  echo "$content" > "$tmp"

  # Validate JSON
  if ! jq empty "$tmp" 2>/dev/null; then
    echo "ERROR: JSON validation failed for $target" >&2
    rm -f "$tmp"
    # Restore from backup if available
    if [[ -f "$backup" ]]; then
      cp "$backup" "$target"
    fi
    return 1
  fi

  # Atomic rename
  mv "$tmp" "$target"
  return 0
}
