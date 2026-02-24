#!/usr/bin/env bash
# scripts/cost-guardrails.sh
# Stop hook helper: monitors session cost against config.json limits
# Reads token usage from stdin (hook payload JSON), calculates estimated cost,
# accumulates in session-cost.json, compares against thresholds, emits warnings.
# Exit 0 always (fail open)

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"
CONFIG_FILE="$VIBECREW_DIR/config.json"
COST_FILE="$VIBECREW_DIR/session-cost.json"
SESSIONS_DIR="$VIBECREW_DIR/sessions"

# ── Helper: floating point math with awk (bc fallback not needed) ──
calc() {
  awk "BEGIN {printf \"%.6f\", $1}"
}

fmt_usd() {
  awk "BEGIN {printf \"%.2f\", $1}"
}

# ── Read hook payload from stdin ──
PAYLOAD="$(cat)"
if [[ -z "$PAYLOAD" ]]; then
  exit 0
fi

# ── Extract model name from payload ──
MODEL="$(echo "$PAYLOAD" | jq -r '.model // "unknown"' 2>/dev/null || echo "unknown")"

# ── Pricing (per million tokens, model-specific) ──
case "$MODEL" in
  *opus*)
    PRICE_INPUT="15.00"
    PRICE_CACHE_CREATE="18.75"
    PRICE_CACHE_READ="1.50"
    PRICE_OUTPUT="75.00"
    ;;
  *sonnet*)
    PRICE_INPUT="3.00"
    PRICE_CACHE_CREATE="3.75"
    PRICE_CACHE_READ="0.30"
    PRICE_OUTPUT="15.00"
    ;;
  *haiku*)
    PRICE_INPUT="0.25"
    PRICE_CACHE_CREATE="0.30"
    PRICE_CACHE_READ="0.03"
    PRICE_OUTPUT="1.25"
    ;;
  *)
    # Default to Sonnet pricing for unknown models
    PRICE_INPUT="3.00"
    PRICE_CACHE_CREATE="3.75"
    PRICE_CACHE_READ="0.30"
    PRICE_OUTPUT="15.00"
    ;;
esac

# ── Extract token counts from payload ──
INPUT_TOKENS="$(echo "$PAYLOAD" | jq -r '.usage.input_tokens // 0' 2>/dev/null || echo 0)"
CACHE_CREATE_TOKENS="$(echo "$PAYLOAD" | jq -r '.usage.cache_creation_input_tokens // 0' 2>/dev/null || echo 0)"
CACHE_READ_TOKENS="$(echo "$PAYLOAD" | jq -r '.usage.cache_read_input_tokens // 0' 2>/dev/null || echo 0)"
OUTPUT_TOKENS="$(echo "$PAYLOAD" | jq -r '.usage.output_tokens // 0' 2>/dev/null || echo 0)"

# ── Calculate turn cost ──
TURN_COST="$(calc "($INPUT_TOKENS * $PRICE_INPUT / 1000000) + ($CACHE_CREATE_TOKENS * $PRICE_CACHE_CREATE / 1000000) + ($CACHE_READ_TOKENS * $PRICE_CACHE_READ / 1000000) + ($OUTPUT_TOKENS * $PRICE_OUTPUT / 1000000)")"

# ── Ensure .vibecrew directory exists ──
mkdir -p "$VIBECREW_DIR"

# ── Read or initialize session cost file ──
if [[ -f "$COST_FILE" ]]; then
  PREV_COST="$(jq -r '.session_cost_usd // 0' "$COST_FILE" 2>/dev/null || echo 0)"
  PREV_TURNS="$(jq -r '.turn_count // 0' "$COST_FILE" 2>/dev/null || echo 0)"
else
  PREV_COST="0"
  PREV_TURNS="0"
fi

# ── Accumulate ──
SESSION_COST="$(calc "$PREV_COST + $TURN_COST")"
TURN_COUNT="$(( PREV_TURNS + 1 ))"
LAST_UPDATED="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

# ── Write updated session cost file (temp-file-then-mv for atomicity) ──
COST_TMP="$(mktemp "${COST_FILE}.XXXXXX")"
jq -n \
  --argjson cost "$SESSION_COST" \
  --argjson turns "$TURN_COUNT" \
  --arg updated "$LAST_UPDATED" \
  --argjson turn_cost "$TURN_COST" \
  --arg model "$MODEL" \
  '{session_cost_usd: $cost, turn_count: $turns, last_turn_cost_usd: $turn_cost, model: $model, last_updated: $updated}' \
  > "$COST_TMP" 2>/dev/null && mv "$COST_TMP" "$COST_FILE" || { rm -f "$COST_TMP"; true; }

# ── Read thresholds from config.json ──
SESSION_WARN="2.00"
SESSION_MAX="5.00"
DAILY_WARN="20.00"

if [[ -f "$CONFIG_FILE" ]]; then
  SESSION_WARN="$(jq -r '.cost_limits.session_warn_usd // 2.00' "$CONFIG_FILE" 2>/dev/null || echo "2.00")"
  SESSION_MAX="$(jq -r '.cost_limits.session_max_usd // 5.00' "$CONFIG_FILE" 2>/dev/null || echo "5.00")"
  DAILY_WARN="$(jq -r '.cost_limits.daily_warn_usd // 20.00' "$CONFIG_FILE" 2>/dev/null || echo "20.00")"
fi

# ── Session cost checks ──
SESSION_COST_FMT="$(fmt_usd "$SESSION_COST")"

# Check hard limit first (most severe)
EXCEEDS_MAX="$(awk "BEGIN {print ($SESSION_COST > $SESSION_MAX) ? 1 : 0}")"
if [[ "$EXCEEDS_MAX" == "1" ]]; then
  SESSION_MAX_FMT="$(fmt_usd "$SESSION_MAX")"
  echo "COST LIMIT: Session cost \$${SESSION_COST_FMT} exceeds hard limit (\$${SESSION_MAX_FMT}). Agent MUST pause and ask user for permission to continue."
else
  # Check warning threshold
  EXCEEDS_WARN="$(awk "BEGIN {print ($SESSION_COST > $SESSION_WARN) ? 1 : 0}")"
  if [[ "$EXCEEDS_WARN" == "1" ]]; then
    SESSION_WARN_FMT="$(fmt_usd "$SESSION_WARN")"
    echo "COST WARNING: Session cost \$${SESSION_COST_FMT} exceeds warning threshold (\$${SESSION_WARN_FMT})."
  fi
fi

# ── Daily cost check ──
# Sum estimated_cost_usd from all session files for today
TODAY="$(date +%Y-%m-%d)"
DAILY_COST="$SESSION_COST"

if [[ -d "$SESSIONS_DIR" ]]; then
  # Find all session files matching today's date pattern
  SESSIONS_TODAY_COST="0"
  for session_file in "$SESSIONS_DIR"/session-"${TODAY}"*.json; do
    if [[ -f "$session_file" ]]; then
      FILE_COST="$(jq -r '.tokens.estimated_cost_usd // 0' "$session_file" 2>/dev/null || echo 0)"
      SESSIONS_TODAY_COST="$(calc "$SESSIONS_TODAY_COST + $FILE_COST")"
    fi
  done
  DAILY_COST="$(calc "$SESSIONS_TODAY_COST + $SESSION_COST")"
fi

EXCEEDS_DAILY="$(awk "BEGIN {print ($DAILY_COST > $DAILY_WARN) ? 1 : 0}")"
if [[ "$EXCEEDS_DAILY" == "1" ]]; then
  DAILY_COST_FMT="$(fmt_usd "$DAILY_COST")"
  DAILY_WARN_FMT="$(fmt_usd "$DAILY_WARN")"
  echo "DAILY COST WARNING: Estimated daily spend \$${DAILY_COST_FMT} exceeds daily warning threshold (\$${DAILY_WARN_FMT})."
fi

exit 0
