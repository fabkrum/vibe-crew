#!/usr/bin/env bash
# scripts/ensure-dashboard.sh — Idempotent dashboard liveness checker
# Usage: bash scripts/ensure-dashboard.sh [--open]
# - Checks if dashboard is already running via .vibecrew/dashboard.pid
# - If alive + port listening: exits silently (hot path, <100ms)
# - If stale PID or no PID file: launches fresh via start-dashboard.sh
# - Accepts --open flag to open browser on first launch
# - Exits 0 always (fail-open, never blocks session startup)
# - Logs to .vibecrew/dashboard.log

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"
DOCS_DIR="$PROJECT_ROOT/docs"
PID_FILE="$VIBECREW_DIR/dashboard.pid"
LOG_FILE="$VIBECREW_DIR/dashboard.log"

OPEN_FLAG="--no-open"
if [[ "${1:-}" == "--open" ]]; then
  OPEN_FLAG=""
fi

# --- Pre-checks: bail silently if nothing to serve ---

# No .vibecrew/ dir → not initialized
if [[ ! -d "$VIBECREW_DIR" ]]; then
  exit 0
fi

# No docs site → nothing to serve
if [[ ! -f "$DOCS_DIR/package.json" ]]; then
  exit 0
fi

# --- Check if already running ---

if [[ -f "$PID_FILE" ]]; then
  DASH_PID=$(jq -r '.pid // empty' "$PID_FILE" 2>/dev/null || echo "")
  DASH_PORT=$(jq -r '.port // empty' "$PID_FILE" 2>/dev/null || echo "")

  if [[ -n "$DASH_PID" ]] && kill -0 "$DASH_PID" 2>/dev/null; then
    # Process alive — check if port is actually listening
    PORT_ALIVE=false
    if [[ -n "$DASH_PORT" ]]; then
      if command -v lsof &>/dev/null; then
        lsof -i :"$DASH_PORT" &>/dev/null && PORT_ALIVE=true
      elif command -v ss &>/dev/null; then
        ss -tlnp "sport = :$DASH_PORT" 2>/dev/null | grep -q ":$DASH_PORT" && PORT_ALIVE=true
      else
        # Can't check port — trust PID
        PORT_ALIVE=true
      fi
    fi

    if [[ "$PORT_ALIVE" == "true" ]]; then
      echo "Dashboard: http://localhost:$DASH_PORT"
      exit 0
    fi
  fi

  # Stale PID file — clean up
  rm -f "$PID_FILE" 2>/dev/null || true
fi

# --- Launch fresh ---

START_SCRIPT="$SCRIPT_DIR/start-dashboard.sh"
if [[ ! -x "$START_SCRIPT" ]]; then
  # Try without -x check (might not have execute bit)
  if [[ ! -f "$START_SCRIPT" ]]; then
    exit 0
  fi
fi

# Launch in background via nohup
if [[ -n "$OPEN_FLAG" ]]; then
  nohup bash "$START_SCRIPT" "$OPEN_FLAG" >> "$LOG_FILE" 2>&1 &
else
  nohup bash "$START_SCRIPT" >> "$LOG_FILE" 2>&1 &
fi

# Wait briefly for PID file to appear (max 5s)
for i in 1 2 3 4 5; do
  sleep 1
  if [[ -f "$PID_FILE" ]]; then
    DASH_PORT=$(jq -r '.port // 5173' "$PID_FILE" 2>/dev/null || echo "5173")
    echo "Dashboard: http://localhost:$DASH_PORT (launched)"
    exit 0
  fi
done

# PID file didn't appear — still exit clean
echo "Dashboard: starting in background (check $LOG_FILE)"
exit 0
