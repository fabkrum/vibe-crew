#!/usr/bin/env bats
# tests/refresh-pricing.bats
# Tests for scripts/refresh-pricing.sh — pricing config updater

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
}

@test "config.json not found: exits 1" {
  cd "$TEST_PROJECT_DIR"
  rm -f "$VIBECREW_DIR/config.json"

  run bash "$SCRIPTS_DIR/refresh-pricing.sh"
  assert_failure
}

@test "updates pricing in config.json" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/refresh-pricing.sh"
  assert_success

  local opus_input
  opus_input=$(jq '.pricing.opus.input' "$VIBECREW_DIR/config.json")
  [[ "$opus_input" != "null" ]]
}

@test "pricing has all three models" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/refresh-pricing.sh"
  assert_success

  jq -e '.pricing.opus' "$VIBECREW_DIR/config.json" >/dev/null
  jq -e '.pricing.sonnet' "$VIBECREW_DIR/config.json" >/dev/null
  jq -e '.pricing.haiku' "$VIBECREW_DIR/config.json" >/dev/null
}

@test "pricing has last_updated field" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/refresh-pricing.sh"
  assert_success

  local last_updated
  last_updated=$(jq -r '.pricing.last_updated' "$VIBECREW_DIR/config.json")
  [[ "$last_updated" != "null" ]]
  [[ -n "$last_updated" ]]
}

@test "exits 0 on success" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/refresh-pricing.sh"
  assert_success
}
