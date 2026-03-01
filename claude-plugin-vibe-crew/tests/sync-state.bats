#!/usr/bin/env bats
# tests/sync-state.bats
# Tests for scripts/sync-state.sh — state reconciliation

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  SCRIPT="$SCRIPTS_DIR/sync-state.sh"
}

teardown() {
  teardown_vibecrew_dir
}

run_sync() {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
}

# =============================================================================
# Happy path
# =============================================================================

@test "consistent state: reports no issues" {
  run_sync
  assert_success
  assert_output --partial "consistent"
}

# =============================================================================
# Missing files
# =============================================================================

@test "missing state.json: skips gracefully" {
  rm "$VIBECREW_DIR/state.json"
  run_sync
  assert_success
  assert_output --partial "skipped"
}

@test "missing backlog.json: skips gracefully" {
  rm "$VIBECREW_DIR/backlog.json"
  run_sync
  assert_success
  assert_output --partial "skipped"
}

# =============================================================================
# Check 1: Orphaned active feature
# =============================================================================

@test "orphaned active feature: clears from state" {
  set_active_feature "feat-999" "Ghost Feature" "code"
  run_sync
  assert_success
  assert_output --partial "Cleared active_feature"

  # Verify state was updated
  local active_id
  active_id=$(jq -r '.active_feature.id' "$VIBECREW_DIR/state.json")
  [ "$active_id" = "null" ]
}

@test "valid active feature: no fix needed" {
  add_feature_to_backlog "feat-001" "Real Feature" "in-progress"
  set_active_feature "feat-001" "Real Feature" "code"
  run_sync
  assert_success
  assert_output --partial "consistent"
}

# =============================================================================
# Check 2: Phase/column mismatch
# =============================================================================

@test "phase/column mismatch: fixes backlog column" {
  add_feature_to_backlog "feat-001" "Test Feature" "planned"
  set_active_feature "feat-001" "Test Feature" "code"
  run_sync
  assert_success
  assert_output --partial "Updated backlog column"

  # Verify backlog column was updated to match phase
  local column
  column=$(jq -r '.features[0].column' "$VIBECREW_DIR/backlog.json")
  [ "$column" = "in-progress" ]
}

# =============================================================================
# Check 3: Orphaned in-progress features
# =============================================================================

@test "orphaned in-progress feature: warns" {
  add_feature_to_backlog "feat-001" "Active Feature" "in-progress"
  add_feature_to_backlog "feat-002" "Orphan Feature" "in-progress"
  set_active_feature "feat-001" "Active Feature" "code"
  run_sync
  assert_success
  assert_output --partial "Orphaned in-progress"
}

# =============================================================================
# Check 4: Foundation consistency
# =============================================================================

@test "foundation marked complete but has incomplete artifacts: fixes" {
  set_foundation_complete
  # Break one artifact
  jq '.foundation.artifacts.vision.status = "pending"' \
    "$VIBECREW_DIR/state.json" > "$VIBECREW_DIR/state.json.tmp" \
    && mv "$VIBECREW_DIR/state.json.tmp" "$VIBECREW_DIR/state.json"

  run_sync
  assert_success
  assert_output --partial "Reset foundation.complete"

  # Verify foundation.complete is now false
  local complete
  complete=$(jq -r '.foundation.complete' "$VIBECREW_DIR/state.json")
  [ "$complete" = "false" ]
}

# =============================================================================
# Schema migration
# =============================================================================

@test "missing architecture_diagrams: adds via migration" {
  # Remove architecture_diagrams from state
  jq 'del(.foundation.artifacts.architecture_diagrams)' \
    "$VIBECREW_DIR/state.json" > "$VIBECREW_DIR/state.json.tmp" \
    && mv "$VIBECREW_DIR/state.json.tmp" "$VIBECREW_DIR/state.json"

  run_sync
  assert_success
  assert_output --partial "Migrated"

  # Verify it was added
  local status
  status=$(jq -r '.foundation.artifacts.architecture_diagrams.status' "$VIBECREW_DIR/state.json")
  [ "$status" = "pending" ]
}

# =============================================================================
# Locking
# =============================================================================

@test "stale lock: recovers and proceeds" {
  # Create a stale lock (old timestamp)
  mkdir -p "$VIBECREW_DIR/locks/state-files"
  cat > "$VIBECREW_DIR/locks/state-files/info.json" <<EOF
{
  "locked_by": "stale-process",
  "pid": 99999,
  "locked_at": "2020-01-01T00:00:00Z",
  "timeout_seconds": 30
}
EOF

  run_sync
  assert_success
  # Should proceed normally despite the stale lock
  assert_output --partial "consistent"
}
