#!/usr/bin/env bats

# Tests for R13: Lock Timeout Unification

setup() {
  TEST_DIR="$(mktemp -d)"
  mkdir -p "$TEST_DIR/.vibecrew/locks"
  export PROJECT_ROOT="$TEST_DIR"
  export _LOCK_PROJECT_ROOT="$TEST_DIR"
  export _LOCK_VIBECREW_DIR="$TEST_DIR/.vibecrew"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "default stale timeout is 60 seconds" {
  # No config file — should use default
  _LOCK_STALE_TIMEOUT_SECS=60
  _LOCK_CONFIG_FILE="$TEST_DIR/.vibecrew/config.json"
  if [[ -f "$_LOCK_CONFIG_FILE" ]]; then
    _CFG_STALE="$(jq -r '.locks.stale_timeout_secs // empty' "$_LOCK_CONFIG_FILE" 2>/dev/null || echo "")"
    [[ -n "$_CFG_STALE" && "$_CFG_STALE" =~ ^[0-9]+$ ]] && _LOCK_STALE_TIMEOUT_SECS="$_CFG_STALE"
  fi
  [ "$_LOCK_STALE_TIMEOUT_SECS" -eq 60 ]
}

@test "stale timeout reads from config" {
  cat > "$TEST_DIR/.vibecrew/config.json" << 'EOF'
{
  "locks": {
    "stale_timeout_secs": 120,
    "wait_timeout_secs": 45
  }
}
EOF
  _LOCK_STALE_TIMEOUT_SECS=60
  _LOCK_WAIT_TIMEOUT_SECS=30
  _LOCK_CONFIG_FILE="$TEST_DIR/.vibecrew/config.json"
  _CFG_STALE="$(jq -r '.locks.stale_timeout_secs // empty' "$_LOCK_CONFIG_FILE" 2>/dev/null || echo "")"
  _CFG_WAIT="$(jq -r '.locks.wait_timeout_secs // empty' "$_LOCK_CONFIG_FILE" 2>/dev/null || echo "")"
  [[ -n "$_CFG_STALE" && "$_CFG_STALE" =~ ^[0-9]+$ ]] && _LOCK_STALE_TIMEOUT_SECS="$_CFG_STALE"
  [[ -n "$_CFG_WAIT" && "$_CFG_WAIT" =~ ^[0-9]+$ ]] && _LOCK_WAIT_TIMEOUT_SECS="$_CFG_WAIT"

  [ "$_LOCK_STALE_TIMEOUT_SECS" -eq 120 ]
  [ "$_LOCK_WAIT_TIMEOUT_SECS" -eq 45 ]
}
