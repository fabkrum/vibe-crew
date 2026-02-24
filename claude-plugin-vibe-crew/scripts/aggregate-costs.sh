#!/usr/bin/env bash
# scripts/aggregate-costs.sh
# Scans .vibecrew/sessions/session-*.json and .vibecrew/session-cost.json to compute
# daily, weekly, monthly, and all-time cost aggregates. Outputs JSON to stdout.
# Exit 0 always (fail open — aggregation failures should not block the session)

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"
SESSIONS_DIR="$VIBECREW_DIR/sessions"
COST_FILE="$VIBECREW_DIR/session-cost.json"

# ── Helper: floating point math with awk ──
calc() {
  awk "BEGIN {printf \"%.6f\", $1}"
}

fmt_usd() {
  awk "BEGIN {printf \"%.2f\", $1}"
}

# ── Date boundaries ──
TODAY="$(date +%Y-%m-%d)"

# Week start (Monday). macOS date vs GNU date handled separately.
if date --version >/dev/null 2>&1; then
  # GNU date
  WEEK_START="$(date -d "last monday" +%Y-%m-%d 2>/dev/null || echo "$TODAY")"
  MONTH_START="$(date +%Y-%m-01)"
else
  # macOS date
  DOW="$(date +%u)"  # 1=Monday, 7=Sunday
  DAYS_SINCE_MONDAY="$(( DOW - 1 ))"
  WEEK_START="$(date -v-"${DAYS_SINCE_MONDAY}"d +%Y-%m-%d 2>/dev/null || echo "$TODAY")"
  MONTH_START="$(date +%Y-%m-01)"
fi

# ── Read live session cost ──
LIVE_SESSION_COST="0"
if [[ -f "$COST_FILE" ]]; then
  LIVE_SESSION_COST="$(jq -r '.session_cost_usd // 0' "$COST_FILE" 2>/dev/null || echo 0)"
fi

# ── Scan completed session files ──
DAILY_COST="0"
WEEKLY_COST="0"
MONTHLY_COST="0"
ALL_TIME_COST="0"
SESSION_COUNT_TODAY="0"
SESSION_COUNT_TOTAL="0"

if [[ -d "$SESSIONS_DIR" ]]; then
  for session_file in "$SESSIONS_DIR"/session-*.json; do
    [[ -f "$session_file" ]] || continue

    SESSION_COUNT_TOTAL="$(( SESSION_COUNT_TOTAL + 1 ))"

    # Extract cost and date from session file
    FILE_COST="$(jq -r '.tokens.estimated_cost_usd // 0' "$session_file" 2>/dev/null || echo 0)"
    FILE_DATE="$(jq -r '.started_at // "" | split("T")[0] // ""' "$session_file" 2>/dev/null || echo "")"

    # If no started_at field, try to extract date from filename (session-YYYY-MM-DD*.json)
    if [[ -z "$FILE_DATE" ]]; then
      BASENAME="$(basename "$session_file")"
      FILE_DATE="$(echo "$BASENAME" | sed -n 's/^session-\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\).*/\1/p')"
    fi

    # All-time total
    ALL_TIME_COST="$(calc "$ALL_TIME_COST + $FILE_COST")"

    # Skip date-based buckets if we couldn't determine the date
    [[ -z "$FILE_DATE" ]] && continue

    # Daily
    if [[ "$FILE_DATE" == "$TODAY" ]]; then
      DAILY_COST="$(calc "$DAILY_COST + $FILE_COST")"
      SESSION_COUNT_TODAY="$(( SESSION_COUNT_TODAY + 1 ))"
    fi

    # Weekly (file date >= week start)
    if [[ "$FILE_DATE" > "$WEEK_START" || "$FILE_DATE" == "$WEEK_START" ]]; then
      WEEKLY_COST="$(calc "$WEEKLY_COST + $FILE_COST")"
    fi

    # Monthly (file date >= month start)
    if [[ "$FILE_DATE" > "$MONTH_START" || "$FILE_DATE" == "$MONTH_START" ]]; then
      MONTHLY_COST="$(calc "$MONTHLY_COST + $FILE_COST")"
    fi
  done
fi

# ── Add live session cost to each bucket ──
DAILY_COST="$(calc "$DAILY_COST + $LIVE_SESSION_COST")"
WEEKLY_COST="$(calc "$WEEKLY_COST + $LIVE_SESSION_COST")"
MONTHLY_COST="$(calc "$MONTHLY_COST + $LIVE_SESSION_COST")"
ALL_TIME_COST="$(calc "$ALL_TIME_COST + $LIVE_SESSION_COST")"

# ── Format for output ──
COMPUTED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

jq -n \
  --argjson live "$(fmt_usd "$LIVE_SESSION_COST")" \
  --argjson daily "$(fmt_usd "$DAILY_COST")" \
  --argjson weekly "$(fmt_usd "$WEEKLY_COST")" \
  --argjson monthly "$(fmt_usd "$MONTHLY_COST")" \
  --argjson alltime "$(fmt_usd "$ALL_TIME_COST")" \
  --argjson count_today "$SESSION_COUNT_TODAY" \
  --argjson count_total "$SESSION_COUNT_TOTAL" \
  --arg computed "$COMPUTED_AT" \
  '{
    live_session_cost_usd: $live,
    daily_cost_usd: $daily,
    weekly_cost_usd: $weekly,
    monthly_cost_usd: $monthly,
    all_time_cost_usd: $alltime,
    session_count_today: $count_today,
    session_count_total: $count_total,
    computed_at: $computed
  }'

exit 0
