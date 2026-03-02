#!/usr/bin/env bash
# scripts/lib/lock.sh
# Unified advisory locking for all scripts that write state files.
# Supports named locks for independent resource groups (state-files, gamification, etc.).
#
# Usage:
#   source "$(dirname "$0")/lib/lock.sh"
#   acquire_state_lock "caller-name"               # state-files lock (legacy API)
#   acquire_named_lock "gamification" "caller-name" # named lock
#   # ... critical section ...
#   release_named_lock "gamification"
#   release_state_lock
#
# Behavior:
#   - mkdir-based advisory lock (atomic on all filesystems)
#   - Configurable stale lock detection (default 60s, via config.json)
#   - Configurable wait timeout (default 30s, via config.json), 0.5s polling
#   - Trap-based cleanup on EXIT (cleans up ALL acquired named locks)
#   - Caller sets LOCK_FAIL_OPEN=true before sourcing for fail-open behavior

# Resolve project root and lock path
_LOCK_PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
_LOCK_VIBECREW_DIR="$_LOCK_PROJECT_ROOT/.vibecrew"
_LOCK_DIR="$_LOCK_VIBECREW_DIR/locks/state-files"
_LOCK_ACQUIRED=false

# Track all acquired named locks for EXIT trap cleanup
_LOCK_ACTIVE_NAMES=()

# Configurable timeouts (can be overridden by config.json)
_LOCK_STALE_TIMEOUT_SECS=60
_LOCK_WAIT_TIMEOUT_SECS=30

# Read overrides from config.json if available
_LOCK_CONFIG_FILE="${_LOCK_VIBECREW_DIR}/config.json"
if [[ -f "$_LOCK_CONFIG_FILE" ]]; then
  _CFG_STALE="$(jq -r '.locks.stale_timeout_secs // empty' "$_LOCK_CONFIG_FILE" 2>/dev/null || echo "")"
  _CFG_WAIT="$(jq -r '.locks.wait_timeout_secs // empty' "$_LOCK_CONFIG_FILE" 2>/dev/null || echo "")"
  [[ -n "$_CFG_STALE" && "$_CFG_STALE" =~ ^[0-9]+$ ]] && _LOCK_STALE_TIMEOUT_SECS="$_CFG_STALE"
  [[ -n "$_CFG_WAIT" && "$_CFG_WAIT" =~ ^[0-9]+$ ]] && _LOCK_WAIT_TIMEOUT_SECS="$_CFG_WAIT"
fi

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
  # Clean up legacy state-files lock
  if [[ "$_LOCK_ACQUIRED" == "true" ]]; then
    rm -rf "$_LOCK_DIR"
  fi
  # Clean up all acquired named locks
  for _lock_name in ${_LOCK_ACTIVE_NAMES[@]+"${_LOCK_ACTIVE_NAMES[@]}"}; do
    rm -rf "$_LOCK_VIBECREW_DIR/locks/$_lock_name"
  done
  _LOCK_ACTIVE_NAMES=()
}

# Composable trap: append _lock_cleanup to any existing EXIT trap
_lock_existing_trap="$(trap -p EXIT | sed "s/^trap -- '//;s/' EXIT$//" 2>/dev/null || echo "")"
if [[ -n "$_lock_existing_trap" ]]; then
  trap "${_lock_existing_trap}; _lock_cleanup" EXIT
else
  trap '_lock_cleanup' EXIT
fi

# --- Check if existing lock is stale (older than configured timeout) ---
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
  [[ "$age" -gt "$_LOCK_STALE_TIMEOUT_SECS" ]]
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
  "timeout_seconds": $_LOCK_WAIT_TIMEOUT_SECS
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

  # Lock exists -- check if stale (atomic claim via rename)
  if _lock_is_stale; then
    mv "$_LOCK_DIR" "${_LOCK_DIR}.stale.$$" 2>/dev/null && {
      rm -rf "${_LOCK_DIR}.stale.$$"
      if mkdir "$_LOCK_DIR" 2>/dev/null; then
        _LOCK_ACQUIRED=true
        _lock_write_info "$caller"
        return 0
      fi
    }
  fi

  # Wait up to configured timeout, polling every 0.5s
  local max_attempts=$(( _LOCK_WAIT_TIMEOUT_SECS * 2 ))
  local attempts=0
  while [[ "$attempts" -lt "$max_attempts" ]]; do
    sleep 0.5
    if mkdir "$_LOCK_DIR" 2>/dev/null; then
      _LOCK_ACQUIRED=true
      _lock_write_info "$caller"
      return 0
    fi
    # Check for stale lock while waiting (atomic claim via rename)
    if _lock_is_stale; then
      mv "$_LOCK_DIR" "${_LOCK_DIR}.stale.$$" 2>/dev/null && rm -rf "${_LOCK_DIR}.stale.$$"
    fi
    ((attempts++))
  done

  # Timeout
  if [[ "${LOCK_FAIL_OPEN:-false}" == "true" ]]; then
    echo "WARNING: Could not acquire state lock after $_LOCK_WAIT_TIMEOUT_SECS seconds, proceeding without lock" >&2
    return 1
  else
    echo "ERROR: Could not acquire state lock after $_LOCK_WAIT_TIMEOUT_SECS seconds." >&2
    exit 1
  fi
}

release_state_lock() {
  rm -rf "$_LOCK_DIR"
  _LOCK_ACQUIRED=false
}

# --- Named Lock API ---

acquire_named_lock() {
  local lock_name="${1:?acquire_named_lock requires a lock name}"
  local caller="${2:-unknown}"
  local lock_dir="$_LOCK_VIBECREW_DIR/locks/$lock_name"

  mkdir -p "$_LOCK_VIBECREW_DIR/locks"

  # Try to acquire immediately
  if mkdir "$lock_dir" 2>/dev/null; then
    _LOCK_ACTIVE_NAMES+=("$lock_name")
    _lock_write_named_info "$lock_dir" "$caller" "$lock_name"
    return 0
  fi

  # Lock exists -- check if stale
  if _lock_is_stale_named "$lock_dir"; then
    mv "$lock_dir" "${lock_dir}.stale.$$" 2>/dev/null && {
      rm -rf "${lock_dir}.stale.$$"
      if mkdir "$lock_dir" 2>/dev/null; then
        _LOCK_ACTIVE_NAMES+=("$lock_name")
        _lock_write_named_info "$lock_dir" "$caller" "$lock_name"
        return 0
      fi
    }
  fi

  # Wait up to configured timeout, polling every 0.5s
  local max_attempts=$(( _LOCK_WAIT_TIMEOUT_SECS * 2 ))
  local attempts=0
  while [[ "$attempts" -lt "$max_attempts" ]]; do
    sleep 0.5
    if mkdir "$lock_dir" 2>/dev/null; then
      _LOCK_ACTIVE_NAMES+=("$lock_name")
      _lock_write_named_info "$lock_dir" "$caller" "$lock_name"
      return 0
    fi
    if _lock_is_stale_named "$lock_dir"; then
      mv "$lock_dir" "${lock_dir}.stale.$$" 2>/dev/null && rm -rf "${lock_dir}.stale.$$"
    fi
    ((attempts++))
  done

  # Timeout
  if [[ "${LOCK_FAIL_OPEN:-false}" == "true" ]]; then
    echo "WARNING: Could not acquire '$lock_name' lock after $_LOCK_WAIT_TIMEOUT_SECS seconds, proceeding without lock" >&2
    return 1
  else
    echo "ERROR: Could not acquire '$lock_name' lock after $_LOCK_WAIT_TIMEOUT_SECS seconds." >&2
    exit 1
  fi
}

release_named_lock() {
  local lock_name="${1:?release_named_lock requires a lock name}"
  local lock_dir="$_LOCK_VIBECREW_DIR/locks/$lock_name"
  rm -rf "$lock_dir"
  # Remove from active list
  local new_list=()
  for n in "${_LOCK_ACTIVE_NAMES[@]}"; do
    [[ "$n" != "$lock_name" ]] && new_list+=("$n")
  done
  _LOCK_ACTIVE_NAMES=("${new_list[@]+"${new_list[@]}"}")
}

# --- Named lock helpers ---

_lock_write_named_info() {
  local lock_dir="$1"
  local caller="$2"
  local lock_name="$3"
  local ts
  ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  cat > "$lock_dir/info.json" <<EOF
{
  "locked_by": "$caller",
  "pid": $$,
  "locked_at": "$ts",
  "lock_name": "$lock_name",
  "timeout_seconds": $_LOCK_WAIT_TIMEOUT_SECS
}
EOF
}

_lock_is_stale_named() {
  local lock_dir="$1"
  local lock_info="$lock_dir/info.json"
  if [[ ! -f "$lock_info" ]]; then
    return 0
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
  [[ "$age" -gt "$_LOCK_STALE_TIMEOUT_SECS" ]]
}
