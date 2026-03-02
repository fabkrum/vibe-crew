#!/usr/bin/env bats
# tests/run-a11y-scan.bats
# Tests for scripts/run-a11y-scan.sh — axe-core accessibility scanning

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
}

@test "creates report directory" {
  cd "$TEST_PROJECT_DIR"
  # Mock npx to fail (axe not available)
  mock_command "npx" 1 ""

  run bash "$SCRIPTS_DIR/run-a11y-scan.sh" "http://localhost:3000" "$TEST_PROJECT_DIR"
  assert_success
  [[ -d "$VIBECREW_DIR/a11y" ]]
}

@test "npx not available: returns error JSON" {
  cd "$TEST_PROJECT_DIR"
  mock_command "npx" 1 ""

  run bash "$SCRIPTS_DIR/run-a11y-scan.sh" "http://localhost:3000" "$TEST_PROJECT_DIR"
  assert_success

  local err
  err=$(echo "$output" | jq -r '.error')
  [[ -n "$err" ]]

  local completed
  completed=$(echo "$output" | jq '.scan_completed')
  [[ "$completed" == "false" ]]
}

@test "output is valid JSON when tool missing" {
  cd "$TEST_PROJECT_DIR"
  mock_command "npx" 1 ""

  run bash "$SCRIPTS_DIR/run-a11y-scan.sh" "http://localhost:3000" "$TEST_PROJECT_DIR"
  assert_success
  echo "$output" | jq empty
}

@test "always exits 0" {
  cd "$TEST_PROJECT_DIR"
  mock_command "npx" 1 ""

  run bash "$SCRIPTS_DIR/run-a11y-scan.sh" "http://localhost:3000" "$TEST_PROJECT_DIR"
  assert_success
}

@test "default URL is localhost:3000" {
  cd "$TEST_PROJECT_DIR"
  mock_command "npx" 1 ""

  # Run without explicit URL — should not crash
  run bash "$SCRIPTS_DIR/run-a11y-scan.sh"
  assert_success
}
