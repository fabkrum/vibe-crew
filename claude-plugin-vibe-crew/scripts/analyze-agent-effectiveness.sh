#!/usr/bin/env bash
# scripts/analyze-agent-effectiveness.sh
# Cross-session agent inefficiency detection.
# Reads last N session logs with agent metrics, detects recurring patterns.
# Called by Performance Coach during /wrap.
# Output: JSON with per-agent summaries and inefficiency patterns.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"
CONFIG_FILE="$VIBECREW_DIR/config.json"
SESSIONS_DIR="$VIBECREW_DIR/sessions"

# --- Early exit if observability disabled ---
if [[ -f "$CONFIG_FILE" ]]; then
  ENABLED=$(jq -r 'if .agent_observability.enabled == false then "false" else "true" end' "$CONFIG_FILE" 2>/dev/null || echo "true")
  [[ "$ENABLED" == "false" ]] && { echo '{"agents":[],"inefficiency_patterns":[]}'; exit 0; }
fi

# --- Configuration ---
MIN_SESSIONS=3
WRITE_AGENT_THRESHOLD=0.20
if [[ -f "$CONFIG_FILE" ]]; then
  MIN_SESSIONS=$(jq -r '.agent_observability.efficiency_thresholds.min_sessions // 3' "$CONFIG_FILE" 2>/dev/null || echo "3")
  WRITE_AGENT_THRESHOLD=$(jq -r '.agent_observability.efficiency_thresholds.write_agents // 0.20' "$CONFIG_FILE" 2>/dev/null || echo "0.20")
fi

# --- Collect recent session logs with agent metrics ---
SESSION_FILES=$(find "$SESSIONS_DIR" -name "session-*.json" -type f 2>/dev/null | sort -r | head -10)

if [[ -z "$SESSION_FILES" ]]; then
  echo '{"schema_version":"1.0.0","agents":[],"inefficiency_patterns":[]}'
  exit 0
fi

# --- Extract agent metrics from session logs ---
# Merge all agents[] arrays from recent sessions
AGENT_DATA=$(echo "$SESSION_FILES" | while read -r f; do
  jq -c '.agents[]? | select(.metrics != null) | {agent: .agent, metrics: .metrics, session: (input_filename | split("/") | last | split(".") | first)}' "$f" 2>/dev/null || true
done | jq -s '.')

if [[ -z "$AGENT_DATA" || "$AGENT_DATA" == "[]" ]]; then
  echo '{"schema_version":"1.0.0","agents":[],"inefficiency_patterns":[]}'
  exit 0
fi

# --- Agent classification ---
WRITE_AGENTS='["builder","verifier","ci-healer"]'
READ_AGENTS='["code-reviewer","code-auditor","security-auditor","system-reviewer","code-simplifier"]'

# --- Compute per-agent summaries and detect patterns ---
RESULT=$(echo "$AGENT_DATA" | jq --argjson write_agents "$WRITE_AGENTS" --argjson read_agents "$READ_AGENTS" --argjson min_sessions "$MIN_SESSIONS" --argjson threshold "$WRITE_AGENT_THRESHOLD" '
  group_by(.agent) | map(
    . as $entries |
    $entries[0].agent as $agent_name |
    {
      agent: $agent_name,
      sessions_analyzed: ($entries | length),
      avg_efficiency_ratio: ([$entries[].metrics.efficiency_ratio] | add / length | . * 100 | round / 100),
      avg_total_calls: ([$entries[].metrics.total_tool_calls] | add / length | round),
      trend: (
        if ($entries | length) < 2 then "insufficient_data"
        elif ([$entries | sort_by(.session) | .[-2:][].metrics.efficiency_ratio] | .[1] > .[0]) then "improving"
        elif ([$entries | sort_by(.session) | .[-2:][].metrics.efficiency_ratio] | .[1] < .[0]) then "declining"
        else "stable"
        end
      ),
      flags: (
        [
          # repeated_reads pattern
          if ([$entries[].metrics.repeated_reads | select(. > 2)] | length) >= $min_sessions
          then "repeated_reads" else empty end,

          # excessive_exploration (write agents only)
          if ($write_agents | index($agent_name)) != null
            and ([$entries[].metrics.efficiency_ratio | select(. < $threshold)] | length) >= $min_sessions
          then "excessive_exploration" else empty end,

          # high_failure_rate
          if ([$entries[] | select((.metrics.failed_calls / (if .metrics.total_tool_calls == 0 then 1 else .metrics.total_tool_calls end)) > 0.15)] | length) >= $min_sessions
          then "high_failure_rate" else empty end,

          # tool_concentration (any single tool > 60%)
          if ([$entries[] | .metrics.tools_used | to_entries | max_by(.value) |
            select(.value > ([$entries[0].metrics.total_tool_calls] | .[0] * 0.6))] | length) >= $min_sessions
          then "tool_concentration" else empty end
        ]
      )
    }
  ) as $agent_summaries |

  # Build inefficiency patterns from flagged agents
  [$agent_summaries[] | select(.flags | length > 0) | .agent as $a | .flags[] |
    {
      agent: $a,
      pattern: .,
      description: (
        if . == "repeated_reads" then "\($a) reads the same file 3+ times in \($agent_summaries[] | select(.agent == $a) | .sessions_analyzed) sessions"
        elif . == "excessive_exploration" then "\($a) has efficiency ratio below \($threshold) in multiple sessions (avg: \($agent_summaries[] | select(.agent == $a) | .avg_efficiency_ratio))"
        elif . == "high_failure_rate" then "\($a) has >15% tool call failure rate across multiple sessions"
        elif . == "tool_concentration" then "\($a) concentrates >60% of calls on a single tool type"
        else "Unknown pattern"
        end
      ),
      sessions_detected: ($agent_summaries[] | select(.agent == $a) | .sessions_analyzed)
    }
  ] as $patterns |

  {
    schema_version: "1.0.0",
    agents: $agent_summaries,
    inefficiency_patterns: $patterns
  }
')

echo "$RESULT" | jq '.'
exit 0
