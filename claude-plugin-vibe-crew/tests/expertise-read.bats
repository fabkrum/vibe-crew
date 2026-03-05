#!/usr/bin/env bats
# tests/expertise-read.bats

setup() {
  load 'test_helper/common-setup'
  WRITE_SCRIPT="$SCRIPTS_DIR/expertise-write.sh"
  SCRIPT="$SCRIPTS_DIR/expertise-read.sh"
  setup_vibecrew_dir
  set_foundation_complete
  mkdir -p "$VIBECREW_DIR/expertise"

  # Seed test records
  bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --domain conventions --type convention --tier foundational --content 'Use semicolons' --confidence 0.90 --tags 'style' --session-id 'session-test'" > /dev/null
  bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --domain conventions --type pattern --tier tactical --content 'Use barrel exports' --confidence 0.60 --tags 'imports' --session-id 'session-test'" > /dev/null
  bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --domain failures --type failure --tier observational --content 'Build fails with stale cache' --confidence 0.50 --session-id 'session-test'" > /dev/null
}

teardown() {
  teardown_vibecrew_dir
}

@test "returns all records when no filters" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' --no-update"
  assert_success
  local count
  count=$(echo "$output" | jq 'length')
  [ "$count" -eq 3 ]
}

@test "filters by domain" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' --domain conventions --no-update"
  assert_success
  local count
  count=$(echo "$output" | jq 'length')
  [ "$count" -eq 2 ]
}

@test "filters by tier" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' --tier foundational --no-update"
  assert_success
  local count
  count=$(echo "$output" | jq 'length')
  [ "$count" -eq 1 ]
}

@test "filters by type" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' --type failure --no-update"
  assert_success
  local count
  count=$(echo "$output" | jq 'length')
  [ "$count" -eq 1 ]
}

@test "filters by tags" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' --tags style --no-update"
  assert_success
  local count
  count=$(echo "$output" | jq 'length')
  [ "$count" -eq 1 ]
}

@test "sorts by confidence descending" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' --no-update"
  assert_success
  local first_conf
  first_conf=$(echo "$output" | jq '.[0].confidence')
  local last_conf
  last_conf=$(echo "$output" | jq '.[-1].confidence')
  # first should be >= last
  [ "$(echo "$first_conf >= $last_conf" | bc -l)" -eq 1 ]
}

@test "respects limit" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' --limit 1 --no-update"
  assert_success
  local count
  count=$(echo "$output" | jq 'length')
  [ "$count" -eq 1 ]
}

@test "returns empty array when no expertise dir" {
  rm -rf "$VIBECREW_DIR/expertise"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  assert_output "[]"
}
