#!/usr/bin/env bats
# tests/capture-erosion-baseline.bats

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/capture-erosion-baseline.sh"
  setup_vibecrew_dir
  set_foundation_complete
  mkdir -p "$VIBECREW_DIR/erosion"
}

teardown() {
  teardown_vibecrew_dir
}

@test "creates baseline file" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  [ -f "$VIBECREW_DIR/erosion/baseline.json" ]
}

@test "skips when baseline already exists" {
  echo '{"schema_version":"1.0.0"}' > "$VIBECREW_DIR/erosion/baseline.json"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  assert_output --partial "already exists"
}

@test "force flag overwrites existing baseline" {
  echo '{"schema_version":"1.0.0","total_project_loc":999}' > "$VIBECREW_DIR/erosion/baseline.json"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' --force '$TEST_PROJECT_DIR'"
  assert_success
  assert_output --partial "captured"
  # Should have been overwritten (different LOC than 999)
  local loc
  loc=$(jq -r '.total_project_loc' "$VIBECREW_DIR/erosion/baseline.json")
  [ "$loc" != "999" ]
}

@test "baseline contains required fields" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success

  local version
  version=$(jq -r '.schema_version' "$VIBECREW_DIR/erosion/baseline.json")
  [ "$version" = "1.0.0" ]

  local ts
  ts=$(jq -r '.captured_at' "$VIBECREW_DIR/erosion/baseline.json")
  [ -n "$ts" ]
}
