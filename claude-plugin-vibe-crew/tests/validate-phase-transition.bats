#!/usr/bin/env bats
# tests/validate-phase-transition.bats
# Tests for scripts/validate-phase-transition.sh — phase transition validation hook

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/validate-phase-transition.sh"
  setup_vibecrew_dir
  set_foundation_complete
}

teardown() {
  teardown_vibecrew_dir
}

# =============================================================================
# Passthrough tests
# =============================================================================

@test "passthrough: non-Bash tool is allowed" {
  INPUT=$(create_write_hook_input "$TEST_PROJECT_DIR/src/index.ts")
  run bash -c "echo '$INPUT' | bash '$SCRIPT'"
  assert_success
}

@test "passthrough: Bash command not involving complete-phase.sh is allowed" {
  INPUT=$(create_hook_input "Bash" "npm test")
  run bash -c "echo '$INPUT' | bash '$SCRIPT'"
  assert_success
}

@test "passthrough: empty command is allowed" {
  INPUT=$(create_hook_input "Bash" "")
  run bash -c "echo '$INPUT' | bash '$SCRIPT'"
  assert_success
}

# =============================================================================
# Foundation mode
# =============================================================================

@test "foundation: allows when all artifacts complete" {
  INPUT=$(create_hook_input "Bash" "bash scripts/complete-phase.sh foundation")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$INPUT' | bash '$SCRIPT'"
  assert_success
}

@test "foundation: blocks when artifacts are incomplete" {
  # Reset one artifact to pending
  local tmp="$VIBECREW_DIR/state.json.tmp"
  jq '.foundation.artifacts.vision.status = "pending"' "$VIBECREW_DIR/state.json" > "$tmp" \
    && mv "$tmp" "$VIBECREW_DIR/state.json"

  INPUT=$(create_hook_input "Bash" "bash scripts/complete-phase.sh foundation")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$INPUT' | bash '$SCRIPT'"
  assert_failure
  assert_output --partial "not complete or skipped"
  assert_output --partial "vision"
}

@test "foundation: allows when artifacts are skipped" {
  local tmp="$VIBECREW_DIR/state.json.tmp"
  jq '.foundation.artifacts.vision.status = "skipped"' "$VIBECREW_DIR/state.json" > "$tmp" \
    && mv "$tmp" "$VIBECREW_DIR/state.json"

  INPUT=$(create_hook_input "Bash" "bash scripts/complete-phase.sh foundation")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$INPUT' | bash '$SCRIPT'"
  assert_success
}

@test "foundation: blocks when multiple artifacts incomplete" {
  local tmp="$VIBECREW_DIR/state.json.tmp"
  jq '.foundation.artifacts.vision.status = "pending" | .foundation.artifacts.tdr.status = "pending"' \
    "$VIBECREW_DIR/state.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/state.json"

  INPUT=$(create_hook_input "Bash" "bash scripts/complete-phase.sh foundation")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$INPUT' | bash '$SCRIPT'"
  assert_failure
  assert_output --partial "vision"
  assert_output --partial "tdr"
}

# =============================================================================
# Feature mode: valid transitions
# =============================================================================

@test "feature: allows completing active phase" {
  set_active_feature "feat-001" "Test Feature" "plan"

  INPUT=$(create_hook_input "Bash" "bash scripts/complete-phase.sh feat-001 plan")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$INPUT' | bash '$SCRIPT'"
  assert_success
}

@test "feature: allows completing code phase when active" {
  set_active_feature "feat-001" "Test Feature" "code"

  INPUT=$(create_hook_input "Bash" "bash scripts/complete-phase.sh feat-001 code")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$INPUT' | bash '$SCRIPT'"
  assert_success
}

# =============================================================================
# Feature mode: invalid transitions
# =============================================================================

@test "feature: blocks completing wrong phase" {
  set_active_feature "feat-001" "Test Feature" "plan"

  INPUT=$(create_hook_input "Bash" "bash scripts/complete-phase.sh feat-001 code")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$INPUT' | bash '$SCRIPT'"
  assert_failure
  assert_output --partial "active feature is in phase"
}

@test "feature: blocks already-completed phase" {
  set_active_feature "feat-001" "Test Feature" "code"
  set_phases_completed "plan" "design" "code"

  INPUT=$(create_hook_input "Bash" "bash scripts/complete-phase.sh feat-001 code")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$INPUT' | bash '$SCRIPT'"
  assert_failure
  assert_output --partial "already been completed"
}

@test "feature: blocks completing design when active is plan" {
  set_active_feature "feat-001" "Test Feature" "plan"

  INPUT=$(create_hook_input "Bash" "bash scripts/complete-phase.sh feat-001 design")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$INPUT' | bash '$SCRIPT'"
  assert_failure
  assert_output --partial "active feature is in phase 'plan'"
}

# =============================================================================
# Edge cases
# =============================================================================

@test "missing state.json: allows (delegates to complete-phase.sh)" {
  rm -f "$VIBECREW_DIR/state.json"

  INPUT=$(create_hook_input "Bash" "bash scripts/complete-phase.sh feat-001 plan")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$INPUT' | bash '$SCRIPT'"
  assert_success
}

@test "feature: allows when active_feature.phase is null" {
  local tmp="$VIBECREW_DIR/state.json.tmp"
  jq '.active_feature.phase = null' "$VIBECREW_DIR/state.json" > "$tmp" \
    && mv "$tmp" "$VIBECREW_DIR/state.json"

  INPUT=$(create_hook_input "Bash" "bash scripts/complete-phase.sh feat-001 plan")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$INPUT' | bash '$SCRIPT'"
  assert_success
}

@test "feature: handles path with directory prefix" {
  set_active_feature "feat-001" "Test Feature" "plan"

  INPUT=$(create_hook_input "Bash" "bash /path/to/scripts/complete-phase.sh feat-001 plan")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$INPUT' | bash '$SCRIPT'"
  assert_success
}
