#!/usr/bin/env bats
# tests/save-competitive-analysis.bats
# Tests for scripts/save-competitive-analysis.sh

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  SCRIPT="$SCRIPTS_DIR/save-competitive-analysis.sh"
}

teardown() {
  teardown_vibecrew_dir
}

@test "saves analysis to default path" {
  cd "$TEST_PROJECT_DIR"
  run bash -c 'echo "# Competitive Analysis" | bash '"$SCRIPT"''
  assert_success
  echo "$output" | jq empty
  [[ $(echo "$output" | jq -r '.status') == "saved" ]]
  [[ -f "$TEST_PROJECT_DIR/docs/competitive-analysis.md" ]]
  [[ $(cat "$TEST_PROJECT_DIR/docs/competitive-analysis.md") == "# Competitive Analysis" ]]
}

@test "creates docs directory if missing" {
  cd "$TEST_PROJECT_DIR"
  [[ ! -d "$TEST_PROJECT_DIR/docs" ]]
  run bash -c 'echo "# Analysis" | bash '"$SCRIPT"''
  assert_success
  [[ -d "$TEST_PROJECT_DIR/docs" ]]
  [[ -f "$TEST_PROJECT_DIR/docs/competitive-analysis.md" ]]
}

@test "saves to custom output path" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p reports
  run bash -c 'echo "# Custom" | bash '"$SCRIPT"' '"$TEST_PROJECT_DIR/reports/analysis.md"''
  assert_success
  [[ -f "$TEST_PROJECT_DIR/reports/analysis.md" ]]
  [[ $(cat "$TEST_PROJECT_DIR/reports/analysis.md") == "# Custom" ]]
}

@test "overwrites existing analysis" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p docs
  echo "old content" > "$TEST_PROJECT_DIR/docs/competitive-analysis.md"
  run bash -c 'echo "new content" | bash '"$SCRIPT"''
  assert_success
  [[ $(cat "$TEST_PROJECT_DIR/docs/competitive-analysis.md") == "new content" ]]
}

@test "empty input returns error" {
  cd "$TEST_PROJECT_DIR"
  run bash -c 'echo -n "" | bash '"$SCRIPT"''
  assert_success
  [[ $(echo "$output" | jq -r '.error') == *"No analysis content"* ]]
}

@test "output includes file path" {
  cd "$TEST_PROJECT_DIR"
  run bash -c 'echo "# Analysis" | bash '"$SCRIPT"''
  assert_success
  [[ $(echo "$output" | jq -r '.file') == *"competitive-analysis.md"* ]]
}
