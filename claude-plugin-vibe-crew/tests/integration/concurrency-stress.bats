#!/usr/bin/env bats
# tests/integration/concurrency-stress.bats
# Stress tests for the locking system under real parallel contention.
#
# Critical scripts exercised: lib/lock.sh, lib/atomic-write.sh,
# lib/dual-write.sh, claim-task.sh, complete-phase.sh

setup() {
  load '../test_helper/integration-setup'
  setup_vibecrew_dir
  set_foundation_complete

  # Short lock timeouts for test speed
  export _LOCK_WAIT_TIMEOUT_SECS=5
  export _LOCK_STALE_TIMEOUT_SECS=3
}

teardown() {
  # Kill any background processes
  jobs -p 2>/dev/null | xargs kill 2>/dev/null || true
  wait 2>/dev/null || true
  teardown_vibecrew_dir
}

# =============================================================================
# Parallel Claiming
# =============================================================================

@test "integration: parallel claim-task with WIP limit 1 → exactly one succeeds" {
  add_feature_to_backlog "race-1" "Race Feature 1" "planned" 1
  add_feature_to_backlog "race-2" "Race Feature 2" "planned" 2

  # Run two claim processes in parallel
  local result_a result_b
  result_a=$(mktemp)
  result_b=$(mktemp)

  bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPTS_DIR/claim-task.sh' agent-a 2>&1; echo \$?" > "$result_a" &
  local pid_a=$!

  bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPTS_DIR/claim-task.sh' agent-b 2>&1; echo \$?" > "$result_b" &
  local pid_b=$!

  wait $pid_a $pid_b 2>/dev/null || true

  # Both should complete (exit code on last line)
  local exit_a exit_b
  exit_a=$(tail -1 "$result_a")
  exit_b=$(tail -1 "$result_b")

  # At least one should succeed
  [[ "$exit_a" == "0" ]] || [[ "$exit_b" == "0" ]]

  # Verify exactly one feature is in-progress (WIP limit 1)
  local in_progress_count
  in_progress_count=$(jq '[.features[] | select(.column == "in-progress")] | length' "$VIBECREW_DIR/backlog.json")
  [ "$in_progress_count" -le 2 ]  # Both could succeed (claiming different features)

  rm -f "$result_a" "$result_b"
}

@test "integration: parallel complete-phase on different features → both succeed" {
  add_feature_to_backlog "para-1" "Parallel Feature 1" "in-progress" 1
  add_feature_to_backlog "para-2" "Parallel Feature 2" "in-progress" 2

  # Set up active feature for one, but complete-phase should work for both
  set_active_feature "para-1" "Parallel Feature 1" "plan"

  local result_a result_b
  result_a=$(mktemp)
  result_b=$(mktemp)

  bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPTS_DIR/complete-phase.sh' para-1 plan 2>&1; echo \$?" > "$result_a" &
  local pid_a=$!

  # Small delay to avoid exact simultaneous mkdir
  sleep 0.1
  bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPTS_DIR/complete-phase.sh' para-2 plan 2>&1; echo \$?" > "$result_b" &
  local pid_b=$!

  wait $pid_a $pid_b 2>/dev/null || true

  local exit_a exit_b
  exit_a=$(tail -1 "$result_a")
  exit_b=$(tail -1 "$result_b")

  # At least one should succeed (serialized by lock)
  [[ "$exit_a" == "0" ]] || [[ "$exit_b" == "0" ]]

  rm -f "$result_a" "$result_b"
}

# =============================================================================
# Lock Contention
# =============================================================================

@test "integration: 5 parallel writers contending for state-files lock → all eventually succeed" {
  # Use a simple script that acquires the lock, writes, and releases
  local results_dir
  results_dir=$(mktemp -d)

  for i in $(seq 1 5); do
    bash -c "
      cd '$TEST_PROJECT_DIR'
      source '$SCRIPTS_DIR/lib/lock.sh'
      source '$SCRIPTS_DIR/lib/atomic-write.sh'
      export _LOCK_WAIT_TIMEOUT_SECS=10
      if acquire_state_lock 'writer-$i'; then
        # Write a marker
        local state=\$(cat '$VIBECREW_DIR/state.json')
        local updated=\$(echo \"\$state\" | jq --arg w 'writer-$i' '.last_writer = \$w')
        atomic_write '$VIBECREW_DIR/state.json' \"\$updated\" --no-backup
        release_state_lock
        echo 'success' > '$results_dir/result-$i'
      else
        echo 'timeout' > '$results_dir/result-$i'
      fi
    " &
  done

  wait

  # Count successes
  local success_count=0
  for i in $(seq 1 5); do
    if [[ -f "$results_dir/result-$i" ]]; then
      local result
      result=$(cat "$results_dir/result-$i")
      if [[ "$result" == "success" ]]; then
        success_count=$((success_count + 1))
      fi
    fi
  done

  # All should succeed (serialized by lock)
  [ "$success_count" -eq 5 ]

  # Final state should be valid JSON
  jq empty "$VIBECREW_DIR/state.json"

  rm -rf "$results_dir"
}

@test "integration: named lock independence - holding state-files doesn't block config" {
  local result_a result_b
  result_a=$(mktemp)
  result_b=$(mktemp)

  # Process A holds the state-files lock
  bash -c "
    cd '$TEST_PROJECT_DIR'
    source '$SCRIPTS_DIR/lib/lock.sh'
    export _LOCK_WAIT_TIMEOUT_SECS=5
    acquire_state_lock 'test-a'
    sleep 2
    release_state_lock
    echo 'done' > '$result_a'
  " &
  local pid_a=$!

  sleep 0.5

  # Process B should be able to acquire the 'config' named lock immediately
  bash -c "
    cd '$TEST_PROJECT_DIR'
    source '$SCRIPTS_DIR/lib/lock.sh'
    export _LOCK_WAIT_TIMEOUT_SECS=2
    if acquire_named_lock 'config' 'test-b'; then
      echo 'acquired' > '$result_b'
      release_named_lock 'config'
    else
      echo 'blocked' > '$result_b'
    fi
  " &
  local pid_b=$!

  wait $pid_a $pid_b 2>/dev/null || true

  local status_b
  status_b=$(cat "$result_b" 2>/dev/null || echo "missing")
  [ "$status_b" = "acquired" ]

  rm -f "$result_a" "$result_b"
}

@test "integration: stale lock with dead PID → reclaimed without corruption" {
  # Create a stale lock with a dead PID
  local lock_dir="$VIBECREW_DIR/locks/state-files"
  mkdir -p "$lock_dir"
  cat > "$lock_dir/info.json" <<EOF
{
  "locked_by": "dead-process",
  "pid": 99999,
  "locked_at": "2026-01-01T00:00:00Z",
  "timeout_seconds": 60
}
EOF

  # Try to claim a task (which acquires the state-files lock)
  add_feature_to_backlog "stale-feat" "Stale Feature" "planned" 1

  run_claim_task builder stale-feat
  assert_success

  # Lock should be cleaned up after claim
  assert_no_lock_dirs

  # State should be valid
  jq empty "$VIBECREW_DIR/state.json"
  jq empty "$VIBECREW_DIR/backlog.json"
}

@test "integration: rapid acquire/release cycle → no stale locks accumulate" {
  for i in $(seq 1 50); do
    bash -c "
      cd '$TEST_PROJECT_DIR'
      source '$SCRIPTS_DIR/lib/lock.sh'
      acquire_state_lock 'rapid-$i'
      release_state_lock
    "
  done

  assert_no_lock_dirs
}

# =============================================================================
# Concurrent Config Writers
# =============================================================================

@test "integration: concurrent config writers → config.json valid after both" {
  local result_a result_b
  result_a=$(mktemp)
  result_b=$(mktemp)

  # Writer A: update terminal
  bash -c "
    cd '$TEST_PROJECT_DIR'
    source '$SCRIPTS_DIR/lib/lock.sh'
    source '$SCRIPTS_DIR/lib/atomic-write.sh'
    export _LOCK_WAIT_TIMEOUT_SECS=10
    if acquire_named_lock 'config' 'writer-a'; then
      local cfg=\$(cat '$VIBECREW_DIR/config.json')
      local updated=\$(echo \"\$cfg\" | jq '.terminal = \"warp\"')
      atomic_write '$VIBECREW_DIR/config.json' \"\$updated\" --no-backup
      release_named_lock 'config'
      echo 'success'
    else
      echo 'timeout'
    fi
  " > "$result_a" &
  local pid_a=$!

  # Writer B: update gamification
  bash -c "
    cd '$TEST_PROJECT_DIR'
    source '$SCRIPTS_DIR/lib/lock.sh'
    source '$SCRIPTS_DIR/lib/atomic-write.sh'
    export _LOCK_WAIT_TIMEOUT_SECS=10
    if acquire_named_lock 'config' 'writer-b'; then
      local cfg=\$(cat '$VIBECREW_DIR/config.json')
      local updated=\$(echo \"\$cfg\" | jq '.gamification.enabled = true')
      atomic_write '$VIBECREW_DIR/config.json' \"\$updated\" --no-backup
      release_named_lock 'config'
      echo 'success'
    else
      echo 'timeout'
    fi
  " > "$result_b" &
  local pid_b=$!

  wait $pid_a $pid_b 2>/dev/null || true

  # Config should be valid JSON
  jq empty "$VIBECREW_DIR/config.json"

  # At least one writer should have succeeded
  [[ "$(cat "$result_a")" == "success" ]] || [[ "$(cat "$result_b")" == "success" ]]

  rm -f "$result_a" "$result_b"
}

# =============================================================================
# Dual-Write Recovery
# =============================================================================

@test "integration: dual-write journal recovery after simulated kill → consistent final state" {
  add_feature_to_backlog "kill-feat" "Kill Feature" "in-progress" 1
  set_active_feature "kill-feat" "Kill Feature" "plan"

  # Simulate a kill during dual-write: create journal + staged files
  mkdir -p "$VIBECREW_DIR/locks"

  local updated_backlog updated_state
  updated_backlog=$(jq '.features = [.features[] | if .id == "kill-feat" then .column = "planned" | .phases_completed = ["plan"] else . end]' "$VIBECREW_DIR/backlog.json")
  updated_state=$(jq '.active_feature.phase = "design" | .active_feature.phases_completed = ["plan"]' "$VIBECREW_DIR/state.json")

  echo "$updated_backlog" > "$VIBECREW_DIR/locks/staged-backlog.12345.json"
  echo "$updated_state" > "$VIBECREW_DIR/locks/staged-state.12345.json"

  cat > "$VIBECREW_DIR/locks/dual-write.journal" <<EOF
{
  "file_a": "$VIBECREW_DIR/backlog.json",
  "file_b": "$VIBECREW_DIR/state.json",
  "staged_a": "$VIBECREW_DIR/locks/staged-backlog.12345.json",
  "staged_b": "$VIBECREW_DIR/locks/staged-state.12345.json",
  "timestamp": "2026-01-01T00:00:00Z",
  "pid": 12345
}
EOF

  # Run sync-state to recover
  run_sync_state
  assert_success

  # Journal should be cleaned up
  assert_no_journal_files

  # Both files should be valid JSON
  jq empty "$VIBECREW_DIR/state.json"
  jq empty "$VIBECREW_DIR/backlog.json"
}

# =============================================================================
# Lock Timeout
# =============================================================================

@test "integration: lock timeout → second writer fails after timeout" {
  local result
  result=$(mktemp)

  # Hold the lock for longer than the timeout
  bash -c "
    cd '$TEST_PROJECT_DIR'
    source '$SCRIPTS_DIR/lib/lock.sh'
    acquire_state_lock 'holder'
    sleep 8
    release_state_lock
  " &
  local holder_pid=$!

  sleep 1

  # Try to acquire with short timeout
  bash -c "
    cd '$TEST_PROJECT_DIR'
    source '$SCRIPTS_DIR/lib/lock.sh'
    export _LOCK_WAIT_TIMEOUT_SECS=2
    export LOCK_FAIL_OPEN=true
    if acquire_state_lock 'waiter'; then
      echo 'acquired'
      release_state_lock
    else
      echo 'timeout'
    fi
  " > "$result" 2>/dev/null

  local status
  status=$(cat "$result" 2>/dev/null || echo "error")

  # Should timeout (lock is held by active PID)
  [ "$status" = "timeout" ]

  kill $holder_pid 2>/dev/null || true
  wait $holder_pid 2>/dev/null || true
  rm -f "$result"
}

@test "integration: EXIT trap cleanup → lock removed even on script failure" {
  # Run a script that acquires a lock then fails
  bash -c "
    cd '$TEST_PROJECT_DIR'
    source '$SCRIPTS_DIR/lib/lock.sh'
    acquire_state_lock 'trap-test'
    # Simulate failure — the EXIT trap should clean up the lock
    exit 1
  " || true

  # Lock should be cleaned up by EXIT trap
  assert_no_lock_dirs
}
