#!/usr/bin/env bats
# tests/collect-feature-files.bats
# Tests for scripts/collect-feature-files.sh — feature branch file collection

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  # Need initial commit
  echo "init" > "$TEST_PROJECT_DIR/init.txt"
  git -C "$TEST_PROJECT_DIR" add . && git -C "$TEST_PROJECT_DIR" commit -m "feat: init" >/dev/null 2>&1
}

teardown() {
  teardown_vibecrew_dir
}

@test "no state.json returns empty array" {
  cd "$TEST_PROJECT_DIR"
  rm "$VIBECREW_DIR/state.json"

  run bash "$SCRIPTS_DIR/collect-feature-files.sh"
  assert_success
  [[ "$output" == "[]" ]]
}

@test "no active feature returns empty array" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/collect-feature-files.sh"
  assert_success
  [[ "$output" == "[]" ]]
}

@test "on default branch returns empty array" {
  cd "$TEST_PROJECT_DIR"
  set_active_feature "feat-001" "Test" "code"

  run bash "$SCRIPTS_DIR/collect-feature-files.sh"
  assert_success
  [[ "$output" == "[]" ]]
}

@test "collects source files on feature branch" {
  cd "$TEST_PROJECT_DIR"
  set_active_feature "feat-001" "Test" "code"

  # Create feature branch with source files
  git -C "$TEST_PROJECT_DIR" checkout -b feat/test-feature >/dev/null 2>&1
  mkdir -p "$TEST_PROJECT_DIR/src"
  echo "const x = 1;" > "$TEST_PROJECT_DIR/src/app.ts"
  git -C "$TEST_PROJECT_DIR" add . && git -C "$TEST_PROJECT_DIR" commit -m "feat: add app" >/dev/null 2>&1

  run bash "$SCRIPTS_DIR/collect-feature-files.sh"
  assert_success

  echo "$output" | jq empty
  local len
  len=$(echo "$output" | jq 'length')
  [[ "$len" -ge 1 ]]
}

@test "filters out node_modules and dist" {
  cd "$TEST_PROJECT_DIR"
  set_active_feature "feat-001" "Test" "code"

  git -C "$TEST_PROJECT_DIR" checkout -b feat/filter-test >/dev/null 2>&1
  mkdir -p "$TEST_PROJECT_DIR/node_modules/pkg" "$TEST_PROJECT_DIR/dist"
  echo "x" > "$TEST_PROJECT_DIR/node_modules/pkg/index.js"
  echo "x" > "$TEST_PROJECT_DIR/dist/bundle.js"
  echo "const y = 2;" > "$TEST_PROJECT_DIR/app.ts"
  git -C "$TEST_PROJECT_DIR" add -f . && git -C "$TEST_PROJECT_DIR" commit -m "feat: files" >/dev/null 2>&1

  run bash "$SCRIPTS_DIR/collect-feature-files.sh"
  assert_success

  # Should not include node_modules or dist files
  [[ "$output" != *"node_modules"* ]]
  [[ "$output" != *"dist/bundle"* ]]
}

@test "filters out config files" {
  cd "$TEST_PROJECT_DIR"
  set_active_feature "feat-001" "Test" "code"

  git -C "$TEST_PROJECT_DIR" checkout -b feat/config-test >/dev/null 2>&1
  echo '{}' > "$TEST_PROJECT_DIR/tsconfig.json"
  echo "# README" > "$TEST_PROJECT_DIR/README.md"
  echo "const z = 3;" > "$TEST_PROJECT_DIR/index.ts"
  git -C "$TEST_PROJECT_DIR" add . && git -C "$TEST_PROJECT_DIR" commit -m "feat: configs" >/dev/null 2>&1

  run bash "$SCRIPTS_DIR/collect-feature-files.sh"
  assert_success

  # Should not include .json or .md
  [[ "$output" != *"tsconfig.json"* ]]
  [[ "$output" != *"README.md"* ]]
}

@test "output is valid JSON array" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/collect-feature-files.sh"
  assert_success
  echo "$output" | jq empty
}
