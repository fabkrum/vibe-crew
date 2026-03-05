#!/usr/bin/env bash
# scripts/collect-agent-metrics.sh
# Reads session JSONL agent log, outputs per-agent metrics JSON.
# Called during /wrap (Step 3.5).
# Usage: collect-agent-metrics.sh [session_id]
# Output: Writes .vibecrew/agent-logs/metrics-{session_id}.json

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"
STATE_FILE="$VIBECREW_DIR/state.json"
CONFIG_FILE="$VIBECREW_DIR/config.json"
AGENT_LOG_DIR="$VIBECREW_DIR/agent-logs"

# --- Early exit if observability disabled ---
if [[ -f "$CONFIG_FILE" ]]; then
  ENABLED=$(jq -r 'if .agent_observability.enabled == false then "false" else "true" end' "$CONFIG_FILE" 2>/dev/null || echo "true")
  [[ "$ENABLED" == "false" ]] && { echo "Agent observability disabled"; exit 0; }
fi

# --- Resolve session ID ---
SESSION_ID="${1:-}"
if [[ -z "$SESSION_ID" && -f "$STATE_FILE" ]]; then
  SESSION_ID=$(jq -r '.active_feature.session_id // "unknown"' "$STATE_FILE" 2>/dev/null || echo "unknown")
fi

LOG_FILE="$AGENT_LOG_DIR/session-${SESSION_ID}.jsonl"
METRICS_FILE="$AGENT_LOG_DIR/metrics-${SESSION_ID}.json"

if [[ ! -f "$LOG_FILE" ]]; then
  echo "No agent log found: $LOG_FILE"
  exit 0
fi

# --- Aggregate per-agent metrics from JSONL ---
# Uses a single awk+jq pass for efficiency
METRICS=$(jq -s '
  group_by(.agent) | map({
    agent: .[0].agent,
    total_tool_calls: length,
    progress_calls: [.[] | select(.class == "progress")] | length,
    exploration_calls: [.[] | select(.class == "exploration")] | length,
    neutral_calls: [.[] | select(.class == "neutral")] | length,
    failed_calls: [.[] | select(.exit != 0)] | length,
    efficiency_ratio: (
      ([.[] | select(.class == "progress")] | length) /
      (if length == 0 then 1 else length end)
      | . * 100 | round / 100
    ),
    files_touched: [.[].target | select(. != "" and . != null)] | unique,
    files_created: [.[] | select(.tool == "Write" and .class == "progress")] | length,
    files_modified: [.[] | select(.tool == "Edit" and .class == "progress")] | length,
    tools_used: (
      group_by(.tool) | map({key: .[0].tool, value: length}) | from_entries
    ),
    repeated_reads: (
      [.[] | select(.tool == "Read") | .target] |
      group_by(.) | map(select(length > 1)) | length
    )
  }) | {
    agents: (map({(.agent): del(.agent)}) | add // {}),
    total_entries: (map(.total_tool_calls) | add // 0)
  } | {
    session_id: "'"$SESSION_ID"'",
    collected_at: (now | todate),
    agents: .agents,
    total_entries: .total_entries
  }
' "$LOG_FILE" 2>/dev/null)

if [[ -z "$METRICS" ]]; then
  echo "Failed to aggregate metrics"
  exit 1
fi

# --- Write metrics file ---
echo "$METRICS" | jq '.' > "$METRICS_FILE"
echo "Agent metrics collected: $METRICS_FILE"

# --- Prune old log files ---
MAX_LOG_FILES=50
if [[ -f "$CONFIG_FILE" ]]; then
  MAX_LOG_FILES=$(jq -r '.agent_observability.max_log_files // 50' "$CONFIG_FILE" 2>/dev/null || echo "50")
fi

LOG_COUNT=$(find "$AGENT_LOG_DIR" -name "session-*.jsonl" -type f 2>/dev/null | wc -l | tr -d ' ')
if [[ "$LOG_COUNT" -gt "$MAX_LOG_FILES" ]]; then
  PRUNE_COUNT=$((LOG_COUNT - MAX_LOG_FILES))
  find "$AGENT_LOG_DIR" -name "session-*.jsonl" -type f -print0 2>/dev/null | \
    xargs -0 ls -t | tail -n "$PRUNE_COUNT" | while read -r old_file; do
    rm -f "$old_file"
    # Also remove matching metrics file
    rm -f "${old_file%.jsonl}.json" 2>/dev/null || true
  done
  echo "Pruned $PRUNE_COUNT old agent log files"
fi

exit 0
