#!/usr/bin/env bats
# tests/complete-phase.bats
# Tests for scripts/complete-phase.sh — phase advancement

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  set_foundation_complete
  SCRIPT="$SCRIPTS_DIR/complete-phase.sh"
}

teardown() {
  teardown_vibecrew_dir
}

run_complete() {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' $*"
}

# =============================================================================
# Foundation mode
# =============================================================================

@test "foundation: marks foundation complete" {
  # Start with incomplete foundation
  jq '.foundation.complete = false' "$VIBECREW_DIR/state.json" > "$VIBECREW_DIR/state.json.tmp" \
    && mv "$VIBECREW_DIR/state.json.tmp" "$VIBECREW_DIR/state.json"

  run_complete "foundation"
  assert_success
  assert_output --partial "Foundation marked complete"

  local complete
  complete=$(jq -r '.foundation.complete' "$VIBECREW_DIR/state.json")
  [ "$complete" = "true" ]
}

# =============================================================================
# Feature phase completion
# =============================================================================

@test "completes plan phase: advances to design" {
  add_feature_to_backlog "feat-001" "Test Feature" "in-progress"
  set_active_feature "feat-001" "Test Feature" "plan"

  run_complete "feat-001" "plan"
  assert_success
  assert_output --partial "completed plan"

  # Verify state advanced
  local phase
  phase=$(jq -r '.active_feature.phase' "$VIBECREW_DIR/state.json")
  [ "$phase" = "design" ]

  # Verify backlog column
  local column
  column=$(jq -r '.features[0].column' "$VIBECREW_DIR/backlog.json")
  [ "$column" = "planned" ]
}

@test "completes code phase: moves to testing" {
  add_feature_to_backlog "feat-001" "Test Feature" "in-progress"
  set_active_feature "feat-001" "Test Feature" "code"

  run_complete "feat-001" "code"
  assert_success

  local column
  column=$(jq -r '.features[0].column' "$VIBECREW_DIR/backlog.json")
  [ "$column" = "testing" ]
}

@test "completes test phase: moves to review" {
  add_feature_to_backlog "feat-001" "Test Feature" "testing"
  set_active_feature "feat-001" "Test Feature" "test"

  run_complete "feat-001" "test"
  assert_success

  local column
  column=$(jq -r '.features[0].column' "$VIBECREW_DIR/backlog.json")
  [ "$column" = "review" ]
}

@test "completes docs phase: moves to review" {
  add_feature_to_backlog "feat-001" "Test Feature" "review"
  set_active_feature "feat-001" "Test Feature" "docs"

  run_complete "feat-001" "docs"
  assert_success

  local phase
  phase=$(jq -r '.active_feature.phase' "$VIBECREW_DIR/state.json")
  [ "$phase" = "done" ]
}

@test "phase added to phases_completed array" {
  add_feature_to_backlog "feat-001" "Test Feature" "in-progress"
  set_active_feature "feat-001" "Test Feature" "plan"

  run_complete "feat-001" "plan"
  assert_success

  # Verify phase was added to state
  local has_plan
  has_plan=$(jq '.active_feature.phases_completed | index("plan") != null' "$VIBECREW_DIR/state.json")
  [ "$has_plan" = "true" ]

  # Verify phase was added to backlog
  has_plan=$(jq '.features[0].phases_completed | index("plan") != null' "$VIBECREW_DIR/backlog.json")
  [ "$has_plan" = "true" ]
}

@test "idempotent: same phase twice doesn't duplicate" {
  add_feature_to_backlog "feat-001" "Test Feature" "in-progress"
  set_active_feature "feat-001" "Test Feature" "plan"

  run_complete "feat-001" "plan"
  assert_success
  run_complete "feat-001" "plan"
  assert_success

  local count
  count=$(jq '[.features[0].phases_completed[] | select(. == "plan")] | length' "$VIBECREW_DIR/backlog.json")
  [ "$count" = "1" ]
}

# =============================================================================
# Error cases
# =============================================================================

@test "invalid phase name: fails" {
  run_complete "feat-001" "invalid"
  assert_failure
  assert_output --partial "Invalid phase"
}

@test "feature not found: fails" {
  run_complete "feat-999" "plan"
  assert_failure
  assert_output --partial "not found"
}

@test "no arguments: shows usage" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_failure
  assert_output --partial "Usage"
}

@test "missing .vibecrew: fails" {
  rm -rf "$VIBECREW_DIR"
  run_complete "feat-001" "plan"
  assert_failure
  assert_output --partial "not found"
}
