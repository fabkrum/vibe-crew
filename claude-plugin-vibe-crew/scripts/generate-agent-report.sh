#!/usr/bin/env bash
# scripts/generate-agent-report.sh
# Merges agent metrics into session log agents[] array.
# Called during /wrap (Step 3.5) after collect-agent-metrics.sh.
# Usage: generate-agent-report.sh [session_id]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"
STATE_FILE="$VIBECREW_DIR/state.json"
AGENT_LOG_DIR="$VIBECREW_DIR/agent-logs"

source "$SCRIPT_DIR/lib/atomic-write.sh"

# --- Resolve session ID ---
SESSION_ID="${1:-}"
if [[ -z "$SESSION_ID" && -f "$STATE_FILE" ]]; then
  SESSION_ID=$(jq -r '.active_feature.session_id // "unknown"' "$STATE_FILE" 2>/dev/null || echo "unknown")
fi

METRICS_FILE="$AGENT_LOG_DIR/metrics-${SESSION_ID}.json"
SESSION_LOG="$VIBECREW_DIR/sessions/session-${SESSION_ID}.json"

# --- Validate inputs ---
if [[ ! -f "$METRICS_FILE" ]]; then
  echo "No metrics file: $METRICS_FILE (skipping agent report)"
  exit 0
fi

if [[ ! -f "$SESSION_LOG" ]]; then
  echo "No session log: $SESSION_LOG (skipping agent report)"
  exit 0
fi

# --- Merge metrics into session log agents[] ---
CURRENT_LOG=$(cat "$SESSION_LOG")
METRICS=$(cat "$METRICS_FILE")

# Build enriched agents array by merging metrics into existing agents[]
UPDATED_LOG=$(echo "$CURRENT_LOG" | jq --argjson metrics "$METRICS" '
  # Get existing agents array
  .agents as $existing_agents |
  # For each existing agent, merge metrics if available
  .agents = (
    if $existing_agents == null or ($existing_agents | length) == 0 then
      # No existing agents — create from metrics
      [$metrics.agents | to_entries[] | {
        agent: .key,
        metrics: .value
      }]
    else
      # Merge metrics into existing agents
      [$existing_agents[] | . as $agent |
        if $metrics.agents[$agent.agent] then
          $agent + { metrics: $metrics.agents[$agent.agent] }
        else
          $agent
        end
      ] +
      # Add agents from metrics not in existing array
      [$metrics.agents | to_entries[] |
        select(.key as $k | $existing_agents | map(.agent) | index($k) | not) |
        { agent: .key, metrics: .value }
      ]
    end
  ) |
  # Bump schema version
  .schema_version = "1.1.0"
')

if [[ -z "$UPDATED_LOG" ]]; then
  echo "Failed to merge agent metrics into session log"
  exit 1
fi

atomic_write "$SESSION_LOG" "$UPDATED_LOG"
echo "Agent report merged into: $SESSION_LOG"

exit 0
