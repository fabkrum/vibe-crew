#!/usr/bin/env bash
# scripts/check-context.sh
# Stop hook: monitors context window usage and warns at thresholds
# Also cleans up stale signal files (>1 hour old)
# Exit 0 always (never block the agent)

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# Load cross-platform helpers
source "$(dirname "$0")/lib/compat.sh"
CONFIG_FILE="$PROJECT_ROOT/.vibecrew/config.json"
SIGNALS_DIR="$PROJECT_ROOT/.vibecrew/signals"

# --- Read thresholds from config ---
WARN_AT=60
CRITICAL_AT=80

if [[ -f "$CONFIG_FILE" ]]; then
  WARN_AT=$(jq -r '.context_warnings.warn_at_percent // 60' "$CONFIG_FILE" 2>/dev/null || echo "60")
  CRITICAL_AT=$(jq -r '.context_warnings.critical_at_percent // 80' "$CONFIG_FILE" 2>/dev/null || echo "80")
fi

# --- Read context usage from hook payload ---
INPUT=$(cat)
CONTEXT_USED=$(echo "$INPUT" | jq -r '.context_window_percent // empty' 2>/dev/null || echo "")

# If context usage is available, check thresholds
if [[ -n "$CONTEXT_USED" && "$CONTEXT_USED" != "null" ]]; then
  USAGE_INT=${CONTEXT_USED%.*}  # Truncate to integer

  if [[ "$USAGE_INT" -ge 90 ]]; then
    echo "DANGER: Context window at ${USAGE_INT}%. Agent quality severely degraded."
    echo "  IMMEDIATELY run /wrap to end this session."
    echo "  Do not attempt complex operations."
  elif [[ "$USAGE_INT" -ge "$CRITICAL_AT" ]]; then
    echo "CRITICAL: Context window at ${USAGE_INT}% (threshold: ${CRITICAL_AT}%)."
    echo "  Commit current work and run /wrap to end this session."
    echo "  Consider delegating remaining work to a sub-agent."
  elif [[ "$USAGE_INT" -ge "$WARN_AT" ]]; then
    echo "WARNING: Context window at ${USAGE_INT}% (threshold: ${WARN_AT}%)."
    echo "  Start wrapping up. Commit working code."
  fi
fi

# --- Clean up stale signal files (older than 1 hour) ---
if [[ -d "$SIGNALS_DIR" ]]; then
  find "$SIGNALS_DIR" -name "*.signal" -mmin +60 -delete 2>/dev/null || true
fi

# --- Clean up stale lock files (older than timeout) ---
LOCKS_DIR="$PROJECT_ROOT/.vibecrew/locks"
if [[ -d "$LOCKS_DIR" ]]; then
  for lock_dir in "$LOCKS_DIR"/*/; do
    [[ -d "$lock_dir" ]] || continue
    INFO_FILE="$lock_dir/info.json"
    if [[ -f "$INFO_FILE" ]]; then
      LOCKED_AT=$(jq -r '.locked_at // empty' "$INFO_FILE" 2>/dev/null || echo "")
      TIMEOUT=$(jq -r '.timeout_seconds // 60' "$INFO_FILE" 2>/dev/null || echo "60")
      if [[ -n "$LOCKED_AT" ]]; then
        LOCKED_EPOCH=$(_compat_parse_timestamp "$LOCKED_AT")
        NOW_EPOCH=$(date "+%s")
        ELAPSED=$(( NOW_EPOCH - LOCKED_EPOCH ))
        if [[ "$ELAPSED" -gt "$TIMEOUT" ]]; then
          # Only remove if owning process is dead
          _lock_pid=$(jq -r '.pid // empty' "$INFO_FILE" 2>/dev/null || echo "")
          if [[ -z "$_lock_pid" ]] || ! kill -0 "$_lock_pid" 2>/dev/null; then
            rm -rf "$lock_dir" 2>/dev/null || true
          fi
        fi
      fi
    else
      # Lock dir without info.json -- stale, remove
      rm -rf "$lock_dir" 2>/dev/null || true
    fi
  done
fi

exit 0
