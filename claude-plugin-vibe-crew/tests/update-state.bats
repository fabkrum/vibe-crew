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
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '.foundation.complete = true'"
  assert_success
  run jq -r '.foundation.complete' "$VIBECREW_DIR/state.json"
  assert_output "true"
}

@test "blocks | env pattern" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '.foo | env'"
  assert_failure
  assert_output --partial "disallowed builtin via pipe"
}

@test "blocks = env pattern" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '.foo = env'"
  assert_failure
  assert_output --partial "disallowed builtin via assignment"
}

@test "blocks | debug pattern" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '.foo | debug'"
  assert_failure
  assert_output --partial "disallowed builtin via pipe"
}

@test "blocks | halt pattern" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '.foo | halt'"
  assert_failure
  assert_output --partial "disallowed builtin via pipe"
}

@test "blocks | halt_error pattern" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '.foo | halt_error'"
  assert_failure
  assert_output --partial "disallowed builtin via pipe"
}

@test "blocks function calls with parens" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '.foo = env()'"
  assert_failure
  assert_output --partial "disallowed function calls"
}

@test "blocks expressions not starting with dot-path" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' 'env'"
  assert_failure
  assert_output --partial "must start with a dot-path"
}

@test "dry-run mode works without modification" {
  local before
  before=$(cat "$VIBECREW_DIR/state.json")
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' --dry-run '.foundation.complete = true'"
  assert_success
  assert_output --partial "DRY RUN"
  local after
  after=$(cat "$VIBECREW_DIR/state.json")
  [ "$before" = "$after" ]
}
