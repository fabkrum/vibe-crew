#!/usr/bin/env bash
# scripts/drift-tracker.sh
# PostToolUse hook: classifies tool calls, updates drift counter, emits soft warnings.
# Fires for ALL tool calls (no matcher filter).
# Exit 0 always (never block tool execution).
# Output: Warning messages to stderr when soft threshold crossed.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"
CONFIG_FILE="$VIBECREW_DIR/config.json"
TRACKER_FILE="$VIBECREW_DIR/drift-tracker.json"
STATE_FILE="$VIBECREW_DIR/state.json"

# Source classification library
source "$SCRIPT_DIR/lib/drift-classify.sh"

# --- Early exit checks ---

# Not initialized
[[ -d "$VIBECREW_DIR" ]] || exit 0

# Check if drift detection is enabled
if [[ -f "$CONFIG_FILE" ]]; then
  ENABLED=$(jq -r 'if .drift_detection.enabled == false then "false" else "true" end' "$CONFIG_FILE" 2>/dev/null || echo "true")
  [[ "$ENABLED" == "false" ]] && exit 0
fi

# Skip during foundation (Tier 1) — research-heavy phases
if [[ -f "$STATE_FILE" ]]; then
  FOUNDATION_COMPLETE=$(jq -r '.foundation.complete // false' "$STATE_FILE" 2>/dev/null || echo "false")
  [[ "$FOUNDATION_COMPLETE" != "true" ]] && exit 0
fi

# --- Read hook input ---
# PostToolUse hook receives JSON on stdin with tool_name, file_path, etc.
HOOK_INPUT=""
if [[ ! -t 0 ]]; then
  HOOK_INPUT=$(cat 2>/dev/null || echo "")
fi

TOOL_NAME=""
FILE_PATH=""
EXIT_CODE="0"

if [[ -n "$HOOK_INPUT" ]]; then
  TOOL_NAME=$(echo "$HOOK_INPUT" | jq -r '.tool_name // empty' 2>/dev/null || echo "")
  FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.file_path // .tool_input.file_path // .tool_input.command // empty' 2>/dev/null || echo "")
  EXIT_CODE=$(echo "$HOOK_INPUT" | jq -r '.exit_code // "0"' 2>/dev/null || echo "0")
fi

# No tool info — skip
[[ -z "$TOOL_NAME" ]] && exit 0

# --- Get current phase ---
CURRENT_PHASE=""
if [[ -f "$STATE_FILE" ]]; then
  CURRENT_PHASE=$(jq -r '.active_feature.phase // empty' "$STATE_FILE" 2>/dev/null || echo "")
fi

# Skip review phase (read-only agent by design)
[[ "$CURRENT_PHASE" == "review" ]] && exit 0

# No active feature phase — skip
[[ -z "$CURRENT_PHASE" ]] && exit 0

# --- Classify tool call ---
CLASSIFICATION=$(classify_tool_call "$TOOL_NAME" "$FILE_PATH" "$EXIT_CODE")

# --- Read or initialize tracker ---
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

if [[ -f "$TRACKER_FILE" ]]; then
  TRACKER=$(cat "$TRACKER_FILE" 2>/dev/null || echo "")
else
  TRACKER=""
fi

if [[ -z "$TRACKER" ]] || ! echo "$TRACKER" | jq -e '.schema_version' &>/dev/null; then
  # Initialize tracker
  TRACKER=$(jq -n \
    --arg ts "$TIMESTAMP" \
    --arg phase "$CURRENT_PHASE" \
    --arg feat "$(jq -r '.active_feature.id // ""' "$STATE_FILE" 2>/dev/null || echo "")" \
    '{
      schema_version: "1.0.0",
      session_started_at: $ts,
      current_phase: $phase,
      current_feature_id: $feat,
      total_tool_calls: 0,
      calls_since_progress: 0,
      last_progress_at: null,
      last_progress_tool: null,
      progress_events: 0,
      exploration_events: 0,
      warnings: { soft_count: 0, last_warned_at: null },
      escalations: { hard_count: 0, last_escalated_at: null },
      recent_reads: [],
      repeated_read_count: 0
    }')
fi

# --- Update tracker ---
TOTAL=$(echo "$TRACKER" | jq -r '.total_tool_calls // 0')
SINCE_PROGRESS=$(echo "$TRACKER" | jq -r '.calls_since_progress // 0')
PROGRESS_EVENTS=$(echo "$TRACKER" | jq -r '.progress_events // 0')
EXPLORATION_EVENTS=$(echo "$TRACKER" | jq -r '.exploration_events // 0')
SOFT_COUNT=$(echo "$TRACKER" | jq -r '.warnings.soft_count // 0')

TOTAL=$((TOTAL + 1))

case "$CLASSIFICATION" in
  progress)
    SINCE_PROGRESS=0
    PROGRESS_EVENTS=$((PROGRESS_EVENTS + 1))
    TRACKER=$(echo "$TRACKER" | jq \
      --argjson total "$TOTAL" \
      --argjson since 0 \
      --argjson prog "$PROGRESS_EVENTS" \
      --arg ts "$TIMESTAMP" \
      --arg tool "$TOOL_NAME" \
      --arg phase "$CURRENT_PHASE" \
      '.total_tool_calls = $total |
       .calls_since_progress = $since |
       .progress_events = $prog |
       .last_progress_at = $ts |
       .last_progress_tool = $tool |
       .current_phase = $phase |
       .recent_reads = []')
    ;;
  exploration)
    SINCE_PROGRESS=$((SINCE_PROGRESS + 1))
    EXPLORATION_EVENTS=$((EXPLORATION_EVENTS + 1))

    # Track repeated reads
    RECENT_READS=$(echo "$TRACKER" | jq -c '.recent_reads // []')
    REPEATED_COUNT=$(echo "$TRACKER" | jq -r '.repeated_read_count // 0')
    if [[ "$TOOL_NAME" == "Read" && -n "$FILE_PATH" ]]; then
      IS_REPEAT=$(echo "$RECENT_READS" | jq --arg f "$FILE_PATH" 'index($f) != null')
      if [[ "$IS_REPEAT" == "true" ]]; then
        REPEATED_COUNT=$((REPEATED_COUNT + 1))
      fi
      RECENT_READS=$(echo "$RECENT_READS" | jq --arg f "$FILE_PATH" \
        'if length >= 10 then .[1:] + [$f] else . + [$f] end')
    fi

    TRACKER=$(echo "$TRACKER" | jq \
      --argjson total "$TOTAL" \
      --argjson since "$SINCE_PROGRESS" \
      --argjson expl "$EXPLORATION_EVENTS" \
      --argjson reads "$RECENT_READS" \
      --argjson rcount "$REPEATED_COUNT" \
      --arg phase "$CURRENT_PHASE" \
      '.total_tool_calls = $total |
       .calls_since_progress = $since |
       .exploration_events = $expl |
       .current_phase = $phase |
       .recent_reads = $reads |
       .repeated_read_count = $rcount')
    ;;
  neutral)
    SINCE_PROGRESS=$((SINCE_PROGRESS + 1))
    TRACKER=$(echo "$TRACKER" | jq \
      --argjson total "$TOTAL" \
      --argjson since "$SINCE_PROGRESS" \
      --arg phase "$CURRENT_PHASE" \
      '.total_tool_calls = $total |
       .calls_since_progress = $since |
       .current_phase = $phase')
    ;;
esac

# --- Check soft threshold ---
SOFT_THRESHOLD=""
if [[ -f "$CONFIG_FILE" ]]; then
  SOFT_THRESHOLD=$(jq -r --arg p "$CURRENT_PHASE" '.drift_detection.thresholds[$p].soft // empty' "$CONFIG_FILE" 2>/dev/null || echo "")
fi

# Apply default thresholds if not in config
if [[ -z "$SOFT_THRESHOLD" || "$SOFT_THRESHOLD" == "null" ]]; then
  case "$CURRENT_PHASE" in
    plan)   SOFT_THRESHOLD=40 ;;
    design) SOFT_THRESHOLD=30 ;;
    code)   SOFT_THRESHOLD=20 ;;
    test)   SOFT_THRESHOLD=25 ;;
    docs)   SOFT_THRESHOLD=25 ;;
    *)      SOFT_THRESHOLD=30 ;;
  esac
fi

if [[ "$SINCE_PROGRESS" -ge "$SOFT_THRESHOLD" ]]; then
  # Only warn once per crossing (not every call after)
  LAST_WARNED_COUNT=$(echo "$TRACKER" | jq -r '.warnings.last_warned_count // 0')
  if [[ "$SINCE_PROGRESS" -ge "$SOFT_THRESHOLD" && "$LAST_WARNED_COUNT" -lt "$SOFT_THRESHOLD" ]] || \
     [[ $((SINCE_PROGRESS % SOFT_THRESHOLD)) -eq 0 && "$SINCE_PROGRESS" -gt "$LAST_WARNED_COUNT" ]]; then
    SOFT_COUNT=$((SOFT_COUNT + 1))
    TRACKER=$(echo "$TRACKER" | jq \
      --argjson sc "$SOFT_COUNT" \
      --arg ts "$TIMESTAMP" \
      --argjson lwc "$SINCE_PROGRESS" \
      '.warnings.soft_count = $sc |
       .warnings.last_warned_at = $ts |
       .warnings.last_warned_count = $lwc')
    echo "DRIFT WARNING: $SINCE_PROGRESS tool calls without code progress in '$CURRENT_PHASE' phase (soft limit: $SOFT_THRESHOLD). Consider writing code or producing an artifact." >&2
  fi
fi

# --- Write tracker ---
echo "$TRACKER" | jq -c '.' > "$TRACKER_FILE" 2>/dev/null || true

exit 0
