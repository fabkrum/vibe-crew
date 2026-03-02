#!/usr/bin/env bats
# tests/update-backlog.bats
# Tests for scripts/update-backlog.sh — validated backlog field updates

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir

  # Add a test feature to backlog
  add_feature_to_backlog "feat-001" "Test Feature" "planned" 1
}

teardown() {
  teardown_vibecrew_dir
}

@test "updates column to valid value" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/update-backlog.sh" "feat-001" "column" "testing"
  assert_success
  assert_output --partial "Updated feat-001.column"
  run jq -r '.features[0].column' "$VIBECREW_DIR/backlog.json"
  assert_output "testing"
}

@test "rejects invalid column value" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/update-backlog.sh" "feat-001" "column" "invalid-col"
  assert_failure
  assert_output --partial "Invalid column"
}

@test "updates priority with valid positive integer" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/update-backlog.sh" "feat-001" "priority" "5"
  assert_success
  run jq -r '.features[0].priority' "$VIBECREW_DIR/backlog.json"
  assert_output "5"
}

@test "rejects zero priority" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/update-backlog.sh" "feat-001" "priority" "0"
  assert_failure
  assert_output --partial "positive integer"
}

@test "rejects non-integer priority" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/update-backlog.sh" "feat-001" "priority" "abc"
  assert_failure
  assert_output --partial "positive integer"
}

@test "rejects disallowed field path" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/update-backlog.sh" "feat-001" "secret_key" "value"
  assert_failure
  assert_output --partial "Invalid field"
}

@test "updates nested spec field" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/update-backlog.sh" "feat-001" "spec.acceptance_criteria" '["Login with email","OAuth support"]'
  assert_success
  run jq -r '.features[0].spec.acceptance_criteria | length' "$VIBECREW_DIR/backlog.json"
  assert_output "2"
}

@test "rejects nonexistent feature" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/update-backlog.sh" "feat-999" "column" "done"
  assert_failure
  assert_output --partial "not found"
}

@test "sets updated_at on update" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/update-backlog.sh" "feat-001" "column" "done"
  assert_success
  local updated_at
  updated_at=$(jq -r '.features[0].updated_at' "$VIBECREW_DIR/backlog.json")
  # updated_at should be a recent timestamp, not the fixture default
  [[ "$updated_at" != "2026-01-01T00:00:00Z" ]]
}

@test "uses state-files lock (not backlog named lock)" {
  cd "$TEST_PROJECT_DIR"
  # Run update and verify no backlog lock dir is created
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPTS_DIR/update-backlog.sh' 'feat-001' 'column' 'review' 2>&1; [ ! -d '$VIBECREW_DIR/locks/backlog' ] && echo 'backlog-lock-absent'"
  assert_success
  assert_output --partial "backlog-lock-absent"
}

@test "shows usage on insufficient arguments" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/update-backlog.sh" "feat-001" "column"
  assert_failure
  assert_output --partial "Usage"
}
