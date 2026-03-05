#!/usr/bin/env bash
# scripts/context-monitor-posttool.sh
# PostToolUse hook: lightweight context window monitoring with debouncing.
# Runs after every tool use but only checks thresholds every N invocations
# to minimize performance impact.
# Uses additionalContext to inject warnings into the agent's context.
# Exit 0 always (never block the agent).

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"
CONFIG_FILE="$VIBECREW_DIR/config.json"
DEBOUNCE_FILE="$VIBECREW_DIR/.context-monitor-counter"

# --- Debounce: check every 5 tool uses ---
DEBOUNCE_INTERVAL=5

# Read and increment counter
COUNTER=0
if [[ -f "$DEBOUNCE_FILE" ]]; then
  COUNTER=$(cat "$DEBOUNCE_FILE" 2>/dev/null || echo "0")
fi
COUNTER=$((COUNTER + 1))
echo "$COUNTER" > "$DEBOUNCE_FILE" 2>/dev/null || true

# Only check on every Nth invocation
if (( COUNTER % DEBOUNCE_INTERVAL != 0 )); then
  exit 0
fi

# --- Read context usage from hook payload ---
INPUT=$(cat)
CONTEXT_USED=$(echo "$INPUT" | jq -r '.context_window_percent // empty' 2>/dev/null || echo "")

# No context data available — skip silently
if [[ -z "$CONTEXT_USED" || "$CONTEXT_USED" == "null" ]]; then
  exit 0
fi

USAGE_INT=${CONTEXT_USED%.*}  # Truncate to integer

# --- Read thresholds from config (with fallbacks matching VibeCrew defaults) ---
WARN_AT=45
CRITICAL_AT=60
DANGER_AT=80

if [[ -f "$CONFIG_FILE" ]]; then
  WARN_AT=$(jq -r '.context_warnings.warn_at_percent // 45' "$CONFIG_FILE" 2>/dev/null || echo "45")
  CRITICAL_AT=$(jq -r '.context_warnings.critical_at_percent // 60' "$CONFIG_FILE" 2>/dev/null || echo "60")
fi

# --- Emit warnings via additionalContext based on 3-fold thresholds ---
if [[ "$USAGE_INT" -ge "$DANGER_AT" ]]; then
  cat <<EOF
{"additionalContext": "CRITICAL: Context window at ${USAGE_INT}%. Stop current work immediately. Commit progress and start a fresh session or run /compact. Do not begin any new tasks."}
EOF
elif [[ "$USAGE_INT" -ge "$CRITICAL_AT" ]]; then
  cat <<EOF
{"additionalContext": "WARNING: Context window at ${USAGE_INT}% (threshold: ${CRITICAL_AT}%). Finish your current task and then compact or wrap. Do not start new work."}
EOF
elif [[ "$USAGE_INT" -ge "$WARN_AT" ]]; then
  cat <<EOF
{"additionalContext": "INFO: Context window at ${USAGE_INT}% (threshold: ${WARN_AT}%). Context entering caution zone. Consider wrapping up your current task soon."}
EOF
fi

exit 0
