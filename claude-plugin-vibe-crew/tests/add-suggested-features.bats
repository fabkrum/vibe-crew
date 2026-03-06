#!/usr/bin/env bats
# tests/add-suggested-features.bats
# Tests for scripts/add-suggested-features.sh

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  SCRIPT="$SCRIPTS_DIR/add-suggested-features.sh"
}

teardown() {
  teardown_vibecrew_dir
}

@test "adds features to empty backlog" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPT" '[{"name":"Dark mode","description":"Support dark theme","priority":"differentiator"}]'
  assert_success
  echo "$output" | jq empty
  [[ $(echo "$output" | jq -r '.added') -eq 1 ]]
  [[ $(echo "$output" | jq -r '.skipped') -eq 0 ]]
  [[ $(echo "$output" | jq -r '.feature_ids[0]') == "feat-001" ]]

  # Verify backlog entry
  local entry
  entry=$(jq '.features[-1]' "$VIBECREW_DIR/backlog.json")
  [[ $(echo "$entry" | jq -r '.name') == "Dark mode" ]]
  [[ $(echo "$entry" | jq -r '.column') == "idea" ]]
  [[ $(echo "$entry" | jq -r '.source') == "competitive-analysis" ]]
  [[ $(echo "$entry" | jq -r '.labels[0]') == "competitive-analysis" ]]
}

@test "adds multiple features" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPT" '[{"name":"Feature A","description":"Desc A","priority":"must-have"},{"name":"Feature B","description":"Desc B","priority":"nice-to-have"}]'
  assert_success
  [[ $(echo "$output" | jq -r '.added') -eq 2 ]]
  [[ $(jq '.features | length' "$VIBECREW_DIR/backlog.json") -eq 2 ]]
}

@test "deduplicates by name case-insensitive" {
  cd "$TEST_PROJECT_DIR"
  add_feature_to_backlog "feat-001" "Dark Mode"
  run bash "$SCRIPT" '[{"name":"dark mode","description":"Already exists","priority":"must-have"}]'
  assert_success
  [[ $(echo "$output" | jq -r '.added') -eq 0 ]]
  [[ $(echo "$output" | jq -r '.skipped') -eq 1 ]]
  # Backlog still has only the original
  [[ $(jq '.features | length' "$VIBECREW_DIR/backlog.json") -eq 1 ]]
}

@test "skips features without name" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPT" '[{"description":"No name","priority":"must-have"},{"name":"Valid","description":"Has name","priority":"must-have"}]'
  assert_success
  [[ $(echo "$output" | jq -r '.added') -eq 1 ]]
  [[ $(echo "$output" | jq -r '.skipped') -eq 1 ]]
}

@test "maps must-have to priority 1" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPT" '[{"name":"Critical Feature","description":"Must have","priority":"must-have"}]'
  assert_success
  [[ $(jq '.features[-1].priority' "$VIBECREW_DIR/backlog.json") -eq 1 ]]
}

@test "maps differentiator to priority 2" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPT" '[{"name":"Unique Feature","description":"Differentiator","priority":"differentiator"}]'
  assert_success
  [[ $(jq '.features[-1].priority' "$VIBECREW_DIR/backlog.json") -eq 2 ]]
}

@test "maps nice-to-have to priority 3" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPT" '[{"name":"Optional Feature","description":"Nice to have","priority":"nice-to-have"}]'
  assert_success
  [[ $(jq '.features[-1].priority' "$VIBECREW_DIR/backlog.json") -eq 3 ]]
}

@test "defaults unknown priority to 3" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPT" '[{"name":"Unknown Priority","description":"Desc"}]'
  assert_success
  [[ $(jq '.features[-1].priority' "$VIBECREW_DIR/backlog.json") -eq 3 ]]
}

@test "continues ID sequence from existing backlog" {
  cd "$TEST_PROJECT_DIR"
  add_feature_to_backlog "feat-005" "Existing Feature"
  run bash "$SCRIPT" '[{"name":"New Feature","description":"Desc","priority":"must-have"}]'
  assert_success
  [[ $(echo "$output" | jq -r '.feature_ids[0]') == "feat-006" ]]
}

@test "invalid JSON input returns error" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPT" 'not json'
  assert_success
  [[ $(echo "$output" | jq -r '.status') == "error" ]]
  [[ $(echo "$output" | jq -r '.error') == *"JSON array"* ]]
}

@test "empty array returns skipped status" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPT" '[]'
  assert_success
  [[ $(echo "$output" | jq -r '.status') == "skipped" ]]
  [[ $(echo "$output" | jq -r '.added') -eq 0 ]]
}

@test "missing backlog.json returns error" {
  cd "$TEST_PROJECT_DIR"
  rm "$VIBECREW_DIR/backlog.json"
  run bash "$SCRIPT" '[{"name":"Test","description":"Desc","priority":"must-have"}]'
  assert_success
  [[ $(echo "$output" | jq -r '.status') == "error" ]]
  [[ $(echo "$output" | jq -r '.error') == *"backlog.json not found"* ]]
}

@test "reads features from stdin" {
  cd "$TEST_PROJECT_DIR"
  run bash -c 'echo '\''[{"name":"Stdin Feature","description":"From stdin","priority":"must-have"}]'\'' | bash '"$SCRIPT"''
  assert_success
  [[ $(echo "$output" | jq -r '.added') -eq 1 ]]
}

@test "technical_notes includes priority label" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPT" '[{"name":"Test Feature","description":"Desc","priority":"differentiator"}]'
  assert_success
  local notes
  notes=$(jq -r '.features[-1].spec.technical_notes' "$VIBECREW_DIR/backlog.json")
  [[ "$notes" == *"differentiator"* ]]
  [[ "$notes" == *"competitive analysis"* ]]
}

@test "deduplicates within batch" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPT" '[{"name":"Same Feature","description":"First","priority":"must-have"},{"name":"Same Feature","description":"Duplicate","priority":"nice-to-have"}]'
  assert_success
  [[ $(echo "$output" | jq -r '.added') -eq 1 ]]
  [[ $(echo "$output" | jq -r '.skipped') -eq 1 ]]
}
