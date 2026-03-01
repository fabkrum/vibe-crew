#!/usr/bin/env bats
# tests/claim-task.bats
# Tests for scripts/claim-task.sh — atomic feature claiming

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  set_foundation_complete
  SCRIPT="$SCRIPTS_DIR/claim-task.sh"
}

teardown() {
  teardown_vibecrew_dir
}

run_claim() {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' $*"
}

# =============================================================================
# Successful claim
# =============================================================================

@test "claims highest-priority planned feature" {
  add_feature_to_backlog "feat-001" "Low Priority" "planned" 2
  add_feature_to_backlog "feat-002" "High Priority" "planned" 1
  run_claim "builder"
  assert_success
  assert_output --partial "feat-002"
  assert_output --partial "High Priority"

  # Verify backlog column updated
  local column
  column=$(jq -r '.features[] | select(.id == "feat-002") | .column' "$VIBECREW_DIR/backlog.json")
  [ "$column" = "in-progress" ]

  # Verify state updated
  local active_id
  active_id=$(jq -r '.active_feature.id' "$VIBECREW_DIR/state.json")
  [ "$active_id" = "feat-002" ]
}

@test "claims specific feature by ID" {
  add_feature_to_backlog "feat-001" "Feature One" "planned" 1
  add_feature_to_backlog "feat-002" "Feature Two" "planned" 2
  run_claim "builder" "feat-002"
  assert_success
  assert_output --partial "feat-002"
}

# =============================================================================
# No features available
# =============================================================================

@test "no planned features: exits cleanly" {
  run_claim "builder"
  assert_success
  assert_output --partial "No planned features"
}

@test "all features in progress: exits with WIP limit" {
  add_feature_to_backlog "feat-001" "In Progress" "in-progress"
  add_feature_to_backlog "feat-002" "Planned" "planned"
  run_claim "builder"
  assert_failure
  assert_output --partial "WIP limit"
}

# =============================================================================
# Dependency checking
# =============================================================================

@test "skips features with unmet dependencies" {
  add_feature_to_backlog "feat-001" "Base Feature" "planned" 1
  add_feature_to_backlog "feat-002" "Dependent Feature" "planned" 1 '["feat-001"]'
  run_claim "builder"
  assert_success
  # Should claim feat-001, not feat-002
  assert_output --partial "feat-001"
}

@test "claims feature when all dependencies done" {
  add_feature_to_backlog "feat-001" "Done Feature" "done" 1
  add_feature_to_backlog "feat-002" "Ready Feature" "planned" 1 '["feat-001"]'
  run_claim "builder"
  assert_success
  assert_output --partial "feat-002"
}

@test "blocks explicit claim with unmet dependencies" {
  add_feature_to_backlog "feat-001" "Not Done" "planned" 1
  add_feature_to_backlog "feat-002" "Depends" "planned" 1 '["feat-001"]'
  run_claim "builder" "feat-002"
  assert_failure
  assert_output --partial "Dependency"
}

# =============================================================================
# Error cases
# =============================================================================

@test "missing .vibecrew directory: fails" {
  rm -rf "$VIBECREW_DIR"
  run_claim "builder"
  assert_failure
  assert_output --partial "not found"
}

@test "no agent name: fails" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_failure
  assert_output --partial "Usage"
}

@test "feature not found: fails" {
  run_claim "builder" "feat-999"
  assert_failure
  assert_output --partial "not found"
}

@test "feature not in planned column: fails" {
  add_feature_to_backlog "feat-001" "In Progress" "in-progress"
  run_claim "builder" "feat-001"
  assert_failure
  assert_output --partial "not 'planned'"
}

# =============================================================================
# Rollback on partial failure
# =============================================================================

@test "dual file write: both files updated" {
  add_feature_to_backlog "feat-001" "Test Feature" "planned"
  run_claim "builder"
  assert_success

  # Both files should be consistent
  local backlog_col state_id
  backlog_col=$(jq -r '.features[0].column' "$VIBECREW_DIR/backlog.json")
  state_id=$(jq -r '.active_feature.id' "$VIBECREW_DIR/state.json")
  [ "$backlog_col" = "in-progress" ]
  [ "$state_id" = "feat-001" ]
}
