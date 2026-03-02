#!/usr/bin/env bash
# scripts/error-recovery.sh
# Common error recovery utility for VibeCrew.
# TAKES ACTION on: stale lock removal, temp file cleanup
# REPORTS ONLY on: port conflicts, orphaned processes, git state issues
# Exit 0 always (fail open -- recovery should not create new problems)

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"
GIT_DIR="$PROJECT_ROOT/.git"

source "$(dirname "$0")/lib/compat.sh"

ACTIONS_TAKEN=()
REQUIRES_ATTENTION=()

# Counters
STALE_LOCKS=0
PORTS_IN_USE=0
PORTS_LIST=()
ORPHANED_PROCS=0
ORPHANED_LIST=()
GIT_ISSUES=()
TEMP_CLEANED=0

# =============================================================================
# Timestamp helpers — delegate to compat.sh
# =============================================================================

parse_timestamp() {
  _compat_parse_timestamp "$1"
}

# =============================================================================
# 1. Stale lock cleanup
# Remove .vibecrew/locks/*/ directories older than 60 seconds
# =============================================================================

cleanup_stale_locks() {
  # Use lock timeout constant if available
  local stale_timeout=60
  local lock_lib="$(dirname "$0")/lib/lock.sh"
  if [[ -f "$lock_lib" ]]; then
    # Source just the config-reading portion
    local config_file="$VIBECREW_DIR/config.json"
    if [[ -f "$config_file" ]]; then
      local cfg_stale
      cfg_stale="$(jq -r '.locks.stale_timeout_secs // empty' "$config_file" 2>/dev/null || echo "")"
      [[ -n "$cfg_stale" && "$cfg_stale" =~ ^[0-9]+$ ]] && stale_timeout="$cfg_stale"
    fi
  fi

  local locks_dir="$VIBECREW_DIR/locks"
  if [[ ! -d "$locks_dir" ]]; then
    return 0
  fi

  local now_epoch
  now_epoch=$(date "+%s")

  for lock_dir in "$locks_dir"/*/; do
    # Skip if glob did not match (no directories)
    [[ -d "$lock_dir" ]] || continue

    local lock_name
    lock_name=$(basename "$lock_dir")
    local lock_info="$lock_dir/info.json"

    local is_stale=false

    if [[ ! -f "$lock_info" ]]; then
      # No info.json -- treat as stale
      is_stale=true
    else
      local locked_at
      locked_at=$(jq -r '.locked_at // empty' "$lock_info" 2>/dev/null || echo "")

      if [[ -z "$locked_at" ]]; then
        is_stale=true
      else
        local lock_epoch
        lock_epoch=$(parse_timestamp "$locked_at")
        local age=$(( now_epoch - lock_epoch ))
        if [[ "$age" -gt "$stale_timeout" ]]; then
          is_stale=true
        fi
      fi
    fi

    if [[ "$is_stale" == "true" ]]; then
      rm -rf "$lock_dir"
      STALE_LOCKS=$(( STALE_LOCKS + 1 ))
      ACTIONS_TAKEN+=("Removed stale lock: $lock_name")
    fi
  done
}

# =============================================================================
# 2. Port conflict resolution (report only)
# Check common dev ports for processes
# =============================================================================

check_port_conflicts() {
  local ports=(3000 3001 3002 4173 5173 8080)

  for port in "${ports[@]}"; do
    # Use lsof to check if port is in use
    local port_info
    port_info=$(lsof -iTCP:"$port" -sTCP:LISTEN -P -n 2>/dev/null | tail -n +2 || true)

    if [[ -n "$port_info" ]]; then
      PORTS_IN_USE=$(( PORTS_IN_USE + 1 ))
      local proc_name pid
      proc_name=$(echo "$port_info" | head -1 | awk '{print $1}')
      pid=$(echo "$port_info" | head -1 | awk '{print $2}')
      PORTS_LIST+=("$port ($proc_name, PID $pid)")
      REQUIRES_ATTENTION+=("Port $port in use by $proc_name (PID $pid)")
    fi
  done
}

# =============================================================================
# 3. Orphaned process detection (report only)
# Look for lingering node/vite/next processes
# =============================================================================

detect_orphaned_processes() {
  # Search for common dev server processes
  local process_patterns=("node.*vite" "node.*next" "node.*dev" "vite" "next-server")

  for pattern in "${process_patterns[@]}"; do
    local procs
    procs=$(ps aux 2>/dev/null | grep -i "$pattern" | grep -v "grep" | grep -v "error-recovery" || true)

    if [[ -n "$procs" ]]; then
      while IFS= read -r proc_line; do
        local pid cmd
        pid=$(echo "$proc_line" | awk '{print $2}')
        cmd=$(echo "$proc_line" | awk '{for(i=11;i<=NF;i++) printf "%s ", $i; print ""}' | sed 's/ *$//')

        # Truncate long commands
        if [[ ${#cmd} -gt 80 ]]; then
          cmd="${cmd:0:77}..."
        fi

        # Avoid duplicates (same PID)
        local already_reported=false
        for existing in "${ORPHANED_LIST[@]+"${ORPHANED_LIST[@]}"}"; do
          if [[ "$existing" == "PID $pid:"* ]]; then
            already_reported=true
            break
          fi
        done

        if [[ "$already_reported" == "false" ]]; then
          ORPHANED_PROCS=$(( ORPHANED_PROCS + 1 ))
          ORPHANED_LIST+=("PID $pid: $cmd")
          REQUIRES_ATTENTION+=("Orphaned process PID $pid: $cmd")
        fi
      done <<< "$procs"
    fi
  done
}

# =============================================================================
# 4. Git state recovery (report only)
# =============================================================================

check_git_state() {
  # Only check if we are in a git repo
  if [[ ! -d "$GIT_DIR" ]]; then
    return 0
  fi

  # Check for unfinished merge
  if [[ -f "$GIT_DIR/MERGE_HEAD" ]]; then
    GIT_ISSUES+=("unfinished merge (resolve with: git merge --abort)")
    REQUIRES_ATTENTION+=("Git: unfinished merge detected. Run 'git merge --abort' to abort or resolve conflicts.")
  fi

  # Check for unfinished rebase
  if [[ -d "$GIT_DIR/rebase-merge" ]] || [[ -d "$GIT_DIR/rebase-apply" ]]; then
    GIT_ISSUES+=("unfinished rebase (resolve with: git rebase --abort)")
    REQUIRES_ATTENTION+=("Git: unfinished rebase detected. Run 'git rebase --abort' to abort or resolve.")
  fi

  # Check for detached HEAD
  local head_ref
  head_ref=$(git -C "$PROJECT_ROOT" symbolic-ref HEAD 2>/dev/null || echo "detached")
  if [[ "$head_ref" == "detached" ]]; then
    local head_sha
    head_sha=$(git -C "$PROJECT_ROOT" rev-parse --short HEAD 2>/dev/null || echo "unknown")
    GIT_ISSUES+=("detached HEAD at $head_sha")
    REQUIRES_ATTENTION+=("Git: detached HEAD at $head_sha. Run 'git checkout <branch>' to reattach.")
  fi

  # Check for uncommitted changes
  local uncommitted_count=0
  local status_output
  status_output=$(git -C "$PROJECT_ROOT" status --porcelain 2>/dev/null || true)
  if [[ -n "$status_output" ]]; then
    uncommitted_count=$(echo "$status_output" | wc -l | tr -d ' ')
    GIT_ISSUES+=("$uncommitted_count uncommitted changes")
    REQUIRES_ATTENTION+=("Git: $uncommitted_count uncommitted changes. Run 'git status' to review.")
  fi
}

# =============================================================================
# 5. Temp file cleanup
# Remove .vibecrew/*.tmp files older than 5 minutes
# =============================================================================

cleanup_temp_files() {
  if [[ ! -d "$VIBECREW_DIR" ]]; then
    return 0
  fi

  local now_epoch
  now_epoch=$(date "+%s")
  local five_minutes=300

  for tmp_file in "$VIBECREW_DIR"/*.tmp "$VIBECREW_DIR"/*.tmp.*; do
    # Skip if glob did not match
    [[ -f "$tmp_file" ]] || continue

    local file_epoch
    # Get file modification time (macOS and GNU compatible)
    if stat -f "%m" "$tmp_file" &>/dev/null; then
      # macOS stat
      file_epoch=$(stat -f "%m" "$tmp_file" 2>/dev/null || echo "0")
    else
      # GNU stat
      file_epoch=$(stat -c "%Y" "$tmp_file" 2>/dev/null || echo "0")
    fi

    local age=$(( now_epoch - file_epoch ))
    if [[ "$age" -gt "$five_minutes" ]]; then
      rm -f "$tmp_file"
      TEMP_CLEANED=$(( TEMP_CLEANED + 1 ))
      ACTIONS_TAKEN+=("Removed stale temp file: $(basename "$tmp_file")")
    fi
  done
}

# =============================================================================
# Run all checks
# =============================================================================

cleanup_stale_locks
check_port_conflicts
detect_orphaned_processes
check_git_state
cleanup_temp_files

# =============================================================================
# Output report
# =============================================================================

echo "VibeCrew Error Recovery"
echo "====================="

# Locks
if [[ "$STALE_LOCKS" -gt 0 ]]; then
  echo "Locks:     $STALE_LOCKS stale locks cleaned"
else
  echo "Locks:     clean"
fi

# Ports
if [[ "$PORTS_IN_USE" -gt 0 ]]; then
  PORTS_DISPLAY=$(printf '%s, ' "${PORTS_LIST[@]}")
  PORTS_DISPLAY="${PORTS_DISPLAY%, }"
  echo "Ports:     $PORTS_IN_USE ports in use ($PORTS_DISPLAY)"
else
  echo "Ports:     all free"
fi

# Processes
if [[ "$ORPHANED_PROCS" -gt 0 ]]; then
  PROCS_DISPLAY=$(printf '%s, ' "${ORPHANED_LIST[@]}")
  PROCS_DISPLAY="${PROCS_DISPLAY%, }"
  echo "Processes: $ORPHANED_PROCS orphaned ($PROCS_DISPLAY)"
else
  echo "Processes: clean"
fi

# Git
if [[ ${#GIT_ISSUES[@]} -gt 0 ]]; then
  GIT_DISPLAY=$(printf '%s; ' "${GIT_ISSUES[@]}")
  GIT_DISPLAY="${GIT_DISPLAY%; }"
  echo "Git:       $GIT_DISPLAY"
else
  echo "Git:       clean"
fi

# Temp
if [[ "$TEMP_CLEANED" -gt 0 ]]; then
  echo "Temp:      $TEMP_CLEANED files cleaned"
else
  echo "Temp:      clean"
fi

# Actions taken
if [[ ${#ACTIONS_TAKEN[@]} -gt 0 ]]; then
  echo ""
  echo "Actions taken:"
  for action in "${ACTIONS_TAKEN[@]}"; do
    echo "  - $action"
  done
fi

# Requires attention
if [[ ${#REQUIRES_ATTENTION[@]} -gt 0 ]]; then
  echo ""
  echo "Requires attention:"
  for item in "${REQUIRES_ATTENTION[@]}"; do
    echo "  - $item"
  done
fi

exit 0
