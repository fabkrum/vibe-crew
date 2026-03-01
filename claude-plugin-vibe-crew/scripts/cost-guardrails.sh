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

# ── Helper: floating point math with awk (safe -v passing) ──
calc() {
  awk -v a="$1" -v b="${2:-0}" 'BEGIN {printf "%.6f", a + b}'
}

fmt_usd() {
  awk -v val="$1" 'BEGIN {printf "%.2f", val}'
}

# ── Read hook payload from stdin ──
PAYLOAD="$(cat)"
if [[ -z "$PAYLOAD" ]]; then
  exit 0
fi

# ── Extract model name from payload ──
MODEL="$(echo "$PAYLOAD" | jq -r '.model // "unknown"' 2>/dev/null || echo "unknown")"

# ── Pricing (per million tokens, model-specific) ──

# ── Read custom pricing from config (with hardcoded fallbacks) ──
CUSTOM_PRICING=""
if [[ -f "$CONFIG_FILE" ]]; then
  CUSTOM_PRICING="$(jq -r '.pricing // empty' "$CONFIG_FILE" 2>/dev/null || echo "")"
fi

case "$MODEL" in
  *opus*)
    PRICE_INPUT="$(echo "$CUSTOM_PRICING" | jq -r '.opus.input // 15.00' 2>/dev/null || echo "15.00")"
    PRICE_CACHE_CREATE="$(echo "$CUSTOM_PRICING" | jq -r '.opus.cache_create // 18.75' 2>/dev/null || echo "18.75")"
    PRICE_CACHE_READ="$(echo "$CUSTOM_PRICING" | jq -r '.opus.cache_read // 1.50' 2>/dev/null || echo "1.50")"
    PRICE_OUTPUT="$(echo "$CUSTOM_PRICING" | jq -r '.opus.output // 75.00' 2>/dev/null || echo "75.00")"
    ;;
  *sonnet*)
    PRICE_INPUT="$(echo "$CUSTOM_PRICING" | jq -r '.sonnet.input // 3.00' 2>/dev/null || echo "3.00")"
    PRICE_CACHE_CREATE="$(echo "$CUSTOM_PRICING" | jq -r '.sonnet.cache_create // 3.75' 2>/dev/null || echo "3.75")"
    PRICE_CACHE_READ="$(echo "$CUSTOM_PRICING" | jq -r '.sonnet.cache_read // 0.30' 2>/dev/null || echo "0.30")"
    PRICE_OUTPUT="$(echo "$CUSTOM_PRICING" | jq -r '.sonnet.output // 15.00' 2>/dev/null || echo "15.00")"
    ;;
  *haiku*)
    PRICE_INPUT="$(echo "$CUSTOM_PRICING" | jq -r '.haiku.input // 0.25' 2>/dev/null || echo "0.25")"
    PRICE_CACHE_CREATE="$(echo "$CUSTOM_PRICING" | jq -r '.haiku.cache_create // 0.30' 2>/dev/null || echo "0.30")"
    PRICE_CACHE_READ="$(echo "$CUSTOM_PRICING" | jq -r '.haiku.cache_read // 0.03' 2>/dev/null || echo "0.03")"
    PRICE_OUTPUT="$(echo "$CUSTOM_PRICING" | jq -r '.haiku.output // 1.25' 2>/dev/null || echo "1.25")"
    ;;
  *)
    PRICE_INPUT="$(echo "$CUSTOM_PRICING" | jq -r '.sonnet.input // 3.00' 2>/dev/null || echo "3.00")"
    PRICE_CACHE_CREATE="$(echo "$CUSTOM_PRICING" | jq -r '.sonnet.cache_create // 3.75' 2>/dev/null || echo "3.75")"
    PRICE_CACHE_READ="$(echo "$CUSTOM_PRICING" | jq -r '.sonnet.cache_read // 0.30' 2>/dev/null || echo "0.30")"
    PRICE_OUTPUT="$(echo "$CUSTOM_PRICING" | jq -r '.sonnet.output // 15.00' 2>/dev/null || echo "15.00")"
    ;;
esac

# ── Extract token counts from payload ──
INPUT_TOKENS="$(echo "$PAYLOAD" | jq -r '.usage.input_tokens // 0' 2>/dev/null || echo 0)"
CACHE_CREATE_TOKENS="$(echo "$PAYLOAD" | jq -r '.usage.cache_creation_input_tokens // 0' 2>/dev/null || echo 0)"
CACHE_READ_TOKENS="$(echo "$PAYLOAD" | jq -r '.usage.cache_read_input_tokens // 0' 2>/dev/null || echo 0)"
OUTPUT_TOKENS="$(echo "$PAYLOAD" | jq -r '.usage.output_tokens // 0' 2>/dev/null || echo 0)"

# ── Calculate turn cost ──
TURN_COST="$(awk -v it="$INPUT_TOKENS" -v pi="$PRICE_INPUT" -v cct="$CACHE_CREATE_TOKENS" -v pcc="$PRICE_CACHE_CREATE" -v crt="$CACHE_READ_TOKENS" -v pcr="$PRICE_CACHE_READ" -v ot="$OUTPUT_TOKENS" -v po="$PRICE_OUTPUT" 'BEGIN {printf "%.6f", (it*pi/1000000)+(cct*pcc/1000000)+(crt*pcr/1000000)+(ot*po/1000000)}')"

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
SESSION_COST="$(calc "$PREV_COST" "$TURN_COST")"
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
EXCEEDS_MAX="$(awk -v a="$SESSION_COST" -v b="$SESSION_MAX" 'BEGIN {print (a > b) ? 1 : 0}')"
if [[ "$EXCEEDS_MAX" == "1" ]]; then
  SESSION_MAX_FMT="$(fmt_usd "$SESSION_MAX")"
  echo "COST LIMIT: Session cost \$${SESSION_COST_FMT} exceeds hard limit (\$${SESSION_MAX_FMT}). Agent MUST pause and ask user for permission to continue."
else
  # Check warning threshold
  EXCEEDS_WARN="$(awk -v a="$SESSION_COST" -v b="$SESSION_WARN" 'BEGIN {print (a > b) ? 1 : 0}')"
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
      SESSIONS_TODAY_COST="$(calc "$SESSIONS_TODAY_COST" "$FILE_COST")"
    fi
  done
  DAILY_COST="$(calc "$SESSIONS_TODAY_COST" "$SESSION_COST")"
fi

EXCEEDS_DAILY="$(awk -v a="$DAILY_COST" -v b="$DAILY_WARN" 'BEGIN {print (a > b) ? 1 : 0}')"
if [[ "$EXCEEDS_DAILY" == "1" ]]; then
  DAILY_COST_FMT="$(fmt_usd "$DAILY_COST")"
  DAILY_WARN_FMT="$(fmt_usd "$DAILY_WARN")"
  echo "DAILY COST WARNING: Estimated daily spend \$${DAILY_COST_FMT} exceeds daily warning threshold (\$${DAILY_WARN_FMT})."
fi

exit 0
