#!/usr/bin/env bats
# tests/read-profile.bats
# Tests for scripts/read-profile.sh — universal profile reader with defaults

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

@test "returns defaults when no profile exists" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/read-profile.sh"
  assert_success

  # Should return valid JSON
  echo "$output" | jq empty

  # interview_completed should be false
  local completed
  completed=$(echo "$output" | jq -r '.interview_completed')
  [[ "$completed" == "false" ]]

  # Default values
  local autonomy
  autonomy=$(echo "$output" | jq -r '.autonomy')
  [[ "$autonomy" == "checkpoints" ]]
}

@test "returns defaults when config.json is missing" {
  cd "$TEST_PROJECT_DIR"
  rm "$VIBECREW_DIR/config.json"
  run bash "$SCRIPTS_DIR/read-profile.sh"
  assert_success

  # Should still return valid JSON with defaults
  echo "$output" | jq empty

  local verbosity
  verbosity=$(echo "$output" | jq -r '.verbosity')
  [[ "$verbosity" == "standard" ]]
}

@test "merges stored profile over defaults" {
  cd "$TEST_PROJECT_DIR"
  # Write a partial profile to config.json
  jq '.user_profile = {"interview_completed": true, "role": "developer", "autonomy": "full_auto"}' \
    "$VIBECREW_DIR/config.json" > "$VIBECREW_DIR/config.json.tmp" && \
    mv "$VIBECREW_DIR/config.json.tmp" "$VIBECREW_DIR/config.json"

  run bash "$SCRIPTS_DIR/read-profile.sh"
  assert_success

  # Stored values should be present
  local role
  role=$(echo "$output" | jq -r '.role')
  [[ "$role" == "developer" ]]

  local autonomy
  autonomy=$(echo "$output" | jq -r '.autonomy')
  [[ "$autonomy" == "full_auto" ]]

  # Missing fields should get defaults
  local verbosity
  verbosity=$(echo "$output" | jq -r '.verbosity')
  [[ "$verbosity" == "standard" ]]

  local risk
  risk=$(echo "$output" | jq -r '.risk_tolerance')
  [[ "$risk" == "balanced" ]]
}

@test "always exits 0" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/read-profile.sh"
  assert_success

  # Even with missing config
  rm "$VIBECREW_DIR/config.json"
  run bash "$SCRIPTS_DIR/read-profile.sh"
  assert_success
}

@test "output is valid JSON" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/read-profile.sh"
  assert_success
  # jq empty will fail on invalid JSON
  echo "$output" | jq empty
}
