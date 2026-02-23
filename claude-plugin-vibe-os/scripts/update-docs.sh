#!/usr/bin/env bash
set -euo pipefail

# update-docs.sh — PostToolUse helper for VitePress documentation rebuilds
#
# Triggers a VitePress rebuild after documentation files are changed.
# Intended to be called from a PostToolUse hook (Write/Edit events).
# All output goes to stderr (stdout is reserved for hookSpecificOutput).
# Always exits 0 (fail open — this is not a safety script).
#
# Usage: update-docs.sh [changed-file-path]

CHANGED_FILE="${1:-}"

# --- Find project root by walking up from script location looking for .vibeos/ ---
find_project_root() {
  local dir
  dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  while [[ "$dir" != "/" ]]; do
    if [[ -d "$dir/.vibeos" ]]; then
      echo "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

PROJECT_ROOT="$(find_project_root)" || {
  # No .vibeos/ found — not inside a VibeOS project, nothing to do
  exit 0
}

DOCS_DIR="$PROJECT_ROOT/docs"

# --- Check if a VitePress docs site exists ---
if [[ ! -d "$DOCS_DIR/.vitepress" ]]; then
  # No docs site configured — exit silently
  exit 0
fi

# --- Check if VitePress dev server is running (port 3002) ---
dev_server_running() {
  if command -v lsof &>/dev/null; then
    lsof -iTCP:3002 -sTCP:LISTEN &>/dev/null
  elif command -v ss &>/dev/null; then
    ss -tlnp 2>/dev/null | grep -q ':3002 '
  else
    return 1
  fi
}

if dev_server_running; then
  echo "[update-docs] VitePress dev server detected on port 3002 — HMR handles rebuild automatically." >&2
  exit 0
fi

# --- Dev server not running — check for existing build output ---
if [[ -d "$DOCS_DIR/.vitepress/dist" ]]; then
  echo "[update-docs] Rebuilding VitePress static site in background..." >&2
  (cd "$PROJECT_ROOT" && npx vitepress build docs &>/dev/null &)
  exit 0
fi

# No build output exists — user hasn't built docs yet, nothing to do
exit 0
