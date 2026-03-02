#!/usr/bin/env bats
# tests/dual-write-error-recovery.bats
# Verify dual-write journal persists after write failures for crash recovery

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  add_feature_to_backlog "feat-001" "Test Feature" "planned" 1
}

teardown() {
  teardown_vibecrew_dir
}

@test "journal finalized only on success path in claim-task" {
  SCRIPT="$SCRIPTS_DIR/claim-task.sh"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' test-agent"
  assert_success

  # After successful claim, journal should be cleaned up
  [ ! -f "$VIBECREW_DIR/locks/dual-write.journal" ]
  [ ! -f "$VIBECREW_DIR/locks/journal-file1.staged" ]
  [ ! -f "$VIBECREW_DIR/locks/journal-file2.staged" ]
}

@test "journal finalized only on success path in complete-phase" {
  SCRIPT="$SCRIPTS_DIR/complete-phase.sh"

  add_feature_to_backlog "feat-002" "Active Feature" "in-progress" 1
  set_active_feature "feat-002" "Active Feature" "plan"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' feat-002 plan"
  assert_success

  # After successful completion, journal should be cleaned up
  [ ! -f "$VIBECREW_DIR/locks/dual-write.journal" ]
  [ ! -f "$VIBECREW_DIR/locks/journal-file1.staged" ]
  [ ! -f "$VIBECREW_DIR/locks/journal-file2.staged" ]
}

@test "claim-task error path does not call finalize_dual_write" {
  # Verify the source code does not have finalize_dual_write on error paths
  SCRIPT="$SCRIPTS_DIR/claim-task.sh"

  # Extract error path blocks (between "ERROR:" and "exit 1") — must not contain finalize_dual_write
  # The error paths for atomic_write failures should NOT finalize the journal
  run grep -A3 'ERROR: Failed to write' "$SCRIPT"
  assert_success
  refute_output --partial "finalize_dual_write"
}

@test "complete-phase error path does not call finalize_dual_write" {
  SCRIPT="$SCRIPTS_DIR/complete-phase.sh"

  run grep -A3 'ERROR: Failed to write' "$SCRIPT"
  assert_success
  refute_output --partial "finalize_dual_write"
}

@test "claim-task success path calls finalize_dual_write" {
  SCRIPT="$SCRIPTS_DIR/claim-task.sh"

  # The success path (after both writes) should still finalize
  run grep -B1 'Both writes succeeded' "$SCRIPT"
  assert_success

  run grep -A1 'Both writes succeeded' "$SCRIPT"
  assert_output --partial "finalize_dual_write"
}

@test "complete-phase success path calls finalize_dual_write" {
  SCRIPT="$SCRIPTS_DIR/complete-phase.sh"

  run grep -A1 'Both writes succeeded' "$SCRIPT"
  assert_success
  assert_output --partial "finalize_dual_write"
}

@test "recover_dual_write replays journal contents" {
  # Manually create a journal + staged files, then verify recovery works
  source "$SCRIPTS_DIR/lib/dual-write.sh"
  source "$SCRIPTS_DIR/lib/atomic-write.sh"

  # Create test journal
  local test_state='{"test":"recovered_state"}'
  local test_backlog='{"test":"recovered_backlog"}'
  local state_target="$VIBECREW_DIR/state.json"
  local backlog_target="$VIBECREW_DIR/backlog.json"

  prepare_dual_write "$VIBECREW_DIR" "$state_target" "$test_state" "$backlog_target" "$test_backlog"

  # Journal should exist
  [ -f "$VIBECREW_DIR/locks/dual-write.journal" ]

  # Run recovery
  recover_dual_write "$VIBECREW_DIR"

  # Journal should be cleaned up
  [ ! -f "$VIBECREW_DIR/locks/dual-write.journal" ]

  # Files should have recovered content
  run jq -r '.test' "$state_target"
  assert_output "recovered_state"

  run jq -r '.test' "$backlog_target"
  assert_output "recovered_backlog"
}
