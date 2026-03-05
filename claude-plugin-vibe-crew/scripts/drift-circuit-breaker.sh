#!/usr/bin/env bash
# scripts/drift-circuit-breaker.sh
# Stop hook: checks hard threshold, forces WIP commit + signal + escalation.
# Runs at the end of each agent turn (Stop event).
# Exit 0 always (fail open — never block agent from stopping).
# Output: Escalation messages to stdout when hard threshold crossed.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"
CONFIG_FILE="$VIBECREW_DIR/config.json"
TRACKER_FILE="$VIBECREW_DIR/drift-tracker.json"
STATE_FILE="$VIBECREW_DIR/state.json"

# --- Early exit checks ---
[[ -d "$VIBECREW_DIR" ]] || exit 0
[[ -f "$TRACKER_FILE" ]] || exit 0

# Check if drift detection is enabled
if [[ -f "$CONFIG_FILE" ]]; then
  ENABLED=$(jq -r 'if .drift_detection.enabled == false then "false" else "true" end' "$CONFIG_FILE" 2>/dev/null || echo "true")
  [[ "$ENABLED" == "false" ]] && exit 0
fi

# Skip during foundation (Tier 1)
if [[ -f "$STATE_FILE" ]]; then
  FOUNDATION_COMPLETE=$(jq -r '.foundation.complete // false' "$STATE_FILE" 2>/dev/null || echo "false")
  [[ "$FOUNDATION_COMPLETE" != "true" ]] && exit 0
fi

# --- Read tracker ---
TRACKER=$(cat "$TRACKER_FILE" 2>/dev/null || echo "")
[[ -z "$TRACKER" ]] && exit 0

SINCE_PROGRESS=$(echo "$TRACKER" | jq -r '.calls_since_progress // 0' 2>/dev/null || echo "0")
CURRENT_PHASE=$(echo "$TRACKER" | jq -r '.current_phase // ""' 2>/dev/null || echo "")
HARD_COUNT=$(echo "$TRACKER" | jq -r '.escalations.hard_count // 0' 2>/dev/null || echo "0")

# No phase info — skip
[[ -z "$CURRENT_PHASE" ]] && exit 0

# Skip review phase
[[ "$CURRENT_PHASE" == "review" ]] && exit 0

# --- Get hard threshold ---
HARD_THRESHOLD=""
if [[ -f "$CONFIG_FILE" ]]; then
  HARD_THRESHOLD=$(jq -r --arg p "$CURRENT_PHASE" '.drift_detection.thresholds[$p].hard // empty' "$CONFIG_FILE" 2>/dev/null || echo "")
fi

# Apply default thresholds if not in config
if [[ -z "$HARD_THRESHOLD" || "$HARD_THRESHOLD" == "null" ]]; then
  case "$CURRENT_PHASE" in
    plan)   HARD_THRESHOLD=60 ;;
    design) HARD_THRESHOLD=50 ;;
    code)   HARD_THRESHOLD=35 ;;
    test)   HARD_THRESHOLD=40 ;;
    docs)   HARD_THRESHOLD=40 ;;
    *)      HARD_THRESHOLD=40 ;;
  esac
fi

# --- Check hard threshold ---
if [[ "$SINCE_PROGRESS" -lt "$HARD_THRESHOLD" ]]; then
  exit 0
fi

# Already escalated for this crossing — don't spam
LAST_ESCALATED_COUNT=$(echo "$TRACKER" | jq -r '.escalations.last_escalated_count // 0' 2>/dev/null || echo "0")
if [[ "$LAST_ESCALATED_COUNT" -ge "$HARD_THRESHOLD" && "$SINCE_PROGRESS" -lt $((HARD_THRESHOLD * 2)) ]]; then
  exit 0
fi

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# --- Escalation: WIP commit ---
FEATURE_ID=$(echo "$TRACKER" | jq -r '.current_feature_id // ""' 2>/dev/null || echo "")

# Attempt WIP commit if there are changes
HAS_CHANGES=$(git -C "$PROJECT_ROOT" status --porcelain 2>/dev/null | head -1 || true)
if [[ -n "$HAS_CHANGES" ]]; then
  (cd "$PROJECT_ROOT" && git add -A && git commit -m "wip: drift circuit breaker — saving progress

Feature: ${FEATURE_ID:-unknown}
Phase: $CURRENT_PHASE
Calls since progress: $SINCE_PROGRESS" 2>/dev/null) || true
fi

# --- Write blocked signal ---
SIGNALS_DIR="$VIBECREW_DIR/signals"
mkdir -p "$SIGNALS_DIR"
cat > "$SIGNALS_DIR/builder-blocked.signal" <<EOF
{
  "feature_id": "${FEATURE_ID:-unknown}",
  "phase": "$CURRENT_PHASE",
  "timestamp": "$TIMESTAMP",
  "agent": "drift-circuit-breaker",
  "status": "blocked",
  "error": "Agent drift detected: $SINCE_PROGRESS exploration calls without code progress (hard limit: $HARD_THRESHOLD for $CURRENT_PHASE phase)",
  "drift_data": {
    "calls_since_progress": $SINCE_PROGRESS,
    "hard_threshold": $HARD_THRESHOLD,
    "escalation_count": $((HARD_COUNT + 1))
  }
}
EOF

# --- Update tracker with escalation ---
HARD_COUNT=$((HARD_COUNT + 1))
TRACKER=$(echo "$TRACKER" | jq \
  --argjson hc "$HARD_COUNT" \
  --arg ts "$TIMESTAMP" \
  --argjson lec "$SINCE_PROGRESS" \
  '.escalations.hard_count = $hc |
   .escalations.last_escalated_at = $ts |
   .escalations.last_escalated_count = $lec')
echo "$TRACKER" | jq -c '.' > "$TRACKER_FILE" 2>/dev/null || true

# --- Output escalation message ---
echo "DRIFT CIRCUIT BREAKER: $SINCE_PROGRESS tool calls without code progress in '$CURRENT_PHASE' phase (hard limit: $HARD_THRESHOLD)."
echo "  WIP commit created. Builder blocked signal written."
echo "  Consider: (1) changing approach, (2) producing a code artifact, or (3) asking the user for guidance."

exit 0
