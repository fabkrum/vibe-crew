#!/usr/bin/env bash
# scripts/start-dashboard.sh — One-command Vibe Dashboard launcher
# Usage: bash scripts/start-dashboard.sh [--no-open]
# - Smart install: skips npm install if node_modules exists and package.json unchanged
# - Port detection: finds first available port in 5173-5180 range
# - Auto-open browser: opens the URL after 3 seconds (disable with --no-open)
# - PID tracking: writes PID + port to .vibecrew/dashboard.pid for session startup checks

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/compat.sh"

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
DOCS_DIR="$PROJECT_ROOT/docs"
VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"

# Verify docs site exists
if [[ ! -f "$DOCS_DIR/package.json" ]]; then
  echo "ERROR: docs/ not found. Run /setup first." >&2
  exit 1
fi

# Install deps (skip if node_modules exists and package.json unchanged)
if [[ ! -d "$DOCS_DIR/node_modules" ]] || \
   [[ "$DOCS_DIR/package.json" -nt "$DOCS_DIR/node_modules/.package-lock.json" ]]; then
  echo "Installing dashboard dependencies..."
  (cd "$DOCS_DIR" && npm install --silent)
fi

# Find available port (default 5173, fallback to 5174-5180)
PORT=5173
for p in 5173 5174 5175 5176 5177 5178 5179 5180; do
  if command -v lsof &>/dev/null; then
    if ! lsof -i :"$p" &>/dev/null; then
      PORT=$p
      break
    fi
  elif command -v ss &>/dev/null; then
    if ! ss -tlnp "sport = :$p" 2>/dev/null | grep -q ":$p"; then
      PORT=$p
      break
    fi
  else
    # No port-check tool available — use default
    PORT=$p
    break
  fi
done

# Write PID file for session startup checks
cleanup() {
  rm -f "$VIBECREW_DIR/dashboard.pid" 2>/dev/null || true
}
trap cleanup TERM INT

if [[ -d "$VIBECREW_DIR" ]]; then
  mkdir -p "$VIBECREW_DIR"
  echo "{\"pid\": $$, \"port\": $PORT, \"started_at\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" \
    > "$VIBECREW_DIR/dashboard.pid"
fi

# Auto-open browser after short delay (unless --no-open)
if [[ "${1:-}" != "--no-open" ]]; then
  (sleep 3 && _compat_open_url "http://localhost:$PORT") &
fi

echo "Starting Vibe Dashboard at http://localhost:$PORT"
cd "$DOCS_DIR"
exec npx vitepress dev --port "$PORT"
