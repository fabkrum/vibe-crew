#!/usr/bin/env bats
# tests/uninstall.bats
# Tests for scripts/uninstall.sh — plugin uninstaller safety checks

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  export SCRIPTS_DIR
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
}

@test "refuses to remove root directory" {
  run env CLAUDE_PLUGIN_ROOT="/" bash "$SCRIPTS_DIR/uninstall.sh"
  assert_failure
}

@test "refuses to remove home directory" {
  run env CLAUDE_PLUGIN_ROOT="$HOME" bash "$SCRIPTS_DIR/uninstall.sh"
  assert_failure
}

@test "aborted when user says no" {
  # Create a directory that looks like a valid plugin
  local fake_plugin="$TEST_PROJECT_DIR/fake-plugin"
  mkdir -p "$fake_plugin/scripts"
  mkdir -p "$fake_plugin/.claude-plugin"

  run bash -c 'echo "N" | CLAUDE_PLUGIN_ROOT="$0" bash "$SCRIPTS_DIR/uninstall.sh"' "$fake_plugin"
  assert_success
  [[ "$output" == *"Aborted"* ]]
}

@test "validates plugin directory exists" {
  local nonexistent="$TEST_PROJECT_DIR/does-not-exist"

  run env CLAUDE_PLUGIN_ROOT="$nonexistent" bash "$SCRIPTS_DIR/uninstall.sh"
  assert_failure
}

@test "validates plugin directory looks correct" {
  # Create an empty directory (no scripts/ or .claude-plugin/)
  local empty_dir="$TEST_PROJECT_DIR/empty-dir"
  mkdir -p "$empty_dir"

  run env CLAUDE_PLUGIN_ROOT="$empty_dir" bash "$SCRIPTS_DIR/uninstall.sh"
  assert_failure
}
