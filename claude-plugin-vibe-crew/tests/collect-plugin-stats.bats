#!/usr/bin/env bats
# tests/collect-plugin-stats.bats
# Tests for scripts/collect-plugin-stats.sh — plugin statistics

setup() {
  load 'test_helper/common-setup'
}

@test "counts agents" {
  run bash "$SCRIPTS_DIR/collect-plugin-stats.sh"
  assert_success

  local count
  count=$(echo "$output" | jq '.agents')
  [[ "$count" -ge 1 ]]
}

@test "counts scripts" {
  run bash "$SCRIPTS_DIR/collect-plugin-stats.sh"
  assert_success

  local count
  count=$(echo "$output" | jq '.scripts')
  [[ "$count" -ge 10 ]]
}

@test "counts skills" {
  run bash "$SCRIPTS_DIR/collect-plugin-stats.sh"
  assert_success

  local count
  count=$(echo "$output" | jq '.skills')
  [[ "$count" -ge 1 ]]
}

@test "reads plugin version" {
  run bash "$SCRIPTS_DIR/collect-plugin-stats.sh"
  assert_success

  local ver
  ver=$(echo "$output" | jq -r '.plugin_version')
  [[ "$ver" != "unknown" ]]
  [[ "$ver" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]
}

@test "output is valid JSON" {
  run bash "$SCRIPTS_DIR/collect-plugin-stats.sh"
  assert_success
  echo "$output" | jq empty
}
