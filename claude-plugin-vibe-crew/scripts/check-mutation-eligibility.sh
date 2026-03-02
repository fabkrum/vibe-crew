#!/usr/bin/env bash
# scripts/check-mutation-eligibility.sh
# Checks guardrails for Performance Coach mutation proposals.
# Usage: check-mutation-eligibility.sh [--pattern "category"]
# Outputs JSON: {"eligible": true/false, "reason": "...", "details": {...}}
# Exit 0 always.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SCORES_DIR="$PROJECT_ROOT/.vibecrew/scores"
MUTATION_LOG="$PROJECT_ROOT/.vibecrew/mutation-log.json"
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"
CONFIG_FILE="$PROJECT_ROOT/.vibecrew/config.json"

PATTERN=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --pattern) PATTERN="$2"; shift 2 ;;
    *) shift ;;
  esac
done

# --- Helper: output result and exit ---
result() {
  local eligible="$1"
  local reason="$2"
  jq -n --argjson e "$eligible" --arg r "$reason" \
    '{eligible: $e, reason: $r}'
  exit 0
}

# --- Guardrail 0: Master toggle ---
if [[ -f "$CONFIG_FILE" ]]; then
  ENABLED=$(jq -r 'if .performance_coach.enabled == false then "false" else "true" end' "$CONFIG_FILE" 2>/dev/null || echo "true")
  if [[ "$ENABLED" == "false" ]]; then
    result false "Performance Coach is disabled in config.json"
  fi
fi

# --- Guardrail 1: Cooldown check (early exit before expensive checks) ---
if [[ -n "$PATTERN" && -f "$MUTATION_LOG" ]]; then
  # Check rejection count and dynamic cooldown (cooldown_days = rejection_count * 7)
  REJECTION_DATA=$(jq --arg p "$PATTERN" '
    [.mutations // [] | .[] | select(.reasoning == $p and .status == "rejected")] |
    {
      rejection_count: length,
      cooldown_until: (map(.cooldown_until // empty) | last // null)
    }
  ' "$MUTATION_LOG" 2>/dev/null || echo '{"rejection_count":0,"cooldown_until":null}')

  REJECTION_COUNT=$(echo "$REJECTION_DATA" | jq -r '.rejection_count')
  COOLDOWN_UNTIL=$(echo "$REJECTION_DATA" | jq -r '.cooldown_until // empty')

  if [[ "$REJECTION_COUNT" -ge 3 ]]; then
    COOLDOWN_DAYS=$(( REJECTION_COUNT * 7 ))
    if [[ -n "$COOLDOWN_UNTIL" && "$COOLDOWN_UNTIL" != "null" ]]; then
      # Check if cooldown has expired
      NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
      if [[ "$NOW" < "$COOLDOWN_UNTIL" ]]; then
        result false "Pattern '$PATTERN' is in cooldown until $COOLDOWN_UNTIL (rejected $REJECTION_COUNT times, ${COOLDOWN_DAYS}-day cooldown)"
      fi
    else
      result false "Pattern '$PATTERN' has been rejected $REJECTION_COUNT times (${COOLDOWN_DAYS}-day cooldown required)"
    fi
  fi
fi

# --- Guardrail 2: Minimum 5 sessions ---
SCORE_COUNT=0
if [[ -d "$SCORES_DIR" ]]; then
  SCORE_COUNT=$(ls -1 "$SCORES_DIR"/score-*.json 2>/dev/null | wc -l | tr -d ' ' || true)
  SCORE_COUNT=${SCORE_COUNT:-0}
fi

if [[ "$SCORE_COUNT" -lt 5 ]]; then
  result false "Minimum 5 sessions required (have $SCORE_COUNT)"
fi

# --- Guardrail 3: Session limit (max 1 mutation per session) ---
# Check if a mutation was already proposed/applied in the current session
TODAY=$(date -u +%Y-%m-%d)
LATEST_SCORE=$(ls -1t "$SCORES_DIR"/score-*.json 2>/dev/null | head -1 || true)
CURRENT_SESSION_ID=""
if [[ -n "$LATEST_SCORE" && -f "$LATEST_SCORE" ]]; then
  CURRENT_SESSION_ID=$(jq -r '.session_id // ""' "$LATEST_SCORE" 2>/dev/null || echo "")
fi

if [[ -n "$CURRENT_SESSION_ID" && -f "$MUTATION_LOG" ]]; then
  SESSION_MUTATIONS=$(jq --arg sid "$CURRENT_SESSION_ID" \
    '[.mutations // [] | .[] | select(.session_id == $sid)] | length' \
    "$MUTATION_LOG" 2>/dev/null || echo "0")
  if [[ "$SESSION_MUTATIONS" -gt 0 ]]; then
    result false "Max 1 mutation per session (already proposed in $CURRENT_SESSION_ID)"
  fi
fi

# --- Guardrail 4: Frequency threshold (3+ in last 10 sessions) ---
if [[ -n "$PATTERN" ]]; then
  # Count how many of the last 10 sessions have this pattern
  PATTERN_COUNT=0
  SCORE_FILES=$(ls -1t "$SCORES_DIR"/score-*.json 2>/dev/null | head -10 || true)
  while IFS= read -r file; do
    [[ -z "$file" || ! -f "$file" ]] && continue
    HAS_PATTERN=$(jq --arg p "$PATTERN" \
      '[.deductions // [] | .[] | select(.category == $p)] | length' \
      "$file" 2>/dev/null || echo "0")
    if [[ "$HAS_PATTERN" -gt 0 ]]; then
      PATTERN_COUNT=$(( PATTERN_COUNT + 1 ))
    fi
  done <<< "$SCORE_FILES"

  if [[ "$PATTERN_COUNT" -lt 3 ]]; then
    result false "Pattern '$PATTERN' seen in $PATTERN_COUNT/10 sessions (need 3+)"
  fi
fi

# --- Guardrail 5: No duplicate rules in CLAUDE.md ---
# This check is done at proposal time by the agent, but we verify here too
if [[ -n "$PATTERN" && -f "$MUTATION_LOG" ]]; then
  # Check if an applied mutation for this pattern already exists
  APPLIED_COUNT=$(jq --arg p "$PATTERN" \
    '[.mutations // [] | .[] | select(.reasoning == $p and .status == "applied")] | length' \
    "$MUTATION_LOG" 2>/dev/null || echo "0")
  if [[ "$APPLIED_COUNT" -gt 0 ]]; then
    result false "A mutation for '$PATTERN' was already applied"
  fi
fi

# --- All guardrails passed ---
result true "All eligibility checks passed"
