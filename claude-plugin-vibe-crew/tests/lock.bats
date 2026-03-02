#!/usr/bin/env bats
# tests/lock.bats
# Tests for scripts/lib/lock.sh — advisory locking with composable traps

setup() {
  load 'test_helper/common-setup'
  TEST_DIR="$(cd "$(mktemp -d)" && pwd -P)"
  mkdir -p "$TEST_DIR/.vibecrew/locks"
  export PROJECT_ROOT="$TEST_DIR"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "acquire and release cycle works" {
  run bash -c "
    export PROJECT_ROOT='$TEST_DIR'
    source '$SCRIPTS_DIR/lib/lock.sh'
    acquire_state_lock 'test-caller'
    [ -d '$TEST_DIR/.vibecrew/locks/state-files' ] && echo 'locked'
    release_state_lock
    [ ! -d '$TEST_DIR/.vibecrew/locks/state-files' ] && echo 'unlocked'
  "
  assert_success
  assert_output --partial "locked"
  assert_output --partial "unlocked"
}

@test "stale lock reclaimed after timeout" {
  # Create a stale lock (old timestamp)
  mkdir -p "$TEST_DIR/.vibecrew/locks/state-files"
  cat > "$TEST_DIR/.vibecrew/locks/state-files/info.json" <<EOF
{
  "locked_by": "stale-process",
  "pid": 99999,
  "locked_at": "2020-01-01T00:00:00Z",
  "target_files": "state.json,backlog.json",
  "timeout_seconds": 30
}
EOF

  run bash -c "
    export PROJECT_ROOT='$TEST_DIR'
    source '$SCRIPTS_DIR/lib/lock.sh'
    acquire_state_lock 'reclaimer'
    echo 'acquired'
    release_state_lock
  "
  assert_success
  assert_output --partial "acquired"
}

@test "trap cleanup fires on EXIT" {
  run bash -c "
    export PROJECT_ROOT='$TEST_DIR'
    source '$SCRIPTS_DIR/lib/lock.sh'
    acquire_state_lock 'trap-test'
    # Exit without explicit release — trap should clean up
    exit 0
  "
  assert_success
  # Lock directory should be cleaned up by EXIT trap
  [ ! -d "$TEST_DIR/.vibecrew/locks/state-files" ]
}

# =============================================================================
# Fix 3: PID liveness prevents reclaiming live locks
# =============================================================================

@test "live PID lock is NOT reclaimed even if old" {
  # Create a lock with old timestamp but OUR PID (which is alive)
  mkdir -p "$TEST_DIR/.vibecrew/locks/state-files"
  cat > "$TEST_DIR/.vibecrew/locks/state-files/info.json" <<EOF
{
  "locked_by": "live-process",
  "pid": $$,
  "locked_at": "2020-01-01T00:00:00Z",
  "target_files": "state.json,backlog.json",
  "timeout_seconds": 30
}
EOF

  # Attempt to acquire should fail (times out) because PID is alive
  run bash -c "
    export PROJECT_ROOT='$TEST_DIR'
    export LOCK_FAIL_OPEN=true
    _LOCK_WAIT_TIMEOUT_SECS=1
    source '$SCRIPTS_DIR/lib/lock.sh'
    _LOCK_WAIT_TIMEOUT_SECS=1
    acquire_state_lock 'test-caller'
  "
  assert_failure
  assert_output --partial "Could not acquire"
}

@test "dead PID lock is reclaimed when old" {
  # Create a lock with old timestamp and dead PID (99999)
  mkdir -p "$TEST_DIR/.vibecrew/locks/state-files"
  cat > "$TEST_DIR/.vibecrew/locks/state-files/info.json" <<EOF
{
  "locked_by": "dead-process",
  "pid": 99999,
  "locked_at": "2020-01-01T00:00:00Z",
  "target_files": "state.json,backlog.json",
  "timeout_seconds": 30
}
EOF

  run bash -c "
    export PROJECT_ROOT='$TEST_DIR'
    source '$SCRIPTS_DIR/lib/lock.sh'
    acquire_state_lock 'reclaimer'
    echo 'acquired'
    release_state_lock
  "
  assert_success
  assert_output --partial "acquired"
}

@test "named lock: live PID prevents reclaim" {
  mkdir -p "$TEST_DIR/.vibecrew/locks/gamification"
  cat > "$TEST_DIR/.vibecrew/locks/gamification/info.json" <<EOF
{
  "locked_by": "live-process",
  "pid": $$,
  "locked_at": "2020-01-01T00:00:00Z",
  "lock_name": "gamification",
  "timeout_seconds": 30
}
EOF

  run bash -c "
    export PROJECT_ROOT='$TEST_DIR'
    export LOCK_FAIL_OPEN=true
    source '$SCRIPTS_DIR/lib/lock.sh'
    _LOCK_WAIT_TIMEOUT_SECS=1
    acquire_named_lock 'gamification' 'test-caller'
  "
  assert_failure
  assert_output --partial "Could not acquire"
}

@test "named lock: dead PID allows reclaim" {
  mkdir -p "$TEST_DIR/.vibecrew/locks/gamification"
  cat > "$TEST_DIR/.vibecrew/locks/gamification/info.json" <<EOF
{
  "locked_by": "dead-process",
  "pid": 99999,
  "locked_at": "2020-01-01T00:00:00Z",
  "lock_name": "gamification",
  "timeout_seconds": 30
}
EOF

  run bash -c "
    export PROJECT_ROOT='$TEST_DIR'
    source '$SCRIPTS_DIR/lib/lock.sh'
    acquire_named_lock 'gamification' 'reclaimer'
    echo 'acquired'
    release_named_lock 'gamification'
  "
  assert_success
  assert_output --partial "acquired"
}

@test "composable trap does not overwrite existing traps" {
  run bash -c "
    export PROJECT_ROOT='$TEST_DIR'
    MARKER_FILE='$TEST_DIR/trap-marker'
    trap 'echo existing-trap-ran > \"\$MARKER_FILE\"' EXIT
    source '$SCRIPTS_DIR/lib/lock.sh'
    acquire_state_lock 'compose-test'
    exit 0
  "
  assert_success
  # Both the existing trap and lock cleanup should have run
  [ -f "$TEST_DIR/trap-marker" ]
  run cat "$TEST_DIR/trap-marker"
  assert_output "existing-trap-ran"
  # Lock should also be cleaned up
  [ ! -d "$TEST_DIR/.vibecrew/locks/state-files" ]
}
