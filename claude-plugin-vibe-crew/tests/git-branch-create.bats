#!/usr/bin/env bats
# tests/git-branch-create.bats
# Tests for scripts/git-branch-create.sh — feature branch creation

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  # Need an initial commit for branch operations
  echo "init" > "$TEST_PROJECT_DIR/init.txt"
  git -C "$TEST_PROJECT_DIR" add . && git -C "$TEST_PROJECT_DIR" commit -m "feat: init" >/dev/null 2>&1
}

teardown() {
  teardown_vibecrew_dir
}

@test "creates branch with sanitized name" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/git-branch-create.sh" "User Authentication"
  assert_success

  local branch
  branch=$(echo "$output" | jq -r '.branch')
  [[ "$branch" == "feat/user-authentication" ]]

  local action
  action=$(echo "$output" | jq -r '.action')
  [[ "$action" == "created" ]]
}

@test "converts to lowercase and replaces spaces" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/git-branch-create.sh" "My Feature Name"
  assert_success

  local branch
  branch=$(echo "$output" | jq -r '.branch')
  [[ "$branch" == "feat/my-feature-name" ]]
}

@test "removes special characters" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/git-branch-create.sh" "Feature: Add @auth & #login!"
  assert_success

  local branch
  branch=$(echo "$output" | jq -r '.branch')
  # Special chars removed, hyphens collapsed
  [[ "$branch" == "feat/feature-add-auth-login" ]]
}

@test "truncates to 50 chars" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/git-branch-create.sh" "This is a very long feature name that exceeds the fifty character limit for branch names"
  assert_success

  local branch
  branch=$(echo "$output" | jq -r '.branch')
  # feat/ prefix + 50 chars max for the slug
  local slug="${branch#feat/}"
  [[ ${#slug} -le 50 ]]
}

@test "replaces underscores with hyphens" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/git-branch-create.sh" "user_profile_page"
  assert_success

  local branch
  branch=$(echo "$output" | jq -r '.branch')
  [[ "$branch" == "feat/user-profile-page" ]]
}

@test "checks out existing branch" {
  cd "$TEST_PROJECT_DIR"
  git checkout -b "feat/existing-feature" >/dev/null 2>&1
  git checkout main >/dev/null 2>&1

  run bash "$SCRIPTS_DIR/git-branch-create.sh" "Existing Feature"
  assert_success

  local existed
  existed=$(echo "$output" | jq '.existed')
  [[ "$existed" == "true" ]]

  local action
  action=$(echo "$output" | jq -r '.action')
  [[ "$action" == "checkout" ]]
}

@test "fails with no arguments" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/git-branch-create.sh"
  assert_failure
}

@test "fails outside git repo" {
  local tmpdir
  tmpdir="$(mktemp -d)"
  cd "$tmpdir"
  run bash "$SCRIPTS_DIR/git-branch-create.sh" "Test Feature"
  assert_failure
  rm -rf "$tmpdir"
}

@test "output is valid JSON" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/git-branch-create.sh" "Test"
  assert_success
  echo "$output" | jq empty
}

@test "collapses multiple hyphens" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/git-branch-create.sh" "Hello---World"
  assert_success

  local branch
  branch=$(echo "$output" | jq -r '.branch')
  [[ "$branch" == "feat/hello-world" ]]
}
