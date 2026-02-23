#!/usr/bin/env bash
# scripts/statusline.sh
# Status line script: renders a single-line status bar for Claude Code.
# Reads session JSON from stdin, reads .vibeos/ state files from disk.
# Outputs ANSI-colored status line to stdout.
# Exit 0 always (never break the status bar).

# --- Bail gracefully if jq is missing ---
if ! command -v jq &>/dev/null; then
  printf 'VibeOS'
  exit 0
fi

# --- Read stdin JSON (Claude Code provides session data) ---
INPUT="$(cat 2>/dev/null || echo '{}')"
if [[ -z "$INPUT" || "$INPUT" == "" ]]; then
  INPUT='{}'
fi

# --- ANSI color helpers (printf-safe, portable) ---
C_RESET='\033[0m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_RED='\033[31m'
C_DIM='\033[2m'
C_BOLD='\033[1m'

# --- Parse stdin fields ---
MODEL="$(echo "$INPUT" | jq -r '.model.display_name // empty' 2>/dev/null || echo '')"
CONTEXT_PCT="$(echo "$INPUT" | jq -r '.context_window.used_percentage // empty' 2>/dev/null || echo '')"
COST_USD="$(echo "$INPUT" | jq -r '.cost.total_cost_usd // empty' 2>/dev/null || echo '')"
DURATION_MS="$(echo "$INPUT" | jq -r '.cost.total_duration_ms // empty' 2>/dev/null || echo '')"

# --- Defaults for stdin fields ---
if [[ -z "$MODEL" || "$MODEL" == "null" ]]; then
  MODEL="Claude"
fi

# --- Context bar ---
if [[ -n "$CONTEXT_PCT" && "$CONTEXT_PCT" != "null" ]]; then
  # Truncate to integer
  CTX_INT="${CONTEXT_PCT%.*}"
  # Clamp 0-100
  if [[ "$CTX_INT" -lt 0 ]] 2>/dev/null; then CTX_INT=0; fi
  if [[ "$CTX_INT" -gt 100 ]] 2>/dev/null; then CTX_INT=100; fi

  # Color based on thresholds
  if [[ "$CTX_INT" -le 45 ]]; then
    CTX_COLOR="$C_GREEN"
  elif [[ "$CTX_INT" -le 55 ]]; then
    CTX_COLOR="$C_YELLOW"
  else
    CTX_COLOR="$C_RED"
  fi

  # Build 10-char progress bar (each block = 10%)
  FILLED=$(( CTX_INT / 10 ))
  EMPTY=$(( 10 - FILLED ))
  BAR=""
  for (( i=0; i<FILLED; i++ )); do BAR="${BAR}▓"; done
  for (( i=0; i<EMPTY; i++ )); do BAR="${BAR}░"; done

  CTX_SEGMENT="${CTX_COLOR}${BAR} ${CTX_INT}%${C_RESET}"
else
  CTX_SEGMENT="${C_DIM}---%${C_RESET}"
fi

# --- Cost ---
if [[ -n "$COST_USD" && "$COST_USD" != "null" ]]; then
  COST_FMT="$(printf '$%.2f' "$COST_USD" 2>/dev/null || echo '$?.??')"
else
  COST_FMT='$-.--'
fi

# --- Duration ---
if [[ -n "$DURATION_MS" && "$DURATION_MS" != "null" ]]; then
  # Convert ms to minutes (integer)
  DURATION_INT="${DURATION_MS%.*}"
  DURATION_MIN=$(( DURATION_INT / 60000 ))
  if [[ "$DURATION_MIN" -lt 1 ]]; then
    DUR_SEGMENT="<1m"
  else
    DUR_SEGMENT="${DURATION_MIN}m"
  fi
else
  DUR_SEGMENT="--m"
fi

# --- Disk reads: .vibeos/ state files ---
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBEOS_DIR="$PROJECT_ROOT/.vibeos"

# Feature + phase from state.json
FEATURE=""
PHASE=""
if [[ -f "$VIBEOS_DIR/state.json" ]]; then
  STATE_JSON="$(jq -r '.' "$VIBEOS_DIR/state.json" 2>/dev/null || echo '{}')"
  FEATURE="$(echo "$STATE_JSON" | jq -r '.active_feature.name // empty' 2>/dev/null || echo '')"
  PHASE="$(echo "$STATE_JSON" | jq -r '.active_feature.phase // empty' 2>/dev/null || echo '')"
  FOUNDATION="$(echo "$STATE_JSON" | jq -r '.foundation.complete // false' 2>/dev/null || echo 'false')"

  # If no active feature but foundation incomplete, show foundation status
  if [[ -z "$FEATURE" || "$FEATURE" == "null" ]]; then
    if [[ "$FOUNDATION" != "true" ]]; then
      FEATURE="foundation"
      PHASE="tier-1"
    fi
  fi
fi

# Truncate feature name to 16 chars
if [[ -n "$FEATURE" && "$FEATURE" != "null" && ${#FEATURE} -gt 16 ]]; then
  FEATURE="${FEATURE:0:15}…"
fi

# Capitalize phase (tr for Bash 3.2 compat instead of ${var^})
if [[ -n "$PHASE" && "$PHASE" != "null" ]]; then
  PHASE="$(echo "$PHASE" | tr '[:lower:]' '[:upper:]' | cut -c1)$(echo "$PHASE" | cut -c2-)"
fi

# Build feature segment
if [[ -n "$FEATURE" && "$FEATURE" != "null" ]]; then
  if [[ -n "$PHASE" && "$PHASE" != "null" ]]; then
    FEAT_SEGMENT="${FEATURE} · ${PHASE}"
  else
    FEAT_SEGMENT="${FEATURE}"
  fi
else
  FEAT_SEGMENT="${C_DIM}no project${C_RESET}"
fi

# Vibe Score from latest score file
SCORE=""
TREND=""
LATEST_SCORE="$(ls -t "$VIBEOS_DIR/scores"/score-*.json 2>/dev/null | head -1 || echo '')"
if [[ -n "$LATEST_SCORE" && -f "$LATEST_SCORE" ]]; then
  SCORE="$(jq -r '.score // empty' "$LATEST_SCORE" 2>/dev/null || echo '')"
  TREND_DIR="$(jq -r '.trend.direction // empty' "$LATEST_SCORE" 2>/dev/null || echo '')"
  case "$TREND_DIR" in
    improving) TREND="+" ;;
    declining) TREND="-" ;;
    *)         TREND="" ;;
  esac
fi

if [[ -n "$SCORE" && "$SCORE" != "null" ]]; then
  SCORE_SEGMENT="↑${SCORE}"
  if [[ -n "$TREND" ]]; then
    SCORE_SEGMENT="${SCORE_SEGMENT}${TREND}"
  fi
else
  SCORE_SEGMENT="↑--"
fi

# Compaction count from latest session file
COMPACTIONS="0"
LATEST_SESSION="$(ls -t "$VIBEOS_DIR/sessions"/session-*.json 2>/dev/null | head -1 || echo '')"
if [[ -n "$LATEST_SESSION" && -f "$LATEST_SESSION" ]]; then
  COMPACTIONS="$(jq -r '.context.compactions // 0' "$LATEST_SESSION" 2>/dev/null || echo '0')"
fi
if [[ -z "$COMPACTIONS" || "$COMPACTIONS" == "null" ]]; then
  COMPACTIONS="0"
fi

# --- Assemble status line ---
# Format: Model BAR PCT% | $COST | feature · Phase | ↑SCORE | DURm | ⟳N
printf '%s %b | %s | %b | %s | %s | ⟳%s' \
  "$MODEL" \
  "$CTX_SEGMENT" \
  "$COST_FMT" \
  "$FEAT_SEGMENT" \
  "$SCORE_SEGMENT" \
  "$DUR_SEGMENT" \
  "$COMPACTIONS"

exit 0
