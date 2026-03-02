#!/usr/bin/env bats
# tests/error-recovery.bats
# Tests for scripts/error-recovery.sh — common error recovery utility

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir

  # Make an initial commit so git commands work cleanly
  git -C "$TEST_PROJECT_DIR" commit --allow-empty -m "init" >/dev/null 2>&1

  # Commit the .vibecrew directory so it does not show as uncommitted changes
  git -C "$TEST_PROJECT_DIR" add -A >/dev/null 2>&1
  git -C "$TEST_PROJECT_DIR" commit -m "add vibecrew dir" >/dev/null 2>&1
}

teardown() {
  teardown_vibecrew_dir
}

run_recovery() {
  export PROJECT_ROOT="$TEST_PROJECT_DIR"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPTS_DIR/error-recovery.sh'"
}

# =============================================================================
# 1. No-op when no errors exist
# =============================================================================

@test "clean environment: reports no lock or temp issues and no actions taken" {
  run_recovery
  assert_success
  assert_output --partial "VibeCrew Error Recovery"
  assert_output --partial "Locks:     clean"
  assert_output --partial "Git:       clean"
  assert_output --partial "Temp:      clean"
  refute_output --partial "Actions taken"
}

# =============================================================================
# 2. Cleans stale locks
# =============================================================================

@test "stale lock without info.json: removed" {
  mkdir -p "$VIBECREW_DIR/locks/orphan-lock"

  run_recovery
  assert_success
  assert_output --partial "stale locks cleaned"
  assert_output --partial "Removed stale lock: orphan-lock"
  [ ! -d "$VIBECREW_DIR/locks/orphan-lock" ]
}

@test "stale lock with old timestamp: removed" {
  mkdir -p "$VIBECREW_DIR/locks/old-lock"
  cat > "$VIBECREW_DIR/locks/old-lock/info.json" <<EOF
{
  "locked_by": "dead-process",
  "pid": 99999,
  "locked_at": "2020-01-01T00:00:00Z",
  "timeout_seconds": 30
}
EOF

  run_recovery
  assert_success
  assert_output --partial "stale locks cleaned"
  assert_output --partial "Removed stale lock: old-lock"
  [ ! -d "$VIBECREW_DIR/locks/old-lock" ]
}

# =============================================================================
# 3. Handles corrupted state.json
# =============================================================================

@test "corrupted state.json: script still exits 0 and produces report" {
  echo "NOT VALID JSON {{{" > "$VIBECREW_DIR/state.json"

  run_recovery
  assert_success
  assert_output --partial "VibeCrew Error Recovery"
  assert_output --partial "Locks:"
  assert_output --partial "Temp:"
}

# =============================================================================
# 4. Handles missing backlog.json
# =============================================================================

@test "missing backlog.json: script still exits 0 and produces report" {
  rm -f "$VIBECREW_DIR/backlog.json"

  run_recovery
  assert_success
  assert_output --partial "VibeCrew Error Recovery"
  assert_output --partial "Locks:"
  assert_output --partial "Temp:"
}

# =============================================================================
# 5. Detects orphaned worktree references
#    The script checks git state (detached HEAD, unfinished merge/rebase,
#    uncommitted changes). We simulate git issues to test detection.
# =============================================================================

@test "unfinished merge detected as git issue" {
  # Simulate an unfinished merge by creating the MERGE_HEAD sentinel file
  echo "abc1234abc1234abc1234abc1234abc1234abc123" > "$TEST_PROJECT_DIR/.git/MERGE_HEAD"

  run_recovery
  assert_success
  assert_output --partial "unfinished merge"
  assert_output --partial "Requires attention"
}

@test "unfinished rebase detected as git issue" {
  # Simulate an unfinished rebase by creating the rebase-merge directory
  mkdir -p "$TEST_PROJECT_DIR/.git/rebase-merge"

  run_recovery
  assert_success
  assert_output --partial "unfinished rebase"
  assert_output --partial "Requires attention"
}

# =============================================================================
# 6. Script exits 0 always (non-blocking)
# =============================================================================

@test "exits 0 even with multiple issues present simultaneously" {
  # Create stale lock (no info.json)
  mkdir -p "$VIBECREW_DIR/locks/stale-one"

  # Create uncommitted changes
  echo "dirty" > "$TEST_PROJECT_DIR/dirty.txt"
  git -C "$TEST_PROJECT_DIR" add dirty.txt

  # Simulate unfinished merge
  echo "abc1234abc1234abc1234abc1234abc1234abc123" > "$TEST_PROJECT_DIR/.git/MERGE_HEAD"

  run_recovery
  assert_success
  # Verify the script produced output (did not crash silently)
  assert_output --partial "VibeCrew Error Recovery"
}

# =============================================================================
# 7. Handles missing .vibecrew directory
# =============================================================================

@test "missing .vibecrew directory: script still exits 0" {
  rm -rf "$VIBECREW_DIR"

  run_recovery
  assert_success
  assert_output --partial "Locks:     clean"
  assert_output --partial "Temp:      clean"
}

# =============================================================================
# 8. Logs errors to error report output
# =============================================================================

@test "actions and attention items appear in structured output report" {
  # Create a stale lock so there is an action
  mkdir -p "$VIBECREW_DIR/locks/report-lock"

  # Create uncommitted changes so there is a requires-attention item
  echo "report-test" > "$TEST_PROJECT_DIR/report-file.txt"
  git -C "$TEST_PROJECT_DIR" add report-file.txt

  run_recovery
  assert_success

  # Verify structured report header
  assert_output --partial "VibeCrew Error Recovery"
  assert_output --partial "====================="

  # Verify action was logged
  assert_output --partial "Actions taken:"
  assert_output --partial "Removed stale lock: report-lock"

  # Verify attention item was logged
  assert_output --partial "Requires attention:"
  assert_output --partial "uncommitted changes"
}
