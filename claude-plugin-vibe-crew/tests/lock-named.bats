#!/usr/bin/env bats
# tests/lock-named.bats
# Tests for named lock API in scripts/lib/lock.sh

setup() {
  load 'test_helper/common-setup'
  TEST_DIR="$(cd "$(mktemp -d)" && pwd -P)"
  mkdir -p "$TEST_DIR/.vibecrew/locks"
  export PROJECT_ROOT="$TEST_DIR"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "named lock: acquire and release cycle works" {
  run bash -c "
    export PROJECT_ROOT='$TEST_DIR'
    source '$SCRIPTS_DIR/lib/lock.sh'
    acquire_named_lock 'gamification' 'test-caller'
    [ -d '$TEST_DIR/.vibecrew/locks/gamification' ] && echo 'locked'
    release_named_lock 'gamification'
    [ ! -d '$TEST_DIR/.vibecrew/locks/gamification' ] && echo 'unlocked'
  "
  assert_success
  assert_output --partial "locked"
  assert_output --partial "unlocked"
}

@test "named lock: independent from state-files lock" {
  run bash -c "
    export PROJECT_ROOT='$TEST_DIR'
    source '$SCRIPTS_DIR/lib/lock.sh'
    acquire_state_lock 'test-state'
    acquire_named_lock 'gamification' 'test-gam'
    [ -d '$TEST_DIR/.vibecrew/locks/state-files' ] && echo 'state-locked'
    [ -d '$TEST_DIR/.vibecrew/locks/gamification' ] && echo 'gam-locked'
    release_named_lock 'gamification'
    [ -d '$TEST_DIR/.vibecrew/locks/state-files' ] && echo 'state-still-locked'
    [ ! -d '$TEST_DIR/.vibecrew/locks/gamification' ] && echo 'gam-unlocked'
    release_state_lock
  "
  assert_success
  assert_output --partial "state-locked"
  assert_output --partial "gam-locked"
  assert_output --partial "state-still-locked"
  assert_output --partial "gam-unlocked"
}

@test "named lock: EXIT trap cleans up all named locks" {
  run bash -c "
    export PROJECT_ROOT='$TEST_DIR'
    source '$SCRIPTS_DIR/lib/lock.sh'
    acquire_named_lock 'lock-a' 'trap-test'
    acquire_named_lock 'lock-b' 'trap-test'
    # Exit without explicit release — trap should clean up both
    exit 0
  "
  assert_success
  [ ! -d "$TEST_DIR/.vibecrew/locks/lock-a" ]
  [ ! -d "$TEST_DIR/.vibecrew/locks/lock-b" ]
}

@test "named lock: stale named lock reclaimed" {
  mkdir -p "$TEST_DIR/.vibecrew/locks/stale-test"
  cat > "$TEST_DIR/.vibecrew/locks/stale-test/info.json" <<EOF
{
  "locked_by": "stale-process",
  "pid": 99999,
  "locked_at": "2020-01-01T00:00:00Z",
  "lock_name": "stale-test",
  "timeout_seconds": 30
}
EOF

  run bash -c "
    export PROJECT_ROOT='$TEST_DIR'
    source '$SCRIPTS_DIR/lib/lock.sh'
    acquire_named_lock 'stale-test' 'reclaimer'
    echo 'acquired'
    release_named_lock 'stale-test'
  "
  assert_success
  assert_output --partial "acquired"
}

@test "named lock: info.json written correctly" {
  run bash -c "
    export PROJECT_ROOT='$TEST_DIR'
    source '$SCRIPTS_DIR/lib/lock.sh'
    acquire_named_lock 'info-test' 'my-caller'
    cat '$TEST_DIR/.vibecrew/locks/info-test/info.json'
    release_named_lock 'info-test'
  "
  assert_success
  assert_output --partial '"locked_by": "my-caller"'
  assert_output --partial '"lock_name": "info-test"'
}
