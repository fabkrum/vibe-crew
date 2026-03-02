#!/usr/bin/env bats
# tests/detect-perf-baselines.bats
# Tests for scripts/detect-perf-baselines.sh — performance baseline detection

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

@test "no perf directory returns false" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/detect-perf-baselines.sh" "$TEST_PROJECT_DIR"
  assert_success

  local exists
  exists=$(echo "$output" | jq '.baselines_exist')
  [[ "$exists" == "false" ]]
}

@test "perf directory exists but no matching feature files" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$VIBECREW_DIR/perf-tests"
  set_active_feature "feat-001" "Test Feature" "code"

  run bash "$SCRIPTS_DIR/detect-perf-baselines.sh" "$TEST_PROJECT_DIR"
  assert_success

  local exists
  exists=$(echo "$output" | jq '.baselines_exist')
  [[ "$exists" == "false" ]]
}

@test "finds perf files for active feature" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$VIBECREW_DIR/perf-tests"
  set_active_feature "feat-001" "Test Feature" "code"

  echo '{"test_type":"lighthouse"}' > "$VIBECREW_DIR/perf-tests/perf-feat-001-001.json"
  echo '{"test_type":"bundle-size"}' > "$VIBECREW_DIR/perf-tests/perf-feat-001-002.json"

  run bash "$SCRIPTS_DIR/detect-perf-baselines.sh" "$TEST_PROJECT_DIR"
  assert_success

  local exists
  exists=$(echo "$output" | jq '.baselines_exist')
  [[ "$exists" == "true" ]]

  local types_len
  types_len=$(echo "$output" | jq '.test_types | length')
  [[ "$types_len" == "2" ]]
}

@test "no active feature checks any perf results" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$VIBECREW_DIR/perf-tests"
  echo '{"test_type":"lighthouse"}' > "$VIBECREW_DIR/perf-tests/perf-feat-999-001.json"

  run bash "$SCRIPTS_DIR/detect-perf-baselines.sh" "$TEST_PROJECT_DIR"
  assert_success

  local exists
  exists=$(echo "$output" | jq '.baselines_exist')
  [[ "$exists" == "true" ]]
}

@test "output is valid JSON" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/detect-perf-baselines.sh" "$TEST_PROJECT_DIR"
  assert_success
  echo "$output" | jq empty
}

@test "test_types contains extracted types" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$VIBECREW_DIR/perf-tests"
  set_active_feature "feat-001" "Test Feature" "code"
  echo '{"test_type":"lighthouse"}' > "$VIBECREW_DIR/perf-tests/perf-feat-001-001.json"

  run bash "$SCRIPTS_DIR/detect-perf-baselines.sh" "$TEST_PROJECT_DIR"
  assert_success

  echo "$output" | jq -e '.test_types | index("lighthouse")' >/dev/null
}
