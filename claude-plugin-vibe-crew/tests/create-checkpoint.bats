#!/usr/bin/env bats
# tests/create-checkpoint.bats
# Tests for scripts/create-checkpoint.sh — VibeCrew checkpoint creation

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  # Need a commit to tag
  echo "init" > "$TEST_PROJECT_DIR/init.txt"
  git -C "$TEST_PROJECT_DIR" add . && git -C "$TEST_PROJECT_DIR" commit -m "feat: init" >/dev/null 2>&1
}

teardown() {
  teardown_vibecrew_dir
}

@test "creates checkpoint tag" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/create-checkpoint.sh"
  assert_success

  # Output should contain the tag name
  [[ "$output" == vibecrew-checkpoint-* ]]

  # Tag should exist in git
  git tag -l "vibecrew-checkpoint-*" | grep -q "vibecrew-checkpoint"
}

@test "tag name contains timestamp" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/create-checkpoint.sh"
  assert_success

  # Should match pattern vibecrew-checkpoint-YYYY-MM-DDTHH-MM-SSZ
  [[ "$output" =~ vibecrew-checkpoint-[0-9]{4}-[0-9]{2}-[0-9]{2}T ]]
}

@test "custom description in tag message" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/create-checkpoint.sh" "before auth refactor"
  assert_success

  # Tag message should contain custom description
  local tag_name="$output"
  local message
  message=$(git tag -l --format='%(contents)' "$tag_name" 2>/dev/null)
  [[ "$message" == *"before auth refactor"* ]]
}

@test "default description when none given" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/create-checkpoint.sh"
  assert_success

  local tag_name="$output"
  local message
  message=$(git tag -l --format='%(contents)' "$tag_name" 2>/dev/null)
  [[ "$message" == *"VibeCrew checkpoint"* ]]
}

@test "exit 0 always" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/create-checkpoint.sh"
  assert_success
}
