#!/usr/bin/env bats
# tests/start-dashboard.bats
# Tests for scripts/start-dashboard.sh — dashboard launcher error cases

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
}

@test "no docs/package.json: exits 1" {
  cd "$TEST_PROJECT_DIR"
  # Ensure no docs directory exists
  rm -rf "$TEST_PROJECT_DIR/docs"

  run bash "$SCRIPTS_DIR/start-dashboard.sh"
  assert_failure
}

@test "exits 1 with error message" {
  cd "$TEST_PROJECT_DIR"
  rm -rf "$TEST_PROJECT_DIR/docs"

  run bash "$SCRIPTS_DIR/start-dashboard.sh"
  assert_failure
  [[ "$output" == *"docs/ not found"* ]]
}
