#!/usr/bin/env bats
# tests/lock-contention.bats
# Tests for lock system concurrency behavior

setup() {
  load 'test_helper/common-setup'
  TEST_DIR="$(cd "$(mktemp -d)" && pwd -P)"
  mkdir -p "$TEST_DIR/.vibecrew/locks"
  export PROJECT_ROOT="$TEST_DIR"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "second process waits then acquires after first releases" {
  # Process 1: acquire lock, hold for 1.5s, release
  bash -c "
    export PROJECT_ROOT='$TEST_DIR'
    source '$SCRIPTS_DIR/lib/lock.sh'
    acquire_state_lock 'holder'
    sleep 1.5
    release_state_lock
  " &
  local holder_pid=$!

  # Wait a moment for process 1 to acquire
  sleep 0.3

  # Process 2: try to acquire (should wait, then succeed)
  run bash -c "
    export PROJECT_ROOT='$TEST_DIR'
    source '$SCRIPTS_DIR/lib/lock.sh'
    acquire_state_lock 'waiter'
    echo 'waiter-acquired'
    release_state_lock
  "

  wait "$holder_pid" 2>/dev/null || true

  assert_success
  assert_output --partial "waiter-acquired"
}

@test "named locks are independent — different names don't block" {
  run bash -c "
    export PROJECT_ROOT='$TEST_DIR'
    source '$SCRIPTS_DIR/lib/lock.sh'
    acquire_named_lock 'lock-a' 'process-1'
    acquire_named_lock 'lock-b' 'process-1'
    echo 'both-acquired'
    release_named_lock 'lock-a'
    release_named_lock 'lock-b'
  "
  assert_success
  assert_output --partial "both-acquired"
}

@test "millisecond timestamps differentiate rapid acquisitions" {
  # Acquire, release, re-acquire rapidly — timestamps should differ
  run bash -c "
    export PROJECT_ROOT='$TEST_DIR'
    source '$SCRIPTS_DIR/lib/lock.sh'
    acquire_state_lock 'rapid-1'
    TS1=\$(jq -r '.locked_at' '$TEST_DIR/.vibecrew/locks/state-files/info.json')
    release_state_lock

    # Small delay to ensure different millisecond
    sleep 0.01

    acquire_state_lock 'rapid-2'
    TS2=\$(jq -r '.locked_at' '$TEST_DIR/.vibecrew/locks/state-files/info.json')
    release_state_lock

    if [[ \"\$TS1\" != \"\$TS2\" ]]; then
      echo 'timestamps-differ'
    else
      echo 'timestamps-same'
    fi
    echo \"TS1=\$TS1\"
    echo \"TS2=\$TS2\"
  "
  assert_success
  assert_output --partial "timestamps-differ"
}

@test "lock info.json contains millisecond-precision timestamp" {
  run bash -c "
    export PROJECT_ROOT='$TEST_DIR'
    source '$SCRIPTS_DIR/lib/lock.sh'
    acquire_state_lock 'ms-test'
    cat '$TEST_DIR/.vibecrew/locks/state-files/info.json'
    release_state_lock
  "
  assert_success
  # Verify the locked_at has millisecond precision (contains a dot before Z)
  local locked_at
  locked_at=$(echo "$output" | jq -r '.locked_at')
  [[ "$locked_at" =~ \.[0-9]{3}Z$ ]]
}

@test "lock info.json timeout_seconds matches stale timeout (60)" {
  run bash -c "
    export PROJECT_ROOT='$TEST_DIR'
    source '$SCRIPTS_DIR/lib/lock.sh'
    acquire_state_lock 'timeout-test'
    cat '$TEST_DIR/.vibecrew/locks/state-files/info.json'
    release_state_lock
  "
  assert_success
  local timeout
  timeout=$(echo "$output" | jq -r '.timeout_seconds')
  [[ "$timeout" == "60" ]]
}
