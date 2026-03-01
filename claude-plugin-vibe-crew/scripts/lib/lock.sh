#!/usr/bin/env bash
# scripts/lib/lock.sh
# Unified advisory locking for all scripts that write state.json and/or backlog.json.
# Uses a single lock path (locks/state-files) to prevent race conditions
# between scripts that previously used separate locks.
#
# Usage:
#   source "$(dirname "$0")/lib/lock.sh"
#   acquire_state_lock "caller-name"   # blocks until acquired or timeout
#   # ... critical section ...
#   release_state_lock
#
# Behavior:
#   - mkdir-based advisory lock (atomic on all filesystems)
#   - 30-second stale lock detection
#   - 30-second wait timeout, 0.5s polling
#   - Trap-based cleanup on EXIT
#   - Caller sets LOCK_FAIL_OPEN=true before sourcing for fail-open behavior

# Resolve project root and lock path
_LOCK_PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
_LOCK_VIBECREW_DIR="$_LOCK_PROJECT_ROOT/.vibecrew"
_LOCK_DIR="$_LOCK_VIBECREW_DIR/locks/state-files"
_LOCK_ACQUIRED=false

# --- Cross-platform timestamp parsing ---
_lock_parse_timestamp() {
  local ts="$1"
  if date -j -f "%Y-%m-%dT%H:%M:%SZ" "$ts" "+%s" &>/dev/null; then
    date -j -f "%Y-%m-%dT%H:%M:%SZ" "$ts" "+%s" 2>/dev/null || echo "0"
  else
    date -d "$ts" "+%s" 2>/dev/null || echo "0"
  fi
}

# --- Cleanup on exit ---
_lock_cleanup() {
  if [[ "$_LOCK_ACQUIRED" == "true" ]]; then
    rm -rf "$_LOCK_DIR"
  fi
}

trap _lock_cleanup EXIT

# --- Check if existing lock is stale (>30s old) ---
_lock_is_stale() {
  local lock_info="$_LOCK_DIR/info.json"
  if [[ ! -f "$lock_info" ]]; then
    return 0  # No info file means stale
  fi
  local locked_at
  locked_at=$(jq -r '.locked_at // empty' "$lock_info" 2>/dev/null || echo "")
  if [[ -z "$locked_at" ]]; then
    return 0
  fi
  local lock_epoch now_epoch
  lock_epoch=$(_lock_parse_timestamp "$locked_at")
  now_epoch=$(date "+%s")
  local age=$(( now_epoch - lock_epoch ))
  [[ "$age" -gt 30 ]]
}

# --- Write lock info file ---
_lock_write_info() {
  local caller="$1"
  local ts
  ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  cat > "$_LOCK_DIR/info.json" <<EOF
{
  "locked_by": "$caller",
  "pid": $$,
  "locked_at": "$ts",
  "target_files": "state.json,backlog.json",
  "timeout_seconds": 30
}
EOF
}

# --- Public API ---

acquire_state_lock() {
  local caller="${1:-unknown}"
  mkdir -p "$_LOCK_VIBECREW_DIR/locks"

  # Try to acquire immediately
  if mkdir "$_LOCK_DIR" 2>/dev/null; then
    _LOCK_ACQUIRED=true
    _lock_write_info "$caller"
    return 0
  fi

  # Lock exists -- check if stale
  if _lock_is_stale; then
    rm -rf "$_LOCK_DIR"
    if mkdir "$_LOCK_DIR" 2>/dev/null; then
      _LOCK_ACQUIRED=true
      _lock_write_info "$caller"
      return 0
    fi
  fi

  # Wait up to 30 seconds, polling every 0.5s
  local attempts=0
  while [[ "$attempts" -lt 60 ]]; do
    sleep 0.5
    if mkdir "$_LOCK_DIR" 2>/dev/null; then
      _LOCK_ACQUIRED=true
      _lock_write_info "$caller"
      return 0
    fi
    # Check for stale lock while waiting
    if _lock_is_stale; then
      rm -rf "$_LOCK_DIR"
    fi
    ((attempts++))
  done

  # Timeout
  if [[ "${LOCK_FAIL_OPEN:-false}" == "true" ]]; then
    echo "WARNING: Could not acquire state lock after 30 seconds, proceeding without lock" >&2
    return 1
  else
    echo "ERROR: Could not acquire state lock after 30 seconds." >&2
    exit 1
  fi
}

release_state_lock() {
  rm -rf "$_LOCK_DIR"
  _LOCK_ACQUIRED=false
}
