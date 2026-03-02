#!/usr/bin/env bats
# tests/update-state.bats
# Tests for scripts/update-state.sh — jq expression validation and state updates

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/update-state.sh"
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

@test "allows valid dot-path expression" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '.foundation.artifacts.vision.status = \"complete\"'"
  assert_success
  run jq -r '.foundation.artifacts.vision.status' "$VIBECREW_DIR/state.json"
  assert_output "complete"
}

@test "blocks | env pattern" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '.foo | env'"
  assert_failure
  assert_output --partial "disallowed builtin reference"
}

@test "blocks = env pattern" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '.foo = env'"
  assert_failure
  assert_output --partial "disallowed builtin reference"
}

@test "blocks | debug pattern" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '.foo | debug'"
  assert_failure
  assert_output --partial "disallowed builtin reference"
}

@test "blocks | halt pattern" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '.foo | halt'"
  assert_failure
  assert_output --partial "disallowed builtin reference"
}

@test "blocks | halt_error pattern" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '.foo | halt_error'"
  assert_failure
  assert_output --partial "disallowed builtin reference"
}

@test "blocks function calls with parens" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '.foo = env()'"
  assert_failure
  assert_output --partial "disallowed builtin reference"
}

# --- Bypass attempts (Fix #3) ---

@test "blocks subexpression bypass: .foo = (.bar // env.SECRET)" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '.foo = (.bar // env.SECRET)'"
  assert_failure
  assert_output --partial "disallowed builtin reference"
}

@test "blocks parenthesized env: .foo = (env)" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '.foo = (env)'"
  assert_failure
  assert_output --partial "disallowed builtin reference"
}

@test "blocks \$ENV reference" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '.foo = \$ENV.SECRET'"
  assert_failure
  assert_output --partial "disallowed ENV reference"
}

@test "blocks .ENV reference" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '.foo = .ENV.PATH'"
  assert_failure
  assert_output --partial "disallowed ENV reference"
}

@test "blocks expressions not starting with dot-path" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' 'keys'"
  assert_failure
  assert_output --partial "must start with a dot-path"
}

@test "dry-run mode works without modification" {
  local before
  before=$(cat "$VIBECREW_DIR/state.json")
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' --dry-run '.foundation.artifacts.vision.status = \"complete\"'"
  assert_success
  assert_output --partial "DRY RUN"
  local after
  after=$(cat "$VIBECREW_DIR/state.json")
  [ "$before" = "$after" ]
}

# =============================================================================
# Semantic validation: foundation completion
# =============================================================================

@test "semantic: blocks foundation.complete = true when artifacts are pending" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '.foundation.complete = true'"
  assert_failure
  assert_output --partial "Cannot set foundation.complete = true"
  assert_output --partial "incomplete artifacts"
}

@test "semantic: allows foundation.complete = true when all artifacts complete" {
  set_foundation_complete
  # Reset complete flag to false so we can set it via update-state
  local tmp="$VIBECREW_DIR/state.json.tmp"
  jq '.foundation.complete = false' "$VIBECREW_DIR/state.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/state.json"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '.foundation.complete = true'"
  assert_success
}

@test "semantic: allows foundation.complete = true when artifacts are complete or skipped" {
  set_foundation_complete
  local tmp="$VIBECREW_DIR/state.json.tmp"
  jq '.foundation.complete = false | .foundation.artifacts.vision.status = "skipped"' \
    "$VIBECREW_DIR/state.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/state.json"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '.foundation.complete = true'"
  assert_success
}

@test "semantic: blocks foundation.complete when one artifact incomplete" {
  set_foundation_complete
  local tmp="$VIBECREW_DIR/state.json.tmp"
  jq '.foundation.complete = false | .foundation.artifacts.tdr.status = "in_progress"' \
    "$VIBECREW_DIR/state.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/state.json"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '.foundation.complete = true'"
  assert_failure
  assert_output --partial "tdr"
}

# =============================================================================
# Semantic validation: phase ordering
# =============================================================================

@test "semantic: allows legal next phase transition (plan -> design)" {
  set_active_feature "feat-001" "Test Feature" "plan"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '.active_feature.phase = \"design\"'"
  assert_success
}

@test "semantic: blocks illegal phase transition (plan -> code)" {
  set_active_feature "feat-001" "Test Feature" "plan"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '.active_feature.phase = \"code\"'"
  assert_failure
  assert_output --partial "legal next phase is 'design'"
}

@test "semantic: allows plan as reset for new features" {
  set_active_feature "feat-001" "Test Feature" "code"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '.active_feature.phase = \"plan\"'"
  assert_success
}

@test "semantic: allows phase set when current phase is null" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '.active_feature.phase = \"code\"'"
  assert_success
}
