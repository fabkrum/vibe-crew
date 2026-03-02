#!/usr/bin/env bats
# tests/dual-write.bats
# Tests for scripts/lib/dual-write.sh — write-ahead journal for dual-file atomicity

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir

  # Source the libraries under test
  source "$SCRIPTS_DIR/lib/atomic-write.sh"
  source "$SCRIPTS_DIR/lib/dual-write.sh"
}

teardown() {
  teardown_vibecrew_dir
}

# =============================================================================
# prepare_dual_write
# =============================================================================

@test "prepare creates journal and staged files" {
  local file1="$VIBECREW_DIR/backlog.json"
  local file2="$VIBECREW_DIR/state.json"
  local content1='{"features":[],"updated":true}'
  local content2='{"active_feature":null,"updated":true}'

  prepare_dual_write "$VIBECREW_DIR" "$file1" "$content1" "$file2" "$content2"

  # Journal exists and is valid JSON
  [ -f "$VIBECREW_DIR/locks/dual-write.journal" ]
  jq empty "$VIBECREW_DIR/locks/dual-write.journal"

  # Staged files exist
  [ -f "$VIBECREW_DIR/locks/journal-file1.staged" ]
  [ -f "$VIBECREW_DIR/locks/journal-file2.staged" ]

  # Journal records correct target paths
  local j_file1 j_file2
  j_file1=$(jq -r '.file1' "$VIBECREW_DIR/locks/dual-write.journal")
  j_file2=$(jq -r '.file2' "$VIBECREW_DIR/locks/dual-write.journal")
  [ "$j_file1" = "$file1" ]
  [ "$j_file2" = "$file2" ]

  # Staged content matches
  local staged1 staged2
  staged1=$(cat "$VIBECREW_DIR/locks/journal-file1.staged")
  staged2=$(cat "$VIBECREW_DIR/locks/journal-file2.staged")
  [ "$staged1" = "$content1" ]
  [ "$staged2" = "$content2" ]
}

# =============================================================================
# finalize_dual_write
# =============================================================================

@test "finalize removes journal and staged files" {
  prepare_dual_write "$VIBECREW_DIR" \
    "$VIBECREW_DIR/backlog.json" '{"a":1}' \
    "$VIBECREW_DIR/state.json" '{"b":2}'

  # Files exist before finalize
  [ -f "$VIBECREW_DIR/locks/dual-write.journal" ]

  finalize_dual_write "$VIBECREW_DIR"

  # All cleaned up
  [ ! -f "$VIBECREW_DIR/locks/dual-write.journal" ]
  [ ! -f "$VIBECREW_DIR/locks/journal-file1.staged" ]
  [ ! -f "$VIBECREW_DIR/locks/journal-file2.staged" ]
}

@test "finalize is safe when no journal exists" {
  finalize_dual_write "$VIBECREW_DIR"
  # Should not error
}

# =============================================================================
# recover_dual_write
# =============================================================================

@test "recover replays both writes from journal" {
  local file1="$VIBECREW_DIR/backlog.json"
  local file2="$VIBECREW_DIR/state.json"
  local new_backlog='{"features":[{"id":"feat-001"}]}'
  local new_state='{"active_feature":{"id":"feat-001","phase":"design"}}'

  # Prepare journal (simulates interrupted write)
  prepare_dual_write "$VIBECREW_DIR" "$file1" "$new_backlog" "$file2" "$new_state"

  # Simulate: first file was written, second was not (interrupted)
  echo "$new_backlog" > "$file1"
  # state.json still has old content from setup

  # Recover
  run recover_dual_write "$VIBECREW_DIR"
  assert_success

  # Both files now have the intended content
  local actual_backlog actual_state
  actual_backlog=$(cat "$file1")
  actual_state=$(cat "$file2")
  [ "$actual_backlog" = "$new_backlog" ]
  [ "$actual_state" = "$new_state" ]

  # Journal cleaned up
  [ ! -f "$VIBECREW_DIR/locks/dual-write.journal" ]
  [ ! -f "$VIBECREW_DIR/locks/journal-file1.staged" ]
  [ ! -f "$VIBECREW_DIR/locks/journal-file2.staged" ]
}

@test "recover returns 1 when no journal exists" {
  run recover_dual_write "$VIBECREW_DIR"
  assert_failure
}

@test "recover cleans up corrupt journal" {
  echo "not json" > "$VIBECREW_DIR/locks/dual-write.journal"
  run recover_dual_write "$VIBECREW_DIR"
  assert_failure
  [ ! -f "$VIBECREW_DIR/locks/dual-write.journal" ]
}

@test "recover cleans up when staged files are missing" {
  # Create journal but no staged files
  mkdir -p "$VIBECREW_DIR/locks"
  jq -n '{file1: "/tmp/a", file2: "/tmp/b"}' > "$VIBECREW_DIR/locks/dual-write.journal"

  run recover_dual_write "$VIBECREW_DIR"
  assert_failure
  [ ! -f "$VIBECREW_DIR/locks/dual-write.journal" ]
}

@test "recover cleans up when staged content is invalid JSON" {
  mkdir -p "$VIBECREW_DIR/locks"
  jq -n --arg f1 "$VIBECREW_DIR/backlog.json" --arg f2 "$VIBECREW_DIR/state.json" \
    '{file1: $f1, file2: $f2}' > "$VIBECREW_DIR/locks/dual-write.journal"
  echo "not json" > "$VIBECREW_DIR/locks/journal-file1.staged"
  echo '{"valid":true}' > "$VIBECREW_DIR/locks/journal-file2.staged"

  run recover_dual_write "$VIBECREW_DIR"
  assert_failure
  [ ! -f "$VIBECREW_DIR/locks/dual-write.journal" ]
}

# =============================================================================
# End-to-end: simulate interrupted complete-phase
# =============================================================================

# =============================================================================
# Fix 2: recover propagates write failures
# =============================================================================

@test "recover returns non-zero when atomic_write fails" {
  [[ "$(id -u)" -eq 0 ]] && skip "Cannot test permission denial as root"

  local file1="$VIBECREW_DIR/backlog.json"
  local file2="$VIBECREW_DIR/state.json"
  local content1='{"features":[],"recovered":true}'
  local content2='{"active_feature":null,"recovered":true}'

  prepare_dual_write "$VIBECREW_DIR" "$file1" "$content1" "$file2" "$content2"

  # Make file1's parent read-only so atomic_write fails for it
  chmod 555 "$VIBECREW_DIR"
  run recover_dual_write "$VIBECREW_DIR"
  chmod 755 "$VIBECREW_DIR"
  assert_failure
  assert_output --partial "Dual-write recovery completed with errors"
}

@test "recover writes file2 even when file1 fails" {
  [[ "$(id -u)" -eq 0 ]] && skip "Cannot test permission denial as root"

  # Create a scenario where file1 is in a read-only dir but file2 is writable
  local readonly_dir="$VIBECREW_DIR/readonly_sub"
  mkdir -p "$readonly_dir"
  local file1="$readonly_dir/file1.json"
  local file2="$VIBECREW_DIR/file2.json"
  echo '{"old":true}' > "$file1"
  echo '{"old":true}' > "$file2"

  local content1='{"new1":true}'
  local content2='{"new2":true}'

  prepare_dual_write "$VIBECREW_DIR" "$file1" "$content1" "$file2" "$content2"

  # Make file1's directory read-only
  chmod 555 "$readonly_dir"
  run recover_dual_write "$VIBECREW_DIR"
  chmod 755 "$readonly_dir"
  assert_failure

  # file2 should have been written successfully despite file1 failure
  run jq -r '.new2' "$file2"
  assert_output "true"
}

# =============================================================================
# End-to-end: simulate interrupted complete-phase
# =============================================================================

@test "e2e: sync-state recovers interrupted phase completion" {
  # Setup: feature in-progress, phase=code
  add_feature_to_backlog "feat-001" "Test Feature" "in-progress"
  set_active_feature "feat-001" "Test Feature" "code"

  # Simulate what complete-phase.sh would do:
  # 1. Prepare journal with intended new states
  local new_backlog new_state
  new_backlog=$(jq '.features[0].column = "testing" | .features[0].phases_completed = ["plan","design","code"]' \
    "$VIBECREW_DIR/backlog.json")
  new_state=$(jq '.active_feature.phase = "test" | .active_feature.phases_completed = ["plan","design","code"]' \
    "$VIBECREW_DIR/state.json")

  prepare_dual_write "$VIBECREW_DIR" \
    "$VIBECREW_DIR/backlog.json" "$new_backlog" \
    "$VIBECREW_DIR/state.json" "$new_state"

  # 2. Simulate: backlog written successfully
  echo "$new_backlog" > "$VIBECREW_DIR/backlog.json"

  # 3. Simulate: process killed before state write
  #    (state.json still says phase=code)

  # 4. Verify inconsistent state
  local phase_before column_before
  phase_before=$(jq -r '.active_feature.phase' "$VIBECREW_DIR/state.json")
  column_before=$(jq -r '.features[0].column' "$VIBECREW_DIR/backlog.json")
  [ "$phase_before" = "code" ]
  [ "$column_before" = "testing" ]

  # 5. Run sync-state.sh (which should recover from journal)
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPTS_DIR/sync-state.sh'"
  assert_success
  assert_output --partial "Recovered interrupted dual write"

  # 6. Verify both files are now consistent with intended values
  local phase_after column_after
  phase_after=$(jq -r '.active_feature.phase' "$VIBECREW_DIR/state.json")
  column_after=$(jq -r '.features[0].column' "$VIBECREW_DIR/backlog.json")
  [ "$phase_after" = "test" ]
  [ "$column_after" = "testing" ]
}
